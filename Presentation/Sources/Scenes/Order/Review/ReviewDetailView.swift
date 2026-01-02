//
//  ReviewDetailView.swift
//  Presentation
//
//  Created by 김영훈 on 1/2/26.
//

import SwiftUI
import Domain
import ComposableArchitecture

struct ReviewDetailView: View {
    let store: StoreOf<ReviewDetailFeature>

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store

            ZStack {
                Color.custom(.gray(.gray0))
                    .ignoresSafeArea()

                if store.isLoading {
                    ProgressView()
                } else if let review = store.review {
                    ScrollView {
                        VStack(spacing: AppPadding.large.value) {
                            ReviewDetailContent(review: review)

                            ActionButtonsSection(
                                onEdit: { store.send(.editReviewTapped) },
                                onDelete: { store.send(.deleteReviewTapped) }
                            )
                        }
                        .padding(.all, .xLarge)
                    }
                }
            }
            .background(Color.custom(.gray(.gray0)))
            .navigationTitle("리뷰 상세")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(
                item: $store.scope(state: \.destination?.reviewWrite, action: \.destination.reviewWrite)
            ) { store in
                ReviewWriteView(store: store)
            }
            .alert($store.scope(state: \.alert, action: \.alert))
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

// MARK: - Action Buttons Section
private struct ActionButtonsSection: View {
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: AppPadding.medium.value) {
            Button {
                onDelete()
            } label: {
                Text("삭제")
                    .font(.pretendard(size: .body2, weight: .semiBold))
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.red, lineWidth: 1)
                    )
            }

            Button {
                onEdit()
            } label: {
                Text("수정")
                    .font(.pretendard(size: .body2, weight: .semiBold))
                    .foregroundStyle(.custom(.gray(.gray0)))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.custom(.brand(.blackSprout)))
                    )
            }
        }
    }
}

// MARK: - Review Detail Content
private struct ReviewDetailContent: View {
    let review: ReviewResponse

    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.large.value) {
            // 평점
            HStack(spacing: AppPadding.small.value) {
                ForEach(0..<5) { index in
                    AppIcon.starFill
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.custom(
                            index < review.rating
                                ? .brand(.brightForsythia)
                                : .gray(.gray30)
                        ))
                }

                Spacer()

                Text(TimeFormatter.toKoreanDateTimeFormat(from: review.createdAt))
                    .font(.pretendard(size: .body3, weight: .regular))
                    .foregroundStyle(.custom(.gray(.gray60)))
            }

            MyDivider()

            // 리뷰 내용
            if !review.content.isEmpty {
                Text(review.content)
                    .font(.pretendard(size: .body2, weight: .regular))
                    .foregroundStyle(.custom(.gray(.gray90)))
                    .lineSpacing(6)
            }

            // 리뷰 이미지
            if !review.reviewImageURLs.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppPadding.medium.value) {
                        ForEach(review.reviewImageURLs, id: \.self) { imageURL in
                            AuthenticatedImage(imagePath: imageURL)
                                .frame(width: 150, height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }

            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ReviewDetailView(
            store: Store(
                initialState: ReviewDetailFeature.State(
                    restaurantId: "1",
                    reviewId: "1",
                    review: ReviewResponse(
                        reviewId: "1",
                        content: "정말 맛있었어요! 친구들과 함께 갔는데 모두 만족했습니다. 다음에도 또 올게요.",
                        rating: 5,
                        restaurant: Restaurant(
                            restaurantId: "1",
                            category: .korean,
                            name: "테스트 식당",
                            close: "22:00",
                            restaurantImageURLs: [],
                            isPicchelin: false,
                            isPick: false,
                            pickCount: 0,
                            hashTags: [],
                            totalRating: 4.5,
                            totalOrderCount: 100,
                            totalReviewCount: 50,
                            geolocation: Geolocation(longitude: 0, latitude: 0),
                            distance: nil,
                            createdAt: Date(),
                            updatedAt: Date()
                        ),
                        reviewImageURLs: [],
                        orderMenuList: ["김치찌개", "제육볶음"],
                        creator: Profile(
                            userId: "user1",
                            nickname: "테스터",
                            profileImage: nil
                        ),
                        createdAt: Date(),
                        updatedAt: Date()
                    )
                )
            ) {
                ReviewDetailFeature()
            }
        )
    }
}
