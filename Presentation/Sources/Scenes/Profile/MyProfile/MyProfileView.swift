//
//  MyProfileView.swift
//  Presentation
//
//  Created by 김영훈 on 1/6/26.
//

import SwiftUI
import PhotosUI
import Domain
import Core
import ComposableArchitecture

struct MyProfileView: View {
    let store: StoreOf<MyProfileFeature>
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store
            
            ZStack {
                Color.custom(.gray(.gray15))
                    .ignoresSafeArea()

                if store.profileEditor.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .custom(.brand(.blackSprout))))
                } else if store.profileEditor.displayNickname != nil {
                    ScrollView {
                        VStack(spacing: AppPadding.xLarge.value) {
                            ProfileHeaderSection(
                                store: store,
                                selectedPhotoItem: $selectedPhotoItem
                            )

                            PrimaryButton(
                                title: "채팅 목록 보기",
                                height: 40,
                                fontSize: .body1
                            ) {
                                store.send(.chatListButtonTapped)
                            }

                            ContentTabSection(store: store)

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
                        store.send(.settings(.settingsButtonTapped))
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
            .onChange(of: selectedPhotoItem) {
                handlePhotoSelection($0)
            }
            .alert($store.scope(state: \.profileEditor.alert, action: \.profileEditor.alert))
            .alert($store.scope(state: \.content.alert, action: \.content.alert))
            .alert($store.scope(state: \.settings.alert, action: \.settings.alert))
            .confirmationDialog($store.scope(state: \.settings.confirmationDialog,
                                             action: \.settings.confirmationDialog))
            .profileDestinations(store: store)
            .onAppear {
                store.send(.onAppear)
            }
        }
    }

    private func handlePhotoSelection(_ item: PhotosPickerItem?) {
        guard let item else { return }

        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let compressedData = ImageCompressor.compress(data, maxSizeInMB: 1.0) {
                store.send(.profileEditor(.photoDataSelected(compressedData)))
            }
            selectedPhotoItem = nil
        }
    }
}

// MARK: - Modifiers
private struct ProfileDestinationModifier: ViewModifier {
    @Perception.Bindable var store: StoreOf<MyProfileFeature>

    func body(content: Content) -> some View {
        WithPerceptionTracking {
            content
                .modifier(PostDetailDestination(store: store))
                .modifier(RestaurantDetailDestination(store: store))
                .modifier(SearchUserDestination(store: store))
                .modifier(ChatListDestination(store: store))
                .modifier(ChatDestination(store: store))
        }
    }
}

private struct PostDetailDestination: ViewModifier {
    @Perception.Bindable var store: StoreOf<MyProfileFeature>

    func body(content: Content) -> some View {
        WithPerceptionTracking {
            content
                .navigationDestination(
                    item: $store.scope(state: \.destination?.postDetail, action: \.destination.postDetail)
                ) { postDetailStore in
                    PostDetailView(store: postDetailStore)
                }
        }
    }
}

private struct RestaurantDetailDestination: ViewModifier {
    @Perception.Bindable var store: StoreOf<MyProfileFeature>

    func body(content: Content) -> some View {
        WithPerceptionTracking {
            content
                .navigationDestination(
                    item: $store.scope(state: \.destination?.restaurantDetail, action: \.destination.restaurantDetail)
                ) { restaurantDetailStore in
                    RestaurantDetailView(store: restaurantDetailStore)
                }
        }
    }
}

private struct SearchUserDestination: ViewModifier {
    @Perception.Bindable var store: StoreOf<MyProfileFeature>

    func body(content: Content) -> some View {
        WithPerceptionTracking {
            content
                .navigationDestination(
                    item: $store.scope(state: \.destination?.searchUser, action: \.destination.searchUser)
                ) { searchUserStore in
                    SearchUserView(store: searchUserStore)
                }
        }
    }
}

private struct ChatListDestination: ViewModifier {
    @Perception.Bindable var store: StoreOf<MyProfileFeature>

    func body(content: Content) -> some View {
        WithPerceptionTracking {
            content
                .navigationDestination(
                    item: $store.scope(state: \.destination?.chatList, action: \.destination.chatList)
                ) { chatListStore in
                    ChatListView(store: chatListStore)
                }
        }
    }
}

private struct ChatDestination: ViewModifier {
    @Perception.Bindable var store: StoreOf<MyProfileFeature>

    func body(content: Content) -> some View {
        WithPerceptionTracking {
            content
                .navigationDestination(
                    item: $store.scope(state: \.destination?.chat, action: \.destination.chat)
                ) { chatStore in
                    ChatView(store: chatStore)
                }
        }
    }
}

private extension View {
    func profileDestinations(store: StoreOf<MyProfileFeature>) -> some View {
        modifier(ProfileDestinationModifier(store: store))
    }
}

// MARK: - Profile Header Section
private struct ProfileHeaderSection: View {
    @Perception.Bindable var store: StoreOf<MyProfileFeature>
    @Binding var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: AppPadding.xLarge.value) {
                // 프로필 이미지
                ProfileImageSection(
                    profileImage: store.profileEditor.displayProfileImage,
                    isUploadingImage: store.profileEditor.isUploadingImage,
                    selectedPhotoItem: $selectedPhotoItem
                )

                // 닉네임 + 이메일
                VStack(spacing: AppPadding.small.value) {
                    // 닉네임 (scope를 사용하여 바인딩)
                    NicknameEditorView(
                        store: store.scope(state: \.profileEditor, action: \.profileEditor)
                    )

                    // 이메일
                    if let email = store.profileEditor.displayEmail {
                        Text(email)
                            .font(.pretendard(size: .body2, weight: .regular))
                            .foregroundStyle(.custom(.gray(.gray60)))
                    }
                }
            }
        }
    }
}

// MARK: - Nickname Editor View
private struct NicknameEditorView: View {
    @Perception.Bindable var store: StoreOf<ProfileEditorFeature>

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: AppPadding.medium.value) {
                if store.isEditingNickname {
                    HStack(spacing: AppPadding.small.value) {
                        TextField("닉네임", text: $store.editingNickname)
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
                            store.send(.cancelEditNickname)
                        } label: {
                            Text("취소")
                                .font(.pretendard(size: .body2, weight: .medium))
                                .foregroundStyle(.custom(.gray(.gray60)))
                        }
                        
                        Button {
                            store.send(.saveNickname)
                        } label: {
                            Text("저장")
                                .font(.pretendard(size: .body2, weight: .semiBold))
                                .foregroundStyle(.custom(.brand(.blackSprout)))
                        }
                        .disabled(store.editingNickname.isEmpty)
                    }
                } else {
                    HStack(spacing: AppPadding.small.value) {
                        Text(store.displayNickname ?? "")
                            .font(.pretendard(size: .title1, weight: .bold))
                            .foregroundStyle(.custom(.gray(.gray90)))
                        
                        Button {
                            store.send(.editNicknameTapped)
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
}

// MARK: - Content Tab Section
private struct ContentTabSection: View {
    @Perception.Bindable var store: StoreOf<MyProfileFeature>

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: AppPadding.medium.value) {
                // 탭 선택
                TabSelector(
                    selectedTab: store.content.selectedTab
                ) {
                    store.send(.content(.tabSelected($0)))
                }

                // 그리드 표시
                if store.content.selectedTab == .posts {
                    PostGridSection(posts: store.content.userPosts) { postId in
                        store.send(.postTapped(postId: postId))
                    }
                } else {
                    RestaurantGridSection(restaurants: store.content.likedRestaurants) { restaurantId in
                        store.send(.restaurantTapped(restaurantId: restaurantId))
                    }
                }
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

// MARK: - Tab Selector
private struct TabSelector: View {
    let selectedTab: ProfileContentFeature.State.Tab
    let onTabSelected: (ProfileContentFeature.State.Tab) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ProfileContentFeature.State.Tab.allCases, id: \.self) { tab in
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
                        AuthenticatedMedia(mediaPath: post.files.first, showsPlaybackControls: false)
                            .aspectRatio(1, contentMode: .fit)
                            .allowsHitTesting(false)  // 비디오 플레이어의 터치 비활성화
                            .overlay(
                                Color.clear
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        onPostTapped(post.postId)
                                    }
                            )
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
