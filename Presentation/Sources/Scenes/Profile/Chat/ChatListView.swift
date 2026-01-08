//
//  ChatListView.swift
//  Presentation
//
//  Created by 김영훈 on 1/6/26.
//

import SwiftUI
import Domain
import ComposableArchitecture

struct ChatListView: View {
    let store: StoreOf<ChatListFeature>

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store
            
            ZStack {
                Color.custom(.gray(.gray15))
                    .ignoresSafeArea()

                if store.isLoading && store.chatRooms.isEmpty {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .custom(.brand(.blackSprout))))
                } else if store.chatRooms.isEmpty {
                    EmptyStateView()
                } else {
                    ScrollView {
                        VStack(spacing: AppPadding.medium.value) {
                            MySearchBar(text: $store.searchText.sending(\.searchTextChanged)) { }
                            
                            if store.isSearchEmpty {
                                Text("검색 결과가 없습니다.")
                                    .font(.pretendard(size: .body1, weight: .medium))
                                    .foregroundStyle(.custom(.gray(.gray60)))
                                    .padding(.top, 100)
                            } else {
                                LazyVStack(spacing: 0) {
                                    let filtered = store.filteredChatRooms
                                    ForEach(filtered, id: \.roomId) { chatRoom in
                                        ChatRoomCell(
                                            chatRoom: chatRoom,
                                            store: store
                                        )
                                        
                                        if chatRoom.roomId != filtered.last?.roomId {
                                            MyDivider()
                                                .padding(.leading, 60)
                                        }
                                    }
                                    
                                    Spacer(minLength: 110)
                                }
                            }
                        }
                        .padding(.horizontal, .xLarge)
                    }
                    .refreshable {
                        await store.send(.fetchChatRooms).finish()
                    }
                }
            }
            .hideKeyboardOnTap()
            .navigationTitle("채팅 목록")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { store.send(.onAppear) }
            .navigationDestination(
                item: $store.scope(state: \.destination?.chat, action: \.destination.chat)
            ) { chatStore in
                ChatView(store: chatStore)
            }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

// MARK: - Chat Room Cell
private struct ChatRoomCell: View {
    let chatRoom: ChatRoom
    @Perception.Bindable var store: StoreOf<ChatListFeature>
    
    private var otherParticipant: Profile? {
        chatRoom.participants.first { $0.userId != store.myUserId }
    }
    
    var body: some View {
        WithPerceptionTracking {
            Button {
                store.send(.chatRoomTapped(chatRoom))
            } label: {
                HStack(spacing: AppPadding.medium.value) {
                    // 프로필 이미지
                    if let participant = otherParticipant {
                        AuthenticatedImage(imagePath: participant.profileImage)
                            .frame(width: 56, height: 56)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(.custom(.gray(.gray30)), lineWidth: 1)
                            )
                    } else {
                        Circle()
                            .fill(.custom(.gray(.gray30)))
                            .frame(width: 56, height: 56)
                    }
                    
                    // 채팅 정보
                    VStack(alignment: .leading, spacing: AppPadding.tiny.value) {
                        HStack {
                            Text(otherParticipant?.nickname ?? "알 수 없음")
                                .font(.pretendard(size: .body2, weight: .semiBold))
                                .foregroundStyle(.custom(.gray(.gray90)))
                            
                            Spacer()
                            
                            if let lastChat = chatRoom.lastChat {
                                Text(TimeFormatter.toRelativeTimeString(from: lastChat.createdAt))
                                    .font(.pretendard(size: .body3, weight: .regular))
                                    .foregroundStyle(.custom(.gray(.gray60)))
                            }
                        }
                        
                        if let lastChat = chatRoom.lastChat {
                            Text(lastChat.content)
                                .font(.pretendard(size: .body3, weight: .regular))
                                .foregroundStyle(.custom(.gray(.gray60)))
                                .lineLimit(1)
                        } else {
                            Text("메시지가 없습니다")
                                .font(.pretendard(size: .body3, weight: .regular))
                                .foregroundStyle(.custom(.gray(.gray45)))
                        }
                    }
                }
                .padding(.vertical, .large)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Empty State View
private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: AppPadding.medium.value) {
            AppIcon.chat
                .font(.system(size: 60))
                .foregroundStyle(.custom(.gray(.gray45)))

            VStack(spacing: AppPadding.small.value) {
                Text("채팅 내역이 없습니다")
                    .font(.pretendard(size: .body1, weight: .semiBold))
                    .foregroundStyle(.custom(.gray(.gray60)))

                Text("다른 사용자와 대화를 시작해보세요")
                    .font(.pretendard(size: .body3, weight: .regular))
                    .foregroundStyle(.custom(.gray(.gray45)))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ChatListView(
            store: Store(initialState: ChatListFeature.State(
                myUserId: "my_user_id",
                chatRooms: [
                    ChatRoom(
                        roomId: "room_01",
                        createdAt: Date().addingTimeInterval(-86400 * 3), // 3일 전
                        updatedAt: Date().addingTimeInterval(-3600),     // 1시간 전
                        participants: [
                            Profile(userId: "user_01", nickname: "김철수", profileImage: nil)
                        ],
                        lastChat: Chat(
                            chatId: "chat_01",
                            roomId: "room_01",
                            content: "오늘 점심 뭐 드실 건가요? 맛있는데 찾았어요!",
                            createdAt: Date().addingTimeInterval(-3600),
                            updatedAt: Date().addingTimeInterval(-3600),
                            sender: Profile(userId: "user_01", nickname: "김철수", profileImage: nil),
                            files: nil
                        )
                    ),
                    ChatRoom(
                        roomId: "room_02",
                        createdAt: Date().addingTimeInterval(-86400 * 5),
                        updatedAt: Date().addingTimeInterval(-86400),    // 어제
                        participants: [
                            Profile(userId: "user_02", nickname: "이영희", profileImage: "https://example.com/image.png")
                        ],
                        lastChat: Chat(
                            chatId: "chat_02",
                            roomId: "room_02",
                            content: "네 알겠습니다. 내일 뵙겠습니다!",
                            createdAt: Date().addingTimeInterval(-86400),
                            updatedAt: Date().addingTimeInterval(-86400),
                            sender: Profile(userId: "user_02", nickname: "이영희", profileImage: "https://example.com/image.png"),
                            files: nil
                        )
                    ),
                    ChatRoom(
                        roomId: "room_03",
                        createdAt: Date().addingTimeInterval(-86400 * 10),
                        updatedAt: Date().addingTimeInterval(-86400 * 4), // 4일 전
                        participants: [
                            Profile(userId: "user_03", nickname: "Swift마스터", profileImage: nil)
                        ],
                        lastChat: Chat(
                            chatId: "chat_03",
                            roomId: "room_03",
                            content: "TCA 구조 잡는게 생각보다 까다롭네요 ㅎㅎ",
                            createdAt: Date().addingTimeInterval(-86400 * 4),
                            updatedAt: Date().addingTimeInterval(-86400 * 4),
                            sender: Profile(userId: "user_03", nickname: "Swift마스터", profileImage: nil),
                            files: nil
                        )
                    ),
                    ChatRoom(
                        roomId: "room_04",
                        createdAt: Date().addingTimeInterval(-60),
                        updatedAt: Date().addingTimeInterval(-30),      // 방금 전
                        participants: [
                            Profile(userId: "user_04", nickname: "개발자K", profileImage: nil)
                        ],
                        lastChat: Chat(
                            chatId: "chat_04",
                            roomId: "room_04",
                            content: "방금 사진 한 장 보냈습니다!",
                            createdAt: Date().addingTimeInterval(-30),
                            updatedAt: Date().addingTimeInterval(-30),
                            sender: Profile(userId: "user_04", nickname: "개발자K", profileImage: nil),
                            files: ["image_url_01"]
                        )
                    )
                ])) {
                    ChatListFeature()
                }
        )
    }
}
