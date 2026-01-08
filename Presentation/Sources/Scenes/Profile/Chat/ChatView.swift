//
//  ChatView.swift
//  Presentation
//
//  Created by 김영훈 on 1/6/26.
//

import SwiftUI
import PhotosUI
import Domain
import Core
import ComposableArchitecture

struct ChatView: View {
    let store: StoreOf<ChatFeature>

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store

            VStack(spacing: 0) {
                ZStack {
                    Color.custom(.brand(.brightSprout))
                        .ignoresSafeArea()

                    ChatMessagesListView(store: store)

                    ChatLoadingOverlay(
                        isLoading: store.messageLoading.isLoading,
                        uploadProgress: store.messageSending.uploadProgress
                    )
                }

                ChatInputBar(store: store)
            }
            .hideKeyboardOnTap()
            .navigationTitle(store.other?.nickname ?? "알 수 없음")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { store.send(.onAppear) }
            .onDisappear { store.send(.onDisappear) }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

// MARK: - Chat Messages List View
private struct ChatMessagesListView: View {
    @Perception.Bindable var store: StoreOf<ChatFeature>

    var body: some View {
        ScrollViewReader { proxy in
            WithPerceptionTracking {
                ScrollView {
                    LazyVStack(spacing: AppPadding.large.value) {
                        if store.messageLoading.isLoadingMore {
                            PaginationLoadingIndicator()
                        }
                        
                        ForEach(Array(store.messageLoading.chats.enumerated()), id: \.element.chatId) { index, chat in
                            WithPerceptionTracking {
                                if shouldShowDateSeparator(at: index) {
                                    DateSeperator(date: chat.createdAt)
                                }
                                
                                ChatBubbleCell(
                                    chat: chat,
                                    isMine: chat.sender.userId == store.myUserId
                                )
                                .id(chat.chatId)
                                .onAppear {
                                    if index == 0
                                        && store.messageLoading.hasMoreMessages
                                        && !store.messageLoading.isLoadingMore {
                                        store.send(.messageLoading(.loadOlder))
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, .xLarge)
                }
                .onAppear {
                    if let lastId = store.messageLoading.chats.last?.chatId {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
        }
    }

    private func shouldShowDateSeparator(at index: Int) -> Bool {
        guard index > 0 else { return true }
        let chats = store.messageLoading.chats
        guard index < chats.count else { return false }
        
        let previousChat = chats[index - 1]
        let currentChat = chats[index]

        return !previousChat.createdAt.isSameDay(as: currentChat.createdAt)
    }
}

// MARK: - Pagination Loading Indicator
private struct PaginationLoadingIndicator: View {
    var body: some View {
        HStack {
            Spacer()
            ProgressView()
                .progressViewStyle(
                    CircularProgressViewStyle(tint: .custom(.gray(.gray60)))
                )
            Spacer()
        }
        .padding(.vertical, .medium)
    }
}

// MARK: - Chat Loading Overlay
private struct ChatLoadingOverlay: View {
    let isLoading: Bool
    let uploadProgress: Double?

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle(tint: .custom(.gray(.gray15)))
                    )
                    .zIndex(1)
            }

            if let progress = uploadProgress {
                UploadProgressView(progress: progress)
                    .zIndex(2)
            }
        }
    }
}

// MARK: - Upload Progress View
private struct UploadProgressView: View {
    let progress: Double

    var body: some View {
        VStack(spacing: AppPadding.medium.value) {
            ProgressView(value: progress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .custom(.brand(.blackSprout))))
                .frame(width: 200)

            Text("\(Int(progress * 100))%")
                .font(.pretendard(size: .body2, weight: .medium))
                .foregroundStyle(.custom(.gray(.gray75)))
        }
        .padding(.all, .large)
        .background(.custom(.gray(.gray0)))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Chat Bubble Cell
private struct ChatBubbleCell: View {
    let chat: Chat
    let isMine: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: AppPadding.small.value) {
            if !isMine {
                AuthenticatedImage(imagePath: chat.sender.profileImage)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.custom(.gray(.gray30)), lineWidth: 1))
            } else {
                Spacer()
            }
            
            VStack(alignment: isMine ? .trailing : .leading, spacing: AppPadding.tiny.value) {
                if !isMine {
                    Text(chat.sender.nickname)
                        .font(.pretendard(size: .body3, weight: .medium))
                        .foregroundStyle(.custom(.gray(.gray75)))
                }
                
                HStack(alignment: .bottom, spacing: 6) {
                    if isMine {
                        timeText
                    }
                    
                    Group {
                        if let files = chat.files, !files.isEmpty {
                            MultipleAuthenticatedMedia(files: files)
                        } else {
                            Text(chat.content)
                                .font(.pretendard(size: .body2, weight: .medium))
                                .foregroundStyle(isMine
                                                 ? .custom(.gray(.gray0))
                                                 : .custom(.gray(.gray90))
                                )
                        }
                    }
                    .padding(.horizontal, .medium)
                    .padding(.vertical, .small)
                    .background(isMine
                                ? .custom(.brand(.blackSprout))
                                : .custom(.gray(.gray0))
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 8)
                    )
                    
                    if !isMine {
                        timeText
                    }
                }
            }
            
            if !isMine {
                Spacer()
            }
        }
    }
    
    private var timeText: some View {
        Text(TimeFormatter.toKoreanAMPMFormat(from: chat.createdAt))
            .font(.pretendard(size: .caption1, weight: .regular))
            .foregroundStyle(.custom(.gray(.gray60)))
            .padding(.bottom, 2)
    }
}

// MARK: - Date Seperator
private struct DateSeperator: View {
    let date: Date
    
    var body: some View {
        HStack(spacing: AppPadding.small.value) {
            MyDivider(color: .custom(.gray(.gray45)))
            
            Text(TimeFormatter.toKoreanDateOnlyFormat(from: date))
                .font(.pretendard(size: .caption2, weight: .regular))
                .foregroundStyle(.custom(.gray(.gray60)))
            
            MyDivider(color: .custom(.gray(.gray45)))
        }
    }
}

private extension Date {
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }
}

// MARK: - Chat Input Bar
private struct ChatInputBar: View {
    @Perception.Bindable var store: StoreOf<ChatFeature>
    @State private var selectedMedia: [PhotosPickerItem] = []

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                MyDivider()

                HStack(alignment: .top, spacing: AppPadding.medium.value) {
                    MediaButton {
                        store.send(.messageSending(.mediaButtonTapped))
                    }
                    
                    MessageTextField(text: $store.messageSending.messageText)
                    
                    SendButton(
                        isDisabled: store.messageSending.isMessageEmpty
                    ) {
                        store.send(.messageSending(.sendButtonTapped))
                    }
                }
                .padding(.horizontal, .large)
                .padding(.vertical, .small)
                .background(.custom(.gray(.gray0)))
            }
            .photosPicker(
                isPresented: $store.messageSending.isShowingMediaPicker,
                selection: $selectedMedia,
                maxSelectionCount: store.messageSending.maxMedia,
                matching: .any(of: [.images, .videos])
            )
            .onChange(of: selectedMedia) {
                handleMediaSelection($0)
            }
        }
    }

    private func handleMediaSelection(_ items: [PhotosPickerItem]) {
        Task {
            var dataArray: [(Data, MediaType)] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data),
                       let jpegData = uiImage.jpegData(compressionQuality: 0.8) {
                        dataArray.append((jpegData, .jpeg))
                    } else if item.supportedContentTypes.contains(where: { $0.conforms(to: .movie) }) {
                        dataArray.append((data, .mp4))
                    }
                }
            }
            if !dataArray.isEmpty {
                store.send(.messageSending(.mediaSelected(dataArray)))
            }
            selectedMedia = []
        }
    }
}

// MARK: - Media Button
private struct MediaButton: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            AppIcon.photoPlus
                .font(.system(size: 20))
                .foregroundStyle(.custom(.gray(.gray60)))
        }
        .offset(y: 4)
    }
}

// MARK: - Message TextField
private struct MessageTextField: View {
    @Binding var text: String

    var body: some View {
        TextField(
            "메시지를 입력하세요",
            text: $text,
            axis: .vertical
        )
        .font(.pretendard(size: .body2, weight: .regular))
        .padding(.horizontal, .large)
        .padding(.vertical, .small)
        .background(.custom(.gray(.gray15)))
        .cornerRadius(20)
        .lineLimit(1...6)
    }
}

// MARK: - Send Button
private struct SendButton: View {
    let isDisabled: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            AppIcon.paperplane
                .font(.system(size: 20))
                .foregroundStyle(buttonColor)
        }
        .disabled(isDisabled)
        .offset(y: 4)
    }

    private var buttonColor: Color {
        isDisabled
            ? .custom(.gray(.gray30))
            : .custom(.brand(.blackSprout))
    }
}

#Preview {
    let roomId = "room_id"
    let myProfile = Profile(
        userId: "user_me",
        nickname: "김학도",
        profileImage: nil
    )
    let otherProfile = Profile(
        userId: "user_other",
        nickname: "김민교",
        profileImage: nil
    )
    
    NavigationStack {
        ChatView(
            store: Store(initialState: ChatFeature.State(
                chatRoom: ChatRoom(
                    roomId: "room_001",
                    createdAt: Date(timeIntervalSinceNow: -86400),
                    updatedAt: Date(timeIntervalSinceNow: -86400),
                    participants: [
                        myProfile,
                        otherProfile
                    ],
                    lastChat: Chat(
                        chatId: "chat_007",
                        roomId: roomId,
                        content: "Media",
                        createdAt: Date(timeIntervalSinceNow: -180),
                        updatedAt: Date(timeIntervalSinceNow: -180),
                        sender: myProfile,
                        files: [
                            "file_1",
                            "file_2",
                            "file_3"
                        ]
                    )
                ),
                myUserId: myProfile.userId
            )) {
                ChatFeature()
            }
        )
    }
}
