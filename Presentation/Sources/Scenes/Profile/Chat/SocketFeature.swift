//
//  SocketFeature.swift
//  Presentation
//
//  Created by 김영훈 on 1/8/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SocketFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        var socketConnectedAt: Date?
        let roomId: String
    }

    // MARK: - Action
    enum Action: Sendable {
        case connect
        case disconnect
        case connected(Date)
        case connectionFailed
    }

    // MARK: - Dependencies
    @Dependency(\.connectChatSocket) var connectChatSocket
    @Dependency(\.disconnectChatSocket) var disconnectChatSocket

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .connect:
                let roomId = state.roomId
                return .run { send in
                    do {
                        let connectedAt = Date()
                        try await connectChatSocket.execute(roomId: roomId)
                        await send(.connected(connectedAt))
                    } catch {
                        await send(.connectionFailed)
                    }
                }

            case let .connected(connectedAt):
                state.socketConnectedAt = connectedAt
                return .none

            case .connectionFailed:
                return .none

            case .disconnect:
                return .run { _ in
                    await disconnectChatSocket.execute()
                }
            }
        }
    }
}
