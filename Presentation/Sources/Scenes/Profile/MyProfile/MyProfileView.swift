//
//  MyProfileView.swift
//  Presentation
//
//  Created by 김영훈 on 1/6/26.
//

import SwiftUI
import Domain
import ComposableArchitecture
import PhotosUI

struct MyProfileView: View {
    let store: StoreOf<MyProfileFeature>

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store

            ZStack {
                Color.custom(.gray(.gray15))
                    .ignoresSafeArea()

                if store.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .custom(.brand(.blackSprout))))
                } else if let nickname = store.displayNickname {
                    ScrollView {
                        VStack(spacing: AppPadding.xLarge.value) {
                            // 프로필 이미지
                            ProfileImageSection(
                                profileImage: store.displayProfileImage,
                                isUploadingImage: store.isUploadingImage,
                                selectedPhotoItem: $store.selectedPhotoItem
                            )

                            // 닉네임 + 이메일
                            VStack(spacing: AppPadding.small.value) {
                                NicknameSection(
                                    nickname: nickname,
                                    isEditingNickname: store.isEditingNickname,
                                    editingNickname: $store.editingNickname,
                                    onEditTapped: {
                                        store.send(.editNicknameTapped)
                                    },
                                    onCancelEdit: {
                                        store.send(.cancelEditNickname)
                                    },
                                    onSave: {
                                        store.send(.saveNickname)
                                    }
                                )

                                // 이메일
                                if let email = store.displayEmail {
                                    Text(email)
                                        .font(.pretendard(size: .body2, weight: .regular))
                                        .foregroundStyle(.custom(.gray(.gray60)))
                                }
                            }
                            
                            // 채팅 목록 보기
                            PrimaryButton(
                                title: "채팅 목록 보기",
                                height: 40
                            ) {
                                
                            }

                            // 탭 선택
                            TabSelector(
                                selectedTab: store.selectedTab
                            ) {
                                store.send(.tabSelected($0))
                            }

                            // 그리드 표시
                            if store.selectedTab == .posts {
                                PostGridSection(posts: store.userPosts) { postId in
                                    store.send(.postTapped(postId: postId))
                                }
                            } else {
                                RestaurantGridSection(restaurants: store.likedRestaurants) { restaurantId in
                                    store.send(.restaurantTapped(restaurantId: restaurantId))
                                }
                            }

                            Spacer(minLength: 110)
                        }
                        .padding([.horizontal, .top], .xLarge)
                    }
                }
            }
            .hideKeyboardOnTap()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        store.send(.settingsButtonTapped)
                    } label: {
                        AppIcon.more
                            .font(.system(size: 20))
                            .foregroundStyle(.custom(.gray(.gray90)))
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.send(.searchButtonTapped)
                    } label: {
                        AppIcon.search
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.custom(.gray(.gray90)))
                    }
                }
            }
            .alert($store.scope(state: \.alert, action: \.alert))
            .confirmationDialog($store.scope(state: \.confirmationDialog, action: \.confirmationDialog))
            .navigationDestination(
                item: $store.scope(state: \.destination?.postDetail, action: \.destination.postDetail)
            ) { postDetailStore in
                PostDetailView(store: postDetailStore)
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.restaurantDetail, action: \.destination.restaurantDetail)
            ) { restaurantDetailStore in
                RestaurantDetailView(store: restaurantDetailStore)
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.searchUser, action: \.destination.searchUser)
            ) { searchUserStore in
                SearchUserView(store: searchUserStore)
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

// MARK: - Profile Image Section
private struct ProfileImageSection: View {
    let profileImage: String?
    let isUploadingImage: Bool
    @Binding var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                AuthenticatedImage(imagePath: profileImage)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(.custom(.gray(.gray30)), lineWidth: 2)
                    )

                if isUploadingImage {
                    ProgressView()
                        .frame(width: 120, height: 120)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }

                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Circle()
                        .fill(.custom(.brand(.blackSprout)))
                        .frame(width: 32, height: 32)
                        .overlay(
                            AppIcon.photo
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundStyle(.custom(.gray(.gray0)))
                        )
                        .overlay(
                            Circle()
                                .stroke(.custom(.gray(.gray0)), lineWidth: 2)
                        )
                }
                .disabled(isUploadingImage)
            }
        }
    }
}

// MARK: - Nickname Section
private struct NicknameSection: View {
    let nickname: String
    let isEditingNickname: Bool
    @Binding var editingNickname: String
    let onEditTapped: () -> Void
    let onCancelEdit: () -> Void
    let onSave: () -> Void

    var body: some View {
        VStack(spacing: AppPadding.medium.value) {
            if isEditingNickname {
                HStack(spacing: AppPadding.small.value) {
                    TextField("닉네임", text: $editingNickname)
                        .font(.pretendard(size: .body2, weight: .regular))
                        .foregroundStyle(.custom(.gray(.gray90)))
                        .padding(.all, AppPadding.medium.value)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.custom(.gray(.gray0)))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.custom(.gray(.gray30)), lineWidth: 1)
                        )

                    Button {
                        onCancelEdit()
                    } label: {
                        Text("취소")
                            .font(.pretendard(size: .body2, weight: .medium))
                            .foregroundStyle(.custom(.gray(.gray60)))
                    }

                    Button {
                        onSave()
                    } label: {
                        Text("저장")
                            .font(.pretendard(size: .body2, weight: .semiBold))
                            .foregroundStyle(.custom(.brand(.blackSprout)))
                    }
                    .disabled(editingNickname.isEmpty)
                }
            } else {
                HStack(spacing: AppPadding.small.value) {
                    Text(nickname)
                        .font(.pretendard(size: .title1, weight: .bold))
                        .foregroundStyle(.custom(.gray(.gray90)))

                    Button {
                        onEditTapped()
                    } label: {
                        AppIcon.pencil
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.custom(.gray(.gray60)))
                    }
                }
            }
        }
    }
}

// MARK: - Tab Selector
private struct TabSelector: View {
    let selectedTab: MyProfileFeature.State.Tab
    let onTabSelected: (MyProfileFeature.State.Tab) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MyProfileFeature.State.Tab.allCases, id: \.self) { tab in
                Button {
                    onTabSelected(tab)
                } label: {
                    VStack(spacing: AppPadding.small.value) {
                        Text(tab.rawValue)
                            .font(.pretendard(size: .body2, weight: selectedTab == tab ? .semiBold : .regular))
                            .foregroundStyle(selectedTab == tab ? .custom(.gray(.gray90)) : .custom(.gray(.gray60)))

                        if selectedTab == tab {
                            Rectangle()
                                .fill(.custom(.gray(.gray90)))
                                .frame(height: 3)
                        } else {
                            MyDivider()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 44)
    }
}

// MARK: - Post Grid Section
private struct PostGridSection: View {
    let posts: [Post]
    let onPostTapped: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
            if posts.isEmpty {
                Text("게시물이 없습니다")
                    .font(.pretendard(size: .body2, weight: .medium))
                    .foregroundStyle(.custom(.gray(.gray60)))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 4),
                        GridItem(.flexible(), spacing: 4),
                        GridItem(.flexible(), spacing: 4)
                    ],
                    spacing: 4
                ) {
                    ForEach(posts, id: \.postId) { post in
                        AuthenticatedImage(imagePath: post.files.first)
                            .aspectRatio(1, contentMode: .fit)
                            .onTapGesture {
                                onPostTapped(post.postId)
                            }
                    }
                }
            }
        }
    }
}

// MARK: - Restaurant Grid Section
private struct RestaurantGridSection: View {
    let restaurants: [Restaurant]
    let onRestaurantTapped: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
            if restaurants.isEmpty {
                Text("좋아요한 식당이 없습니다")
                    .font(.pretendard(size: .body2, weight: .medium))
                    .foregroundStyle(.custom(.gray(.gray60)))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 4),
                        GridItem(.flexible(), spacing: 4),
                        GridItem(.flexible(), spacing: 4)
                    ],
                    spacing: 4
                ) {
                    ForEach(restaurants, id: \.restaurantId) { restaurant in
                        AuthenticatedImage(imagePath: restaurant.restaurantImageURLs.first)
                            .aspectRatio(1, contentMode: .fit)
                            .onTapGesture {
                                onRestaurantTapped(restaurant.restaurantId)
                            }
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        MyProfileView(
            store: Store(
                initialState: MyProfileFeature.State()
            ) {
                MyProfileFeature()
            }
        )
    }
}
