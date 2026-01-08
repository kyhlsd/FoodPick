//
//  ChatFeature.swift
//  Presentation
//
//  Created by 김영훈 on 1/6/26.
//

import Foundation
import Domain
import Core
import ComposableArchitecture

@Reducer
struct ChatFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        let chatRoom: ChatRoom
        let myUserId: String
        let pageSize: Int

        var socketConnectedAt: Date?
        var disconnectedAt: Date?
        var messageLoading: MessageLoadingFeature.State
        var messageSending: MessageSendingFeature.State

        var roomId: String {
            chatRoom.roomId
        }

        var other: Profile? {
            chatRoom.participants.first { $0.userId != myUserId }
        }

        @Presents var alert: AlertState<Alert>?

        init(chatRoom: ChatRoom, myUserId: String, pageSize: Int = 30) {
            self.chatRoom = chatRoom
            self.myUserId = myUserId
            self.pageSize = pageSize
            self.messageLoading = MessageLoadingFeature.State(roomId: chatRoom.roomId, pageSize: pageSize)
            self.messageSending = MessageSendingFeature.State(roomId: chatRoom.roomId)
        }
    }

    // MARK: - Action
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case socketConnect
        case socketConnected(Date)
        case socketConnectionFailed
        case socketMessageReceived(Chat)
        case socketDisconnect
        case appWillResignActive
        case appDidBecomeActive
        case messageLoading(MessageLoadingFeature.Action)
        case messageSending(MessageSendingFeature.Action)
        case messageSavedLocally(Chat)
        case alert(PresentationAction<Alert>)
    }

    // MARK: - Dependencies
    @Dependency(\.saveLocalChat) var saveLocalChat
    @Dependency(\.connectChatSocket) var connectChatSocket
    @Dependency(\.disconnectChatSocket) var disconnectChatSocket
    @Dependency(\.receiveChatMessages) var receiveChatMessages

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Scope(state: \.messageLoading, action: \.messageLoading) {
            MessageLoadingFeature()
        }

        Scope(state: \.messageSending, action: \.messageSending) {
            MessageSendingFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .send(.socketConnect),
                    .run { send in
                        await withTaskGroup(of: Void.self) { group in
                            // 앱이 백그라운드로 갈 때 감지
                            group.addTask {
                                for await _ in NotificationCenter.default.notifications(
                                    named: Notification.Name("UIApplicationWillResignActiveNotification")
                                ) {
                                    await send(.appWillResignActive)
                                }
                            }
                            
                            // 앱이 포그라운드로 돌아올 때 감지
                            group.addTask {
                                for await _ in NotificationCenter.default.notifications(
                                    named: Notification.Name("UIApplicationDidBecomeActiveNotification")
                                ) {
                                    await send(.appDidBecomeActive)
                                }
                            }
                        }
                    }
                )

            case .socketConnect:
                let roomId = state.roomId
                return .run { send in
                    do {
                        let connectedAt = Date()
                        try await connectChatSocket.execute(roomId: roomId)
                        await send(.socketConnected(connectedAt))

                        for await chat in receiveChatMessages.execute() {
                            await send(.socketMessageReceived(chat))
                        }
                    } catch is CancellationError {
                    } catch {
                        await send(.socketConnectionFailed)
                    }
                }
                
            case let .socketConnected(connectedAt):
                state.socketConnectedAt = connectedAt

                // 백그라운드에서 돌아온 경우: 끊어진 시점부터 로드
                if let disconnectedAt = state.disconnectedAt {
                    state.disconnectedAt = nil
                    return .send(.messageLoading(.fetchNew(disconnectedAt)))
                }

                // 처음 채팅방에 들어온 경우: 초기 로드
                return .send(.messageLoading(.loadInitial))

            case .socketConnectionFailed:
                // 백그라운드에서 돌아온 경우: 끊어진 시점부터 로드
                if let disconnectedAt = state.disconnectedAt {
                    state.disconnectedAt = nil
                    return .send(.messageLoading(.fetchNew(disconnectedAt)))
                }

                // 처음 채팅방에 들어온 경우: 초기 로드
                return .send(.messageLoading(.loadInitial))

            case let .socketMessageReceived(chat):
                return .run { send in
                    do {
                        try await saveLocalChat.execute(chat)
                        await send(.messageSavedLocally(chat))
                    } catch {
                        await send(.messageLoading(.loadingFailed(error)))
                    }
                }

            case .socketDisconnect:
                return .run { _ in
                    await disconnectChatSocket.execute()
                }

            case .appWillResignActive:
                state.disconnectedAt = Date()
                return .send(.socketDisconnect)

            case .appDidBecomeActive:
                return .send(.socketConnect)

            case .messageLoading(.initialLoaded):
                let referenceDate = state.messageLoading.latestMessageDate ?? state.socketConnectedAt

                if let date = referenceDate {
                    return .send(.messageLoading(.fetchNew(date)))
                }

                return .none

            case .messageLoading(.loadingFailed(let error)):
                state.alert = AlertState {
                    TextState("오류")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case .messageSending(.messageSent(let chat)):
                return .run { send in
                    do {
                        try await saveLocalChat.execute(chat)
                        await send(.messageSavedLocally(chat))
                    } catch {
                        await send(.messageLoading(.loadingFailed(error)))
                    }
                }

            case let .messageSavedLocally(chat):
                let existingChatIds = Set(state.messageLoading.chats.map { $0.chatId })
                if !existingChatIds.contains(chat.chatId) {
                    state.messageLoading.chats.append(chat)
                }
                return .none

            case .messageSending(.sendingFailed(let error)):
                state.alert = AlertState {
                    TextState("오류")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case .messageLoading, .messageSending:
                return .none

            case .alert:
                return .none

            case .binding:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    enum Alert: Sendable {}
}
