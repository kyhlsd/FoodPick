//
//  SearchUserView.swift
//  Presentation
//
//  Created by 김영훈 on 1/6/26.
//

import SwiftUI
import Domain
import ComposableArchitecture

struct SearchUserView: View {
    let store: StoreOf<SearchUserFeature>

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store

            let lastId = store.filteredUsers.last?.userId
            
            VStack(spacing: 0) {
                // 서치바
                MySearchBar(
                    text: $store.searchText.sending(\.searchTextChanged),
                    placeholder: "닉네임 검색"
                ) {
                    store.send(.search)
                }
                .padding(.horizontal, .xLarge)
                .padding(.vertical, .medium)

                if store.isLoading {
                    Spacer()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .custom(.brand(.blackSprout))))
                    
                    Spacer()
                } else if store.searchText.isEmpty {
                    Spacer()
                    
                    Text("닉네임을 입력하세요")
                        .font(.pretendard(size: .body2, weight: .medium))
                        .foregroundStyle(.custom(.gray(.gray60)))
                    
                    Spacer()
                } else if store.filteredUsers.isEmpty {
                    Spacer()
                    
                    Text("검색 결과가 없습니다")
                        .font(.pretendard(size: .body2, weight: .medium))
                        .foregroundStyle(.custom(.gray(.gray60)))
                    
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(store.filteredUsers, id: \.userId) { user in
                                UserListItem(user: user) {
                                    store.send(.userTapped(user))
                                }

                                if user.userId != lastId {
                                    MyDivider()
                                        .padding(.horizontal, .xLarge)
                                }
                            }
                        }
                    }
                }
            }
            .background(.custom(.gray(.gray15)))
            .hideKeyboardOnTap()
            .navigationTitle("유저 검색")
            .navigationBarTitleDisplayMode(.inline)
            .alert($store.scope(state: \.alert, action: \.alert))
            .navigationDestination(
                item: $store.scope(state: \.destination?.otherProfile, action: \.destination.otherProfile)
            ) { otherProfileStore in
                OtherProfileView(store: otherProfileStore)
            }
        }
    }
}

// MARK: - User List Item
private struct UserListItem: View {
    let user: Profile
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: AppPadding.medium.value) {
                // 프로필 이미지
                AuthenticatedImage(imagePath: user.profileImage)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(.custom(.gray(.gray30)), lineWidth: 1)
                    )

                // 닉네임
                Text(user.nickname)
                    .font(.pretendard(size: .body2, weight: .medium))
                    .foregroundStyle(.custom(.gray(.gray90)))

                Spacer()

                // 화살표
                AppIcon.chevron
                    .resizable()
                    .rotationEffect(.degrees(180))
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.custom(.gray(.gray60)))
            }
            .padding(.horizontal, .xLarge)
            .padding(.vertical, .medium)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        SearchUserView(
            store: Store(
                initialState: SearchUserFeature.State(myUserId: "testUser")
            ) {
                SearchUserFeature()
            }
        )
    }
}
