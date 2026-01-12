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
                                MediaSliderSection(
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
                                distance: store.distance
                            )

                            MyDivider()

                            // 식당 정보
                            PostRestaurantSection(restaurant: post.restaurant)

                            MyDivider()

                            // 댓글 섹션
                            PostCommentsSection(
                                comments: post.comments,
                                myUserId: store.myUserId,
                                commentText: $store.commentText.sending(\.commentTextChanged),
                                isSubmitting: store.isSubmittingComment,
                                canSubmit: store.canSubmitComment,
                                editingCommentId: store.editingCommentId,
                                editingCommentText: $store.editingCommentText.sending(\.editingCommentTextChanged),
                                canSubmitEdit: store.canSubmitEditComment,
                                selectedCommentId: store.selectedCommentId,
                                onSubmitComment: {
                                    store.send(.submitCommentTapped)
                                },
                                onCommentMoreTapped: { commentId in
                                    store.send(.commentMoreButtonTapped(commentId: commentId))
                                },
                                onEditCommentTapped: { commentId, content in
                                    store.send(.editCommentTapped(commentId: commentId, content: content))
                                },
                                onCancelEditTapped: {
                                    store.send(.cancelEditCommentTapped)
                                },
                                onSubmitEditTapped: { commentId in
                                    store.send(.submitEditCommentTapped(commentId: commentId))
                                },
                                onDeleteCommentTapped: { commentId in
                                    store.send(.deleteCommentTapped(commentId: commentId))
                                }
                            )

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
                                nonLikeColor: .custom(.gray(.gray90))
                            ) {
                                store.send(.likePostTapped)
                            }
                        }
                    }
                }
            }
            .hideKeyboardOnTap()
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

// MARK: - Media Slider Section
private struct MediaSliderSection: View {
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
                    AuthenticatedMedia(mediaPath: filePath, showsPlaybackControls: true)
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

            if let distance {
                HStack(spacing: 4) {
                    AppIcon.distance
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.custom(.brand(.blackSprout)))

                    Text(DistanceFormatter.format(distance))
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
    let myUserId: String?
    @Binding var commentText: String
    let isSubmitting: Bool
    let canSubmit: Bool
    let editingCommentId: String?
    @Binding var editingCommentText: String
    let canSubmitEdit: Bool
    let selectedCommentId: String?
    let onSubmitComment: () -> Void
    let onCommentMoreTapped: (String) -> Void
    let onEditCommentTapped: (String, String) -> Void
    let onCancelEditTapped: () -> Void
    let onSubmitEditTapped: (String) -> Void
    let onDeleteCommentTapped: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
            // 댓글 제목
            Text("댓글 (\(comments.count))")
                .font(.pretendard(size: .body2, weight: .bold))
                .foregroundStyle(.custom(.gray(.gray90)))

            // 댓글 입력
            HStack(alignment: .top, spacing: AppPadding.small.value) {
                TextField("댓글을 입력하세요", text: $commentText, axis: .vertical)
                    .font(.pretendard(size: .body2, weight: .regular))
                    .foregroundStyle(.custom(.gray(.gray90)))
                    .lineLimit(1...5)
                    .padding(.all, AppPadding.medium.value)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.custom(.gray(.gray0)))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.custom(.gray(.gray30)), lineWidth: 1)
                    )
                    .disabled(isSubmitting)

                PrimaryButton(
                    title: "등록",
                    height: 40,
                    fontSize: .body2,
                    isEnabled: canSubmit,
                    isLoading: isSubmitting
                ) {
                    onSubmitComment()
                }
                .frame(width: 60)
            }

            MyDivider()

            // 댓글 목록
            if comments.isEmpty {
                Text("작성된 댓글이 없습니다")
                    .font(.pretendard(size: .body2, weight: .medium))
                    .foregroundStyle(.custom(.gray(.gray60)))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, AppPadding.large.value)
            } else {
                VStack(alignment: .leading, spacing: AppPadding.small.value) {
                    ForEach(Array(comments.enumerated()), id: \.element.commentId) { index, comment in
                        VStack(spacing: AppPadding.small.value) {
                            CommentItemView(
                                comment: comment,
                                isMyComment: myUserId == comment.creator.userId,
                                isEditing: editingCommentId == comment.commentId,
                                editingText: $editingCommentText,
                                canSubmitEdit: canSubmitEdit
                            ) {
                                onCommentMoreTapped(comment.commentId)
                            } onCancelEditTapped: {
                                onCancelEditTapped()
                            } onSubmitEditTapped: {
                                onSubmitEditTapped(comment.commentId)
                            }

                            if index < comments.count - 1 {
                                MyDivider()
                            }
                        }
                    }
                }
                .padding(.all, AppPadding.medium.value)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.custom(.gray(.gray0)))
                )
            }
        }
        .confirmationDialog(
            "",
            isPresented: Binding(
                get: { selectedCommentId != nil },
                set: { _ in }
            ),
            titleVisibility: .hidden
        ) {
            if let commentId = selectedCommentId,
               let comment = comments.first(where: { $0.commentId == commentId }) {
                Button("댓글 수정") {
                    onEditCommentTapped(commentId, comment.content)
                }
                Button("댓글 삭제", role: .destructive) {
                    onDeleteCommentTapped(commentId)
                }
                Button("취소", role: .cancel) {}
            }
        }
    }
}

// MARK: - Comment Item View
private struct CommentItemView: View {
    let comment: Comment
    let isMyComment: Bool
    let isEditing: Bool
    @Binding var editingText: String
    let canSubmitEdit: Bool
    let onMoreTapped: () -> Void
    let onCancelEditTapped: () -> Void
    let onSubmitEditTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.small.value) {
            HStack(spacing: AppPadding.small.value) {
                AuthenticatedImage(imagePath: comment.creator.profileImage)
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: AppPadding.tiny.value) {
                    Text(comment.creator.nickname)
                        .font(.pretendard(size: .caption1, weight: .semiBold))
                        .foregroundStyle(.custom(.gray(.gray90)))

                    Text(TimeFormatter.toRelativeTimeString(from: comment.createdAt))
                        .font(.pretendard(size: .caption2, weight: .medium))
                        .foregroundStyle(.custom(.gray(.gray60)))
                }

                Spacer()

                if isMyComment {
                    if isEditing {
                        HStack(spacing: AppPadding.small.value) {
                            Button {
                                onCancelEditTapped()
                            } label: {
                                Text("취소")
                                    .font(.pretendard(size: .caption1, weight: .medium))
                                    .foregroundStyle(.custom(.gray(.gray60)))
                            }

                            Button {
                                onSubmitEditTapped()
                            } label: {
                                Text("완료")
                                    .font(.pretendard(size: .caption1, weight: .semiBold))
                                    .foregroundStyle(
                                        canSubmitEdit
                                            ? .custom(.brand(.blackSprout))
                                            : .custom(.gray(.gray45))
                                    )
                            }
                            .disabled(!canSubmitEdit)
                        }
                    } else {
                        Button {
                            onMoreTapped()
                        } label: {
                            AppIcon.more
                                .foregroundStyle(.custom(.gray(.gray60)))
                        }
                    }
                }
            }

            if isEditing {
                TextField("댓글을 입력하세요", text: $editingText, axis: .vertical)
                    .font(.pretendard(size: .body2, weight: .regular))
                    .foregroundStyle(.custom(.gray(.gray90)))
                    .lineLimit(1...5)
                    .padding(.all, AppPadding.medium.value)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.custom(.gray(.gray15)))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.custom(.gray(.gray30)), lineWidth: 1)
                    )
            } else {
                Text(comment.content)
                    .font(.pretendard(size: .body2, weight: .regular))
                    .foregroundStyle(.custom(.gray(.gray90)))
                    .lineSpacing(4)
            }
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
