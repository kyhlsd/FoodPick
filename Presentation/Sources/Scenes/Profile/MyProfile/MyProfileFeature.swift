//
//  MyProfileFeature.swift
//  Presentation
//
//  Created by 김영훈 on 1/6/26.
//

import Foundation
import Domain
import Data
import ComposableArchitecture

@Reducer
struct MyProfileFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        var profileEditor = ProfileEditorFeature.State()
        var content = ProfileContentFeature.State()
        var settings = ProfileSettingsFeature.State()
        var unreadMessageCount: Int = 0

        @Presents var destination: Destination.State?
    }

    // MARK: - Action
    enum Action {
        case onAppear
        case profileEditor(ProfileEditorFeature.Action)
        case content(ProfileContentFeature.Action)
        case settings(ProfileSettingsFeature.Action)
        case searchButtonTapped
        case chatListButtonTapped
        case postTapped(postId: String)
        case restaurantTapped(restaurantId: String)
        case navigateToChat(ChatRoom, String)
        case destination(PresentationAction<Destination.Action>)
        case updateUnreadCount
        case updateUnreadCountResponse(Int)
    }

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Scope(state: \.profileEditor, action: \.profileEditor) {
            ProfileEditorFeature()
        }

        Scope(state: \.content, action: \.content) {
            ProfileContentFeature()
        }

        Scope(state: \.settings, action: \.settings) {
            ProfileSettingsFeature()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .send(.profileEditor(.fetchMyProfile)),
                    .send(.content(.fetchMyLikes)),
                    .send(.updateUnreadCount)
                )

            case .profileEditor(.myProfileLoaded(let profile)):
                // 프로필 로드 후 게시물 fetch
                state.content.userId = profile.userId
                return .send(.content(.fetchUserPosts(userId: profile.userId)))

            case .profileEditor:
                return .none

            case .content:
                return .none

            case .settings:
                return .none

            case .searchButtonTapped:
                state.destination = .searchUser(
                    SearchUserFeature.State(myUserId: state.profileEditor.myProfile?.userId)
                )
                return .none

            case .chatListButtonTapped:
                if let myUserId = state.profileEditor.myProfile?.userId {
                    state.destination = .chatList(ChatListFeature.State(myUserId: myUserId))
                }
                return .none

            case let .postTapped(postId):
                state.destination = .postDetail(
                    PostDetailFeature.State(postId: postId, myUserId: state.profileEditor.myProfile?.userId)
                )
                return .none

            case let .restaurantTapped(restaurantId):
                state.destination = .restaurantDetail(
                    RestaurantDetailFeature.State(restaurantId: restaurantId)
                )
                return .none
                
            case let .navigateToChat(chatRoom, myUserId):
                state.destination = .chat(
                    ChatFeature.State(
                        chatRoom: chatRoom,
                        myUserId: myUserId
                    )
                )
                return .none

            case .updateUnreadCount:
                return .run { send in
                    let count = await UnreadMessageBadgeManager.shared.getTotalUnreadCount()
                    await send(.updateUnreadCountResponse(count))
                }

            case let .updateUnreadCountResponse(count):
                state.unreadMessageCount = count
                return .none

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

// MARK: - Destinations
extension MyProfileFeature {
    @Reducer
    enum Destination {
        case postDetail(PostDetailFeature)
        case restaurantDetail(RestaurantDetailFeature)
        case searchUser(SearchUserFeature)
        case chatList(ChatListFeature)
        case chat(ChatFeature)
    }
}

extension MyProfileFeature.Destination.State: Sendable {}
