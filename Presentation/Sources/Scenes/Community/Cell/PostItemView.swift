//
//  PostItemView.swift
//  Presentation
//
//  Created by 김영훈 on 1/3/26.
//

import SwiftUI
import Domain

struct PostItemView: View {
    let post: Post
    let isMyPost: Bool
    let onLikePostTapped: (String) -> Void
    let onMoreTapped: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
            // 작성자
            HStack(spacing: AppPadding.small.value) {
                AuthenticatedImage(imagePath: post.creator.profileImage)
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: AppPadding.tiny.value) {
                    Text(post.creator.nickname)
                        .font(.pretendard(size: .caption1, weight: .semiBold))
                        .foregroundStyle(.custom(.gray(.gray90)))

                    Text(TimeFormatter.toRelativeTimeString(from: post.createdAt))
                        .font(.pretendard(size: .caption2, weight: .medium))
                        .foregroundStyle(.custom(.gray(.gray60)))
                }

                Spacer()

                if isMyPost, let onMoreTapped {
                    Button {
                        onMoreTapped()
                    } label: {
                        AppIcon.more
                            .foregroundStyle(.custom(.gray(.gray60)))
                    }
                }
            }

            // 이미지
            if !post.files.isEmpty {
                PostMediaView(
                    images: post.files,
                    isLike: post.isLike
                ) {
                    onLikePostTapped(post.postId)
                }
            }

            // 제목 + 좋아요 + 거리
            HStack(spacing: AppPadding.tiny.value) {
                Text(post.title)
                    .font(.pretendard(size: .body1, weight: .bold))
                    .foregroundStyle(.custom(.gray(.gray90)))
                    .lineLimit(1)

                Spacer()

                // 좋아요
                HStack(spacing: 2) {
                    AppIcon.likeFill
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.custom(.brand(.brightForsythia)))

                    Text("\(post.likeCount)")
                        .font(.pretendard(size: .body1, weight: .bold))
                        .foregroundStyle(.custom(.gray(.gray90)))
                }

                // 거리
                // TODO: 거리 계산 로직 구현
                if let distance = post.restaurant.distance {
                    HStack(spacing: 2) {
                        AppIcon.distance
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.custom(.brand(.blackSprout)))
                        Text("\(String(format: "%.1f", distance))km")
                            .font(.pretendard(size: .body1, weight: .bold))
                            .foregroundStyle(.custom(.gray(.gray90)))
                    }
                }
            }

            // 내용
            Text(post.content)
                .font(.pretendard(size: .caption1, weight: .regular))
                .foregroundStyle(.custom(.gray(.gray60)))
                .lineLimit(3)
                .lineSpacing(4)

            // 가게 정보
            HStack(spacing: 0) {
                AuthenticatedImage(imagePath: post.restaurant.restaurantImageURLs.first)
                    .frame(width: 60, height: 60)

                Rectangle()
                    .fill(.custom(.brand(.deepSprout)))
                    .frame(width: 1)
                    .frame(maxHeight: .infinity)
                
                VStack(alignment: .leading, spacing: AppPadding.small.value) {
                    Text(post.restaurant.name)
                        .font(.pretendard(size: .body3, weight: .bold))
                        .foregroundStyle(.custom(.brand(.blackSprout)))

                    HStack(spacing: AppPadding.tiny.value) {
                        Text(post.restaurant.category.rawValue)
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

                            Text(String(format: "%.1f", post.restaurant.totalRating))
                                .font(.pretendard(size: .caption1, weight: .semiBold))
                                .foregroundStyle(.custom(.brand(.deepSprout)))

                            Text("(\(post.restaurant.totalReviewCount))")
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
        .padding(.all, .large)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.custom(.gray(.gray0)))
        )
        .shadow(
            color: .init(hex: "#7B7886").opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}

// MARK: - Post Media View
private struct PostMediaView: View {
    let images: [String]
    let isLike: Bool
    let onLikeTapped: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            // 왼쪽 큰 정사각형 (2/3 너비)
            let largeSize = (width - AppPadding.tiny.value) * 2 / 3
            // 오른쪽 작은 정사각형 (1/3 너비)
            let smallSize = (largeSize - AppPadding.tiny.value) / 2

            HStack(spacing: AppPadding.tiny.value) {
                // 왼쪽 큰 미디어 + 좋아요 버튼
                ZStack(alignment: .topLeading) {
                    AuthenticatedMedia(
                        mediaPath: !images.isEmpty ? images[0] : nil,
                        showsPlaybackControls: true
                    )
                    .frame(width: largeSize, height: largeSize)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    // 좋아요 버튼
                    HeartButton(isLike: isLike, nonLikeColor: .custom(.gray(.gray0))) {
                        onLikeTapped()
                    }
                    .padding(AppPadding.small.value)
                }

                VStack(spacing: AppPadding.tiny.value) {
                    AuthenticatedMedia(
                        mediaPath: images.count > 1 ? images[1] : nil,
                        showsPlaybackControls: false
                    )
                    .frame(width: smallSize, height: smallSize)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    AuthenticatedMedia(
                        mediaPath: images.count > 2 ? images[2] : nil,
                        showsPlaybackControls: false
                    )
                    .frame(width: smallSize, height: smallSize)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .aspectRatio(3 / 2, contentMode: .fit)
    }
}
