//
//  MessageSendingFeature.swift
//  Presentation
//
//  Created by 김영훈 on 1/8/26.
//

import Foundation
import Domain
import Core
import ComposableArchitecture

@Reducer
struct MessageSendingFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable, Equatable {
        var messageText = ""
        var isShowingMediaPicker = false
        var uploadProgress: Double?
        let roomId: String
        let maxMedia = 5

        var isMessageEmpty: Bool {
            messageText
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty
        }
    }

    // MARK: - Action
    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case sendButtonTapped
        case mediaButtonTapped
        case mediaSelected([(Data, MediaType)])
        case uploadProgressUpdated(Double)
        case filesUploaded([String])
        case messageSent(Chat)
        case sendingFailed(Error)
    }

    // MARK: - Dependencies
    @Dependency(\.uploadChatFiles) var uploadChatFiles
    @Dependency(\.sendMessage) var sendMessage

    // MARK: - Body
    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .sendButtonTapped:
                guard !state.isMessageEmpty else { return .none }

                let roomId = state.roomId
                let content = state.messageText.trimmingCharacters(in: .whitespacesAndNewlines)

                return .run { send in
                    do {
                        let chat = try await sendMessage.execute(
                            roomId: roomId,
                            content: content,
                            files: nil
                        )
                        await send(.messageSent(chat))
                    } catch {
                        await send(.sendingFailed(error))
                    }
                }

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
                        await send(.sendingFailed(error))
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
                        await send(.sendingFailed(error))
                    }
                }

            case .messageSent:
                state.messageText = ""
                return .none

            case .sendingFailed:
                state.uploadProgress = nil
                return .none

            case .binding:
                return .none
            }
        }
    }
}
