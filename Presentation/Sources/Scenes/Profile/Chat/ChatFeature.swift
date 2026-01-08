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

        var socket: SocketFeature.State
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
            self.socket = SocketFeature.State(roomId: chatRoom.roomId)
            self.messageLoading = MessageLoadingFeature.State(roomId: chatRoom.roomId, pageSize: pageSize)
            self.messageSending = MessageSendingFeature.State(roomId: chatRoom.roomId)
        }
    }

    // MARK: - Action
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case onDisappear
        case socket(SocketFeature.Action)
        case messageLoading(MessageLoadingFeature.Action)
        case messageSending(MessageSendingFeature.Action)
        case messageSavedLocally(Chat)
        case alert(PresentationAction<Alert>)
    }

    // MARK: - Dependencies
    @Dependency(\.saveLocalChat) var saveLocalChat

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Scope(state: \.socket, action: \.socket) {
            SocketFeature()
        }

        Scope(state: \.messageLoading, action: \.messageLoading) {
            MessageLoadingFeature()
        }

        Scope(state: \.messageSending, action: \.messageSending) {
            MessageSendingFeature()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.socket(.connect))

            case .onDisappear:
                return .send(.socket(.disconnect))

            case .socket(.connected):
                return .send(.messageLoading(.loadInitial))

            case .socket(.connectionFailed):
                return .send(.messageLoading(.loadInitial))

            case .messageLoading(.initialLoaded):
                let referenceDate = state.messageLoading.latestMessageDate ?? state.socket.socketConnectedAt

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
                state.messageLoading.chats.append(chat)
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

            case .socket, .messageLoading, .messageSending:
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
