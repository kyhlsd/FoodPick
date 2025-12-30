//
//  ReviewView.swift
//  Presentation
//
//  Created by 김영훈 on 12/28/25.
//

import SwiftUI
import Domain
import ComposableArchitecture

struct ReviewView: View {
    let store: StoreOf<ReviewFeature>

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store
            
            ScrollView {
                VStack(spacing: 0) {
                    // 평점 통계
                    if !store.statistics.isEmpty {
                        ReviewStatisticsSection(statistics: store.statistics)
                            .padding(.horizontal, .xLarge)
                            .padding(.vertical, .large)

                        MyDivider()
                            .padding(.horizontal, .xLarge)
                    }

                    // 리뷰 리스트
                    ReviewListSection(store: store)
                }
            }
            .navigationTitle("리뷰")
            .navigationBarTitleDisplayMode(.inline)
            .alert($store.scope(state: \.alert, action: \.alert))
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

// MARK: - Review Statistics Section
private struct ReviewStatisticsSection: View {
    let statistics: [ReviewStatisticsItem]

    private var totalCount: Int {
        statistics.reduce(0) { $0 + $1.count }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
            Text("평점 분포")
                .font(.pretendard(size: .title1, weight: .bold))
                .foregroundStyle(.custom(.gray(.gray90)))

            VStack(spacing: AppPadding.small.value) {
                ForEach(statistics.sorted { $0.rating > $1.rating }, id: \.rating) { item in
                    ReviewStatisticsRow(item: item, totalCount: totalCount)
                }
            }
        }
    }
}

// MARK: - Review Statistics Row
private struct ReviewStatisticsRow: View {
    let item: ReviewStatisticsItem
    let totalCount: Int

    private var percentage: Double {
        guard totalCount > 0 else { return 0 }
        return Double(item.count) / Double(totalCount) * 100
    }

    var body: some View {
        HStack(spacing: AppPadding.medium.value) {
            // 별점
            HStack(spacing: 2) {
                AppIcon.starFill
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(Color(hex: "#FDC020"))

                Text("\(item.rating)")
                    .font(.pretendard(size: .body2, weight: .medium))
                    .foregroundStyle(.custom(.gray(.gray90)))
            }
            .frame(width: 40, alignment: .leading)

            // 프로그레스 바
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 배경
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.custom(.gray(.gray30)))
                        .frame(height: 8)

                    // 진행률
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "#FDC020"))
                        .frame(width: geometry.size.width * CGFloat(percentage) / 100, height: 8)
                }
            }
            .frame(height: 8)

            // 개수
            Text("\(item.count)개")
                .font(.pretendard(size: .body3, weight: .medium))
                .foregroundStyle(.custom(.gray(.gray60)))
                .frame(width: 50, alignment: .trailing)
        }
    }
}

// MARK: - Review List Section
private struct ReviewListSection: View {
    let store: StoreOf<ReviewFeature>

    var body: some View {
        WithPerceptionTracking {
            let reviews = store.reviews
            let isLoadingReviews = store.isLoadingReviews
            let canLoadMore = store.canLoadMore

            LazyVStack(spacing: 0) {
                ForEach(Array(reviews.enumerated()), id: \.element.reviewId) { index, review in
                    ReviewItemRow(review: review)
                        .padding(.horizontal, .xLarge)
                        .padding(.vertical, .large)
                        .onAppear {
                            // 마지막 아이템에 도달하면 더 로드
                            if index == reviews.count - 1 && canLoadMore {
                                store.send(.loadMoreReviews)
                            }
                        }

                    if index < reviews.count - 1 {
                        MyDivider()
                            .padding(.horizontal, .xLarge)
                    }
                }

                if isLoadingReviews {
                    ProgressView()
                        .padding(.vertical, .large)
                }
            }
        }
    }
}

// MARK: - Review Item Row
private struct ReviewItemRow: View {
    let review: ReviewForListResponse

    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
            // 사용자 정보 + 평점
            HStack {
                // 프로필 이미지
                Circle()
                    .fill(.custom(.gray(.gray30)))
                    .frame(width: 40, height: 40)
                    .overlay {
                        Text(review.creator.nickname.prefix(1))
                            .font(.pretendard(size: .body1, weight: .bold))
                            .foregroundStyle(.custom(.gray(.gray60)))
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(review.creator.nickname)
                        .font(.pretendard(size: .body2, weight: .bold))
                        .foregroundStyle(.custom(.gray(.gray90)))

                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            AppIcon.starFill
                                .resizable()
                                .frame(width: 14, height: 14)
                                .foregroundStyle(
                                    index < review.rating
                                        ? Color(hex: "#FDC020")
                                        : .custom(.gray(.gray30))
                                )
                        }
                    }
                }

                Spacer()

                Text(review.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.pretendard(size: .body3, weight: .regular))
                    .foregroundStyle(.custom(.gray(.gray45)))
            }

            // 리뷰 내용
            if !review.content.isEmpty {
                Text(review.content)
                    .font(.pretendard(size: .body2, weight: .regular))
                    .foregroundStyle(.custom(.gray(.gray75)))
                    .lineSpacing(4)
            }

            // 리뷰 이미지
            if !review.reviewImageURLs.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppPadding.small.value) {
                        ForEach(review.reviewImageURLs, id: \.self) { imageURL in
                            AuthenticatedImage(imagePath: imageURL)
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
        }
    }
}
