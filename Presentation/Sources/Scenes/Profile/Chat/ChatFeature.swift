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
        var chats: [Chat] = []
        var messageText = ""
        var isLoading = false
        var isLoadingMore = false
        var isFetchingNew = false
        var hasMoreMessages = true
        var isShowingMediaPicker = false
        var uploadProgress: Double?
        let maxMedia = 5
        let pageSize = 30

        var roomId: String {
            chatRoom.roomId
        }

        var other: Profile? {
            chatRoom.participants.first { $0.userId != myUserId }
        }

        var isMessageEmpty: Bool {
            messageText
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty
        }

        var oldestMessageDate: Date? {
            chats.first?.createdAt
        }

        var latestMessageDate: Date? {
            chats.last?.updatedAt
        }

        @Presents var alert: AlertState<Alert>?
    }

    // MARK: - Action
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case loadInitialMessages
        case loadOlderMessages
        case initialMessagesLoaded([Chat])
        case olderMessagesLoaded([Chat])
        case fetchNewMessages
        case newMessagesFetched([Chat])
        case newMessagesSaved([Chat])
        case loadingFailed(Error)
        case textChanged(String)
        case sendButtonTapped
        case mediaButtonTapped
        case mediaSelected([(Data, MediaType)])
        case uploadProgressUpdated(Double)
        case filesUploaded([String])
        case messageSent(Chat)
        case messageSavedLocally(Chat)
        case alert(PresentationAction<Alert>)
    }

    // MARK: - Dependencies
    @Dependency(\.fetchRecentChats) var fetchRecentChats
    @Dependency(\.fetchOlderChats) var fetchOlderChats
    @Dependency(\.fetchChatList) var fetchChatList
    @Dependency(\.saveLocalChats) var saveLocalChats
    @Dependency(\.saveLocalChat) var saveLocalChat
    @Dependency(\.uploadChatFiles) var uploadChatFiles
    @Dependency(\.sendMessage) var sendMessage

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadInitialMessages)

            case .loadInitialMessages:
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
                        await send(.initialMessagesLoaded(chats))
                    } catch {
                        await send(.loadingFailed(error))
                    }
                }

            case let .initialMessagesLoaded(chats):
                state.isLoading = false
                state.chats = chats
                state.hasMoreMessages = chats.count >= state.pageSize

                // CoreData의 마지막 메시지와 chatRoom의 lastChat을 비교
                if let localLastMessage = chats.last,
                   let serverLastMessage = state.chatRoom.lastChat,
                   serverLastMessage.updatedAt > localLastMessage.updatedAt {
                    // 서버에 더 최신 메시지가 있으면 fetch
                    return .send(.fetchNewMessages)
                }

                return .none

            case .loadOlderMessages:
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
                        await send(.olderMessagesLoaded(olderChats))
                    } catch {
                        await send(.loadingFailed(error))
                    }
                }

            case let .olderMessagesLoaded(olderChats):
                state.isLoadingMore = false
                if !olderChats.isEmpty {
                    state.chats = olderChats + state.chats
                    state.hasMoreMessages = olderChats.count >= state.pageSize
                } else {
                    state.hasMoreMessages = false
                }
                return .none

            case .fetchNewMessages:
                guard !state.isFetchingNew else { return .none }
                state.isFetchingNew = true
                let roomId = state.roomId
                let latestDate = state.latestMessageDate

                return .run { send in
                    do {
                        let newChats = try await fetchChatList.execute(roomId: roomId, time: latestDate)
                        await send(.newMessagesFetched(newChats))
                    } catch {
                        await send(.loadingFailed(error))
                    }
                }

            case let .newMessagesFetched(newChats):
                guard !newChats.isEmpty else {
                    state.isFetchingNew = false
                    return .none
                }

                // CoreData에 저장
                return .run { send in
                    do {
                        try await saveLocalChats.execute(newChats)
                        await send(.newMessagesSaved(newChats))
                    } catch {
                        await send(.loadingFailed(error))
                    }
                }

            case let .newMessagesSaved(newChats):
                state.isFetchingNew = false

                // 중복 제거하면서 새 메시지를 chats 배열에 추가
                let existingChatIds = Set(state.chats.map { $0.chatId })
                let uniqueNewChats = newChats.filter { !existingChatIds.contains($0.chatId) }

                if !uniqueNewChats.isEmpty {
                    state.chats.append(contentsOf: uniqueNewChats)
                }

                return .none

            case let .loadingFailed(error):
                state.isLoading = false
                state.isLoadingMore = false
                state.isFetchingNew = false
                state.uploadProgress = nil
                state.alert = AlertState {
                    TextState("오류")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState("메시지를 불러오는 중 오류가 발생했습니다.\n\(error.localizedDescription)")
                }
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
                guard !dataArray.isEmpty else { return .none }

                let roomId = state.roomId
                let chatFiles: [(Data, ChatFileType)] = dataArray.compactMap { data, mediaType in
                    guard let chatFileType = mediaType.toChatFileType else { return nil }
                    return (data, chatFileType)
                }

                guard !chatFiles.isEmpty else { return .none }

                state.uploadProgress = 0.0

                return .run { send in
                    do {
                        let filePaths = try await uploadChatFiles.execute(
                            roomId: roomId,
                            files: chatFiles
                        ) { progress in
                            Task { @MainActor in
                                send(.uploadProgressUpdated(progress))
                            }
                        }
                        
                        await send(.filesUploaded(filePaths))
                    } catch {
                        await send(.loadingFailed(error))
                    }
                }

            case let .uploadProgressUpdated(progress):
                state.uploadProgress = progress
                return .none

            case let .filesUploaded(filePaths):
                state.uploadProgress = nil
                let roomId = state.roomId

                return .run { send in
                    do {
                        let chat = try await sendMessage.execute(
                            roomId: roomId,
                            content: "Files",
                            files: filePaths
                        )
                        await send(.messageSent(chat))
                    } catch {
                        await send(.loadingFailed(error))
                    }
                }

            case let .messageSent(chat):
                return .run { send in
                    do {
                        try await saveLocalChat.execute(chat)
                        await send(.messageSavedLocally(chat))
                    } catch {
                        await send(.loadingFailed(error))
                    }
                }

            case let .messageSavedLocally(chat):
                state.chats.append(chat)
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
