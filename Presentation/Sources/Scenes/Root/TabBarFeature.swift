//
//  TabBarFeature.swift
//  Presentation
//
//  Created by 김영훈 on 12/20/25.
//

import Foundation
import Domain
import Data
import ComposableArchitecture

@Reducer
struct TabBarFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        var selectedTab: Tab = .home
        var home = HomeFeature.State()
        var order = OrderFeature.State()
        var community = CommunityFeature.State()
        var profile = MyProfileFeature.State()

        @Presents var alert: AlertState<Alert>?
        @Presents var destination: Destination.State?
    }

    // MARK: - Action
    enum Action {
        case onAppear
        case tabSelected(Tab)
        case centerButtonTapped
        case destination(PresentationAction<Destination.Action>)
        case home(HomeFeature.Action)
        case order(OrderFeature.Action)
        case community(CommunityFeature.Action)
        case profile(MyProfileFeature.Action)
        case deviceTokenError(Error)
        case chatPushTapped(String, Date)
        case fetchChatFailed(Error)
        case navigateToChat(ChatRoom, String)
        case alert(PresentationAction<Alert>)
    }

    enum Alert: Sendable {}
    
    // MARK: - Dependencies
    @Dependency(\.fetchChatList) var fetchChatList
    @Dependency(\.fetchChatRoom) var fetchChatRoom
    @Dependency(\.fetchMyProfile) var fetchMyProfile
    
    // MARK: - Body
    var body: some ReducerOf<Self> {
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }

        Scope(state: \.order, action: \.order) {
            OrderFeature()
        }

        Scope(state: \.community, action: \.community) {
            CommunityFeature()
        }

        Scope(state: \.profile, action: \.profile) {
            MyProfileFeature()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await withTaskGroup(of: Void.self) { group in
                        // 앱 시작 시 대기 중인 알림 확인
                        group.addTask {
                            if let pending = await PendingNotificationManager.shared
                                .consumePendingChatNotification() {
                                await send(.chatPushTapped(pending.roomId, pending.date))
                            }
                        }

                        // Device Token 에러 구독
                        group.addTask {
                            for await notification in NotificationCenter.default.notifications(
                                named: .deviceTokenError
                            ) {
                                if let error = notification.userInfo?["error"] as? Error {
                                    await send(.deviceTokenError(error))
                                }
                            }
                        }

                        // Pending 알림 확인 트리거 구독
                        group.addTask {
                            for await _ in NotificationCenter.default.notifications(
                                named: .checkPendingNotification
                            ) {
                                if let pending = await PendingNotificationManager.shared
                                    .consumePendingChatNotification() {
                                    await send(.chatPushTapped(pending.roomId, pending.date))
                                }
                            }
                        }
                    }
                }

            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none

            case .centerButtonTapped:
                state.destination = .pick(PickFeature.State())
                return .none

            case let .deviceTokenError(error):
                state.alert = AlertState {
                    TextState("푸시 알림 등록 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none
                
            case let .chatPushTapped(roomId, date):
                return .run { send in
                    do {
                        let oneMinuteAgo = Calendar.current.date(byAdding: .minute, value: -1, to: date)
                        async let chatListTask = fetchChatList.execute(
                            roomId: roomId,
                            time: oneMinuteAgo
                        )
                        async let myProfileTask = fetchMyProfile.execute()
                        let (chatList, myProfile) = try await (chatListTask, myProfileTask)
                        
                        let opponentId = chatList.first {
                            $0.sender.userId != myProfile.userId
                        }?.sender.userId
                        guard let opponentId else { return }
                        
                        let chatRoom = try await fetchChatRoom.execute(opponentId: opponentId)
                        await send(.navigateToChat(chatRoom, myProfile.userId))
                    } catch {
                        await send(.fetchChatFailed(error))
                    }
                }
                
            case let .fetchChatFailed(error):
                state.alert = AlertState {
                    TextState("채팅으로 이동 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none
                
            case let .navigateToChat(chatRoom, myUserId):
                state.selectedTab = .profile
                return .send(.profile(.navigateToChat(chatRoom, myUserId)))

            case .alert:
                return .none

            case .destination:
                return .none

            case .home:
                return .none

            case .order:
                return .none

            case .community:
                return .none

            case .profile:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        .ifLet(\.$destination, action: \.destination)
    }
}

// MARK: - Tab
extension TabBarFeature {
    enum Tab: CaseIterable, Sendable {
        case home
        case order
        case pick
        case community
        case profile
    }
}

// MARK: - Destinations
extension TabBarFeature {
    @Reducer
    enum Destination {
        case pick(PickFeature)
    }
}

extension TabBarFeature.Destination.State: Sendable {}

// MARK: - Tab Bar Visibility
extension TabBarFeature.State {
    var isTabBarVisible: Bool {
        // HomeFeature의 detail이나 search destination이 있으면 탭바 숨김
        if home.destination != nil { return false }

        // ProfileFeature에서 ChatFeature로 이동한 경우 탭바 숨김
        if let profileDestination = profile.destination {
            switch profileDestination {
            case .chatList(let chatListState):
                // ChatListFeature → ChatFeature
                if chatListState.destination != nil {
                    return false
                }

            case .searchUser(let searchUserState):
                // SearchUserFeature → OtherProfileFeature → ChatFeature
                if let otherProfileDestination = searchUserState.destination,
                   case .otherProfile(let otherProfileState) = otherProfileDestination,
                   otherProfileState.destination?.chat != nil {
                    return false
                }

            case .chat:
                return false
                
            case .postDetail, .restaurantDetail:
                break
            }
        }

        return true
    }
}
