//
//  ChatFeature.swift
//  Presentation
//
//  Created by 김영훈 on 1/6/26.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct ChatFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        let roomId: String
        let myUserId: String
        let otherNickname: String
        var chats: [Chat] = []
        var messageText = ""
        var isLoading = false
        
        @Presents var alert: AlertState<ChatListFeature.Alert>?
    }

    // MARK: - Action
    enum Action: Sendable {
        case onAppear
        case textChanged(String)
        case sendButtonTapped
    }

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case let .textChanged(text):
                state.messageText = text
                return .none
                
            case .sendButtonTapped:
                return .none
            }
        }
    }
}
