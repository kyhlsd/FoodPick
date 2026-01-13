//
//  MessageLoadingFeature.swift
//  Presentation
//
//  Created by 김영훈 on 1/8/26.
//

import Foundation
import Data
import Domain
import ComposableArchitecture

@Reducer
struct MessageLoadingFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        var chats: [Chat] = []
        var isLoading = false
        var isLoadingMore = false
        var isFetchingNew = false
        var hasMoreMessages = true
        let roomId: String
        let pageSize: Int

        var oldestMessageDate: Date? {
            chats.first?.createdAt
        }

        var latestMessageDate: Date? {
            chats.last?.updatedAt
        }
    }

    // MARK: - Action
    enum Action: Sendable {
        case loadInitial
        case initialLoaded([Chat])
        case loadOlder
        case olderLoaded([Chat])
        case fetchNew(Date?)
        case newFetched([Chat])
        case newSaved([Chat])
        case loadingFailed(Error)
    }

    // MARK: - Dependencies
    @Dependency(\.fetchRecentChats) var fetchRecentChats
    @Dependency(\.fetchOlderChats) var fetchOlderChats
    @Dependency(\.fetchChatList) var fetchChatList
    @Dependency(\.saveLocalChats) var saveLocalChats

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadInitial:
                guard !state.isLoading else { return .none }
                state.isLoading = true
                let roomId = state.roomId
                let limit = state.pageSize

                return .run { send in
                    do {
                        let chats = try await fetchRecentChats.execute(
                            roomId: roomId,
                            limit: limit
                        )
                        await send(.initialLoaded(chats))
                    } catch {
                        await send(.loadingFailed(error))
                    }
                }

            case let .initialLoaded(chats):
                state.isLoading = false
                state.chats = chats
                state.hasMoreMessages = chats.count >= state.pageSize
                return .none

            case .loadOlder:
                guard !state.isLoadingMore,
                      state.hasMoreMessages,
                      let oldestDate = state.oldestMessageDate else {
                    return .none
                }

                state.isLoadingMore = true
                let roomId = state.roomId
                let limit = state.pageSize

                return .run { send in
                    do {
                        let olderChats = try await fetchOlderChats.execute(
                            roomId: roomId,
                            before: oldestDate,
                            limit: limit
                        )
                        await send(.olderLoaded(olderChats))
                    } catch {
                        await send(.loadingFailed(error))
                    }
                }

            case let .olderLoaded(olderChats):
                state.isLoadingMore = false
                if !olderChats.isEmpty {
                    state.chats = olderChats + state.chats
                    state.hasMoreMessages = olderChats.count >= state.pageSize
                } else {
                    state.hasMoreMessages = false
                }
                return .none

            case let .fetchNew(referenceDate):
                guard !state.isFetchingNew else { return .none }
                state.isFetchingNew = true
                let roomId = state.roomId

                return .run { send in
                    do {
                        let newChats = try await fetchChatList.execute(roomId: roomId, time: referenceDate)
                        await send(.newFetched(newChats))
                    } catch {
                        await send(.loadingFailed(error))
                    }
                }

            case let .newFetched(newChats):
                guard !newChats.isEmpty else {
                    state.isFetchingNew = false
                    return .none
                }

                return .run { send in
                    do {
                        try await saveLocalChats.execute(newChats)
                        await send(.newSaved(newChats))
                    } catch {
                        await send(.loadingFailed(error))
                    }
                }

            case let .newSaved(newChats):
                state.isFetchingNew = false

                let existingChatIds = Set(state.chats.map { $0.chatId })
                let uniqueNewChats = newChats.filter { !existingChatIds.contains($0.chatId) }

                if !uniqueNewChats.isEmpty {
                    state.chats.append(contentsOf: uniqueNewChats)
                }

                // 읽지 않은 메시지 수 초기화
                let roomId = state.roomId
                return .run { _ in
                    await UnreadMessageBadgeManager.shared.clearUnreadCount(for: roomId)
                }

            case .loadingFailed:
                state.isLoading = false
                state.isLoadingMore = false
                state.isFetchingNew = false
                return .none
            }
        }
    }
}
