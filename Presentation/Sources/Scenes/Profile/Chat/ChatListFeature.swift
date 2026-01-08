//
//  ChatListFeature.swift
//  Presentation
//
//  Created by 김영훈 on 1/6/26.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct ChatListFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        let myUserId: String
        var chatRooms: [ChatRoom] = []
        var searchText = ""
        var isLoading = false
        
        var filteredChatRooms: [ChatRoom] {
            if searchText.isEmpty { return chatRooms }
            return chatRooms.filter { room in
                let nickname = room.participants.first { $0.userId != myUserId }?.nickname ?? ""
                let lastMessage = room.lastChat?.content ?? ""
                return nickname.localizedCaseInsensitiveContains(searchText) ||
                lastMessage.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        var isSearchEmpty: Bool {
            !searchText.isEmpty && filteredChatRooms.isEmpty
        }
        
        @Presents var destination: Destination.State?
        @Presents var alert: AlertState<ChatListFeature.Alert>?
    }

    // MARK: - Action
    enum Action: Sendable {
        case onAppear
        case fetchChatRooms
        case chatRoomsLoaded([ChatRoom])
        case chatRoomsFailed(Error)
        case chatRoomTapped(ChatRoom)
        case searchTextChanged(String)
        
        case destination(PresentationAction<Destination.Action>)
        case alert(PresentationAction<ChatListFeature.Alert>)
    }

    // MARK: - Dependencies
    @Dependency(\.fetchChatRoomList) var fetchChatRoomList

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchChatRooms)

            case .fetchChatRooms:
                state.isLoading = true
                return .run { send in
                    do {
                        let chatRooms = try await fetchChatRoomList.execute()
                        await send(.chatRoomsLoaded(chatRooms))
                    } catch {
                        await send(.chatRoomsFailed(error))
                    }
                }

            case let .chatRoomsLoaded(chatRooms):
                state.isLoading = false
                state.chatRooms = chatRooms.sorted { $0.updatedAt > $1.updatedAt }
                return .none

            case let .chatRoomsFailed(error):
                state.isLoading = false
                state.alert = AlertState {
                    TextState("채팅 목록 불러오기 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case let .chatRoomTapped(chatRoom):
                state.destination = .chat(
                    ChatFeature.State(
                        chatRoom: chatRoom,
                        myUserId: state.myUserId
                    )
                )
                return .none
                
            case let .searchTextChanged(text):
                state.searchText = text
                return .none

            case .destination, .alert:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$alert, action: \.alert)
    }
    
    enum Alert: Sendable {}
}

// MARK: - Destinations
extension ChatListFeature {
    @Reducer
    enum Destination {
        case chat(ChatFeature)
    }
}

extension ChatListFeature.Destination.State: Sendable {}
