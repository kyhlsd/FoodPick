//
//  PostDetailView.swift
//  Presentation
//
//  Created by 김영훈 on 1/6/26.
//

import SwiftUI
import Domain
import ComposableArchitecture

struct PostDetailView: View {
    let store: StoreOf<PostDetailFeature>

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store

            let selectedPostId = store.selectedPostId

            ZStack {
                if store.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .custom(.brand(.blackSprout))))
                } else if let post = store.postDetail {
                    ScrollView {
                        VStack(alignment: .leading, spacing: AppPadding.xLarge.value) {
                            // 작성자 정보
                            PostHeaderSection(
                                creator: post.creator,
                                createdAt: post.createdAt,
                                isMyPost: store.isMyPost
                            ) {
                                store.send(.moreButtonTapped)
                            }

                            // 이미지/영상 슬라이더
                            if !post.files.isEmpty {
                                ImageSliderSection(
                                    files: post.files,
                                    currentIndex: store.currentImageIndex
                                ) {
                                    store.send(.imageIndexChanged($0))
                                }
                            }

                            // 내용
                            Text(post.content)
                                .font(.pretendard(size: .body2, weight: .regular))
                                .foregroundStyle(.custom(.gray(.gray90)))
                                .lineSpacing(6)

                            // 좋아요 카운트 및 거리
                            PostMetricsSection(
                                likeCount: post.likeCount,
                                distance: post.restaurant.distance
                            )

                            MyDivider()

                            // 식당 정보
                            PostRestaurantSection(restaurant: post.restaurant)

                            // 댓글 섹션
                            if !post.comments.isEmpty {
                                MyDivider()

                                PostCommentsSection(comments: post.comments)
                            }

                            Spacer(minLength: 110)
                        }
                        .padding(.horizontal, .xLarge)
                        .padding(.top, .xLarge)
                    }
                    .background(.custom(.gray(.gray15)))
                    .navigationTitle(post.title)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            HeartButton(
                                isLike: post.isLike,
                                nonLikeColor: .custom(.gray(.gray60))
                            ) {
                                store.send(.likePostTapped)
                            }
                        }
                    }
                }
            }
            .confirmationDialog(
                "",
                isPresented: Binding(
                    get: { selectedPostId != nil },
                    set: { if !$0 { store.send(.actionSheetDismissed) } }
                ),
                titleVisibility: .hidden
            ) {
                Button("포스트 수정") {
                    store.send(.editPostTapped)
                }
                Button("포스트 삭제", role: .destructive) {
                    store.send(.deletePostTapped)
                }
                Button("취소", role: .cancel) {
                    store.send(.actionSheetDismissed)
                }
            }
            .alert($store.scope(state: \.alert, action: \.alert))
            .navigationDestination(
                item: $store.scope(state: \.destination?.postWrite, action: \.destination.postWrite)
            ) { store in
                PostWriteView(store: store)
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

// MARK: - Image Slider Section
private struct ImageSliderSection: View {
    let files: [String]
    let currentIndex: Int
    let onIndexChanged: (Int) -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: Binding(
                get: { currentIndex },
                set: { onIndexChanged($0) }
            )) {
                ForEach(Array(files.enumerated()), id: \.offset) { index, filePath in
                    AuthenticatedImage(imagePath: filePath)
                        .frame(maxWidth: .infinity)
                        .frame(height: 240)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 240)

            // Page Control
            if files.count > 1 {
                HStack(spacing: AppPadding.small.value) {
                    ForEach(0..<files.count, id: \.self) { index in
                        if currentIndex == index {
                            Circle()
                                .fill(.custom(.gray(.gray0)))
                                .frame(width: 8, height: 8)
                        } else {
                            Circle()
                                .fill(.custom(.gray(.gray45)))
                                .frame(width: 4, height: 4)
                        }
                    }
                }
                .padding(.bottom, AppPadding.medium.value)
            }
        }
        .background(.custom(.gray(.gray0)))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Post Header Section
private struct PostHeaderSection: View {
    let creator: Profile
    let createdAt: Date
    let isMyPost: Bool
    let onMoreTapped: () -> Void

    var body: some View {
        HStack(spacing: AppPadding.small.value) {
            AuthenticatedImage(imagePath: creator.profileImage)
                .frame(width: 40, height: 40)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: AppPadding.tiny.value) {
                Text(creator.nickname)
                    .font(.pretendard(size: .body2, weight: .bold))
                    .foregroundStyle(.custom(.gray(.gray90)))

                Text(TimeFormatter.toRelativeTimeString(from: createdAt))
                    .font(.pretendard(size: .caption1, weight: .medium))
                    .foregroundStyle(.custom(.gray(.gray60)))
            }

            Spacer()

            if isMyPost {
                Button {
                    onMoreTapped()
                } label: {
                    AppIcon.more
                        .foregroundStyle(.custom(.gray(.gray60)))
                }
            }
        }
    }
}

// MARK: - Post Metrics Section
private struct PostMetricsSection: View {
    let likeCount: Int
    let distance: Float?

    var body: some View {
        HStack(spacing: AppPadding.medium.value) {
            Spacer()
            
            HStack(spacing: 4) {
                AppIcon.likeFill
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.custom(.brand(.brightForsythia)))

                Text("\(likeCount)")
                    .font(.pretendard(size: .body2, weight: .bold))
                    .foregroundStyle(.custom(.gray(.gray90)))
            }

            if let distance = distance {
                HStack(spacing: 4) {
                    AppIcon.distance
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.custom(.brand(.blackSprout)))

                    Text("\(String(format: "%.1f", distance))km")
                        .font(.pretendard(size: .body2, weight: .bold))
                        .foregroundStyle(.custom(.gray(.gray90)))
                }
            }
        }
    }
}

// MARK: - Post Restaurant Section
private struct PostRestaurantSection: View {
    let restaurant: Restaurant

    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.small.value) {
            Text("식당 정보")
                .font(.pretendard(size: .body2, weight: .bold))
                .foregroundStyle(.custom(.gray(.gray90)))

            HStack(spacing: 0) {
                AuthenticatedImage(imagePath: restaurant.restaurantImageURLs.first)
                    .frame(width: 60, height: 60)

                Rectangle()
                    .fill(.custom(.brand(.deepSprout)))
                    .frame(width: 1)
                    .frame(maxHeight: .infinity)

                VStack(alignment: .leading, spacing: AppPadding.small.value) {
                    Text(restaurant.name)
                        .font(.pretendard(size: .body3, weight: .bold))
                        .foregroundStyle(.custom(.brand(.blackSprout)))

                    HStack(spacing: AppPadding.tiny.value) {
                        Text(restaurant.category.rawValue)
                            .font(.pretendard(size: .caption1, weight: .semiBold))
                            .foregroundStyle(.custom(.brand(.deepSprout)))

                        Text("·")
                            .font(.pretendard(size: .caption1, weight: .semiBold))
                            .foregroundStyle(.custom(.brand(.deepSprout)))

                        HStack(spacing: 2) {
                            AppIcon.starFill
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundStyle(.custom(.brand(.brightForsythia)))

                            Text(String(format: "%.1f", restaurant.totalRating))
                                .font(.pretendard(size: .caption1, weight: .semiBold))
                                .foregroundStyle(.custom(.brand(.deepSprout)))

                            Text("(\(restaurant.totalReviewCount))")
                                .font(.pretendard(size: .caption1, weight: .regular))
                                .foregroundStyle(.custom(.brand(.deepSprout)))
                        }
                    }
                }
                .padding(.leading, .small)

                Spacer()
            }
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.custom(.brand(.brightSprout)))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.custom(.brand(.deepSprout)), lineWidth: 1)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 8)
            )
        }
    }
}

// MARK: - Post Comments Section
private struct PostCommentsSection: View {
    let comments: [Comment]

    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
            Text("댓글 \(comments.count)")
                .font(.pretendard(size: .body1, weight: .bold))
                .foregroundStyle(.custom(.gray(.gray90)))

            // TODO: 댓글 리스트 표시
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        PostDetailView(
            store: Store(
                initialState: PostDetailFeature.State(postId: "1", myUserId: nil)
            ) {
                PostDetailFeature()
            }
        )
    }
}
