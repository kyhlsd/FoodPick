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
        let roomId: String
        let myUserId: String
        let otherNickname: String
        var chats: [Chat] = []
        var messageText = ""
        var isLoading = false
        var isShowingMediaPicker = false
        let maxMedia = 5
        
        var isMessageEmpty: Bool {
            messageText
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty
        }
        
        @Presents var alert: AlertState<ChatListFeature.Alert>?
    }

    // MARK: - Action
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case textChanged(String)
        case sendButtonTapped
        case mediaButtonTapped
        case mediaSelected([(Data, MediaType)])
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
                
            case .mediaButtonTapped:
                state.isShowingMediaPicker = true
                return .none
                
            case let .mediaSelected(dataArray):
                state.isShowingMediaPicker = false
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}
