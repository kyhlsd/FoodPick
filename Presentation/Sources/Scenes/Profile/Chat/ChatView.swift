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
                    
                    ScrollViewReader { proxy in
                        WithPerceptionTracking {
                            ScrollView {
                                LazyVStack(spacing: AppPadding.large.value) {
                                    ForEach(Array(store.chats.enumerated()), id: \.element.chatId) { index, chat in
                                        if shouldShowDateSeparator(at: index, chats: store.chats) {
                                            DateSeperator(date: chat.createdAt)
                                        }
                                        
                                        ChatBubbleCell(
                                            chat: chat,
                                            isMine: chat.sender.userId == store.myUserId
                                        )
                                    }
                                }
                                .padding(.horizontal, .xLarge)
                            }
                            .onAppear {
                                if let lastId = store.chats.last?.chatId {
                                    proxy.scrollTo(lastId, anchor: .bottom)
                                }
                            }
                        }
                    }
                    
                    if store.isLoading {
                        ProgressView()
                            .progressViewStyle(
                                CircularProgressViewStyle(tint: .custom(.gray(.gray15)))
                            )
                            .zIndex(1)
                    }
                }
                
                ChatInputBar(store: store)
            }
            .hideKeyboardOnTap()
            .navigationTitle(store.other?.nickname ?? "알 수 없음")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { store.send(.onAppear) }
        }
    }
    
    private func shouldShowDateSeparator(at index: Int, chats: [Chat]) -> Bool {
        if index == 0 { return true }

        let previousChat = chats[index - 1]
        let currentChat = chats[index]

        return !previousChat.createdAt.isSameDay(as: currentChat.createdAt)
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
                    Button {
                        store.send(.mediaButtonTapped)
                    } label: {
                        AppIcon.photoPlus
                            .font(.system(size: 20))
                            .foregroundStyle(.custom(.gray(.gray60)))
                    }
                    .offset(y: 4)
                    
                    TextField(
                        "메시지를 입력하세요",
                        text: $store.messageText.sending(\.textChanged),
                        axis: .vertical
                    )
                    .font(.pretendard(size: .body2, weight: .regular))
                    .padding(.horizontal, .large)
                    .padding(.vertical, .small)
                    .background(.custom(.gray(.gray15)))
                    .cornerRadius(20)
                    .lineLimit(1...6)
                    
                    Button {
                        store.send(.sendButtonTapped)
                    } label: {
                        AppIcon.paperplane
                            .font(.system(size: 20))
                            .foregroundStyle(store.isMessageEmpty
                                             ? .custom(.gray(.gray30))
                                             : .custom(.brand(.blackSprout))
                            )
                    }
                    .disabled(store.isMessageEmpty)
                    .offset(y: 4)
                }
                .padding(.horizontal, .large)
                .padding(.vertical, .small)
                .background(.custom(.gray(.gray0)))
            }
            .photosPicker(
                isPresented: $store.isShowingMediaPicker,
                selection: $selectedMedia,
                maxSelectionCount: store.maxMedia,
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
            if !dataArray.isEmpty { store.send(.mediaSelected(dataArray)) }
            selectedMedia = []
        }
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
                myUserId: myProfile.userId,
                chats: [
                    Chat(
                        chatId: "chat_001",
                        roomId: roomId,
                        content: "안녕하세요!",
                        createdAt: Date(timeIntervalSinceNow: -86400),
                        updatedAt: Date(timeIntervalSinceNow: -86400),
                        sender: otherProfile,
                        files: nil
                    ),
                    Chat(
                        chatId: "chat_002",
                        roomId: roomId,
                        content: "안녕하세요 🙂",
                        createdAt: Date(timeIntervalSinceNow: -540),
                        updatedAt: Date(timeIntervalSinceNow: -540),
                        sender: myProfile,
                        files: nil
                    ),
                    Chat(
                        chatId: "chat_003",
                        roomId: roomId,
                        content: "채팅 기능 테스트 중이신가요? 채팅 기능 테스트 중이신가요? 채팅 기능 테스트 중이신가요?",
                        createdAt: Date(timeIntervalSinceNow: -420),
                        updatedAt: Date(timeIntervalSinceNow: -420),
                        sender: otherProfile,
                        files: nil
                    ),
                    Chat(
                        chatId: "chat_004",
                        roomId: roomId,
                        content: "네! Socket.IO 연동 확인 중이에요 👍 네! Socket.IO 연동 확인 중이에요 👍 네! Socket.IO 연동 확인 중이에요 👍",
                        createdAt: Date(timeIntervalSinceNow: -360),
                        updatedAt: Date(timeIntervalSinceNow: -360),
                        sender: myProfile,
                        files: nil
                    ),
                    Chat(
                        chatId: "chat_005",
                        roomId: roomId,
                        content: "실시간 수신은 문제 없어요?",
                        createdAt: Date(timeIntervalSinceNow: -240),
                        updatedAt: Date(timeIntervalSinceNow: -240),
                        sender: otherProfile,
                        files: nil
                    ),
                    Chat(
                        chatId: "chat_006",
                        roomId: roomId,
                        content: "네, 백그라운드 복귀도 잘 됩니다!",
                        createdAt: Date(timeIntervalSinceNow: -180),
                        updatedAt: Date(timeIntervalSinceNow: -180),
                        sender: myProfile,
                        files: nil
                    ),
                    Chat(
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
                ]
            )) {
                ChatFeature()
            }
        )
    }
}
