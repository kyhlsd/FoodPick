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

            ZStack {
                Color.custom(.gray(.gray0))
                    .ignoresSafeArea()
                
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
                        
                        // 정렬 드롭다운
                        ReviewSortSection(
                            orderBy: store.orderBy,
                            isShowingOrderByMenu: store.isShowingOrderByMenu,
                            onToggleOrderByMenu: { store.send(.toggleOrderByMenu) },
                            onOrderByChanged: { orderBy in store.send(.orderByChanged(orderBy)) }
                        )
                        
                        // 리뷰 리스트
                        ReviewListSection(store: store)
                    }
                }
                .dropdownBackdrop(isOpen: store.isShowingOrderByMenu
                ) { store.send(.toggleOrderByMenu) }
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

// MARK: - Review Sort Section
private struct ReviewSortSection: View {
    let orderBy: ReviewOrderBy
    let isShowingOrderByMenu: Bool
    let onToggleOrderByMenu: () -> Void
    let onOrderByChanged: (ReviewOrderBy) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()

                DropdownMenu(
                    options: ReviewOrderBy.allCases,
                    selectedOption: orderBy,
                    isOpen: isShowingOrderByMenu,
                    onToggle: onToggleOrderByMenu,
                    onSelect: onOrderByChanged
                ) { option in
                    HStack(spacing: AppPadding.tiny.value) {
                        AppIcon.list
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(.custom(.gray(.gray60)))

                        Text(option.rawValue)
                            .font(.pretendard(size: .body3, weight: .regular))
                            .foregroundStyle(.custom(.gray(.gray60)))
                    }
                }
            }
            .padding(.horizontal, .xLarge)
            .padding(.vertical, .medium)

            MyDivider()
                .padding(.horizontal, .xLarge)
        }
        .dropdownHost(isOpen: isShowingOrderByMenu, onDismiss: onToggleOrderByMenu)
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
                    .foregroundStyle(.custom(.brand(.brightForsythia)))

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
                        .fill(.custom(.brand(.brightForsythia)))
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

            if reviews.isEmpty && !isLoadingReviews {
                VStack(spacing: AppPadding.medium.value) {
                    Text("아직 리뷰가 없습니다")
                        .font(.pretendard(size: .body2, weight: .medium))
                        .foregroundStyle(.custom(.gray(.gray60)))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
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
                    HStack(spacing: 4) {
                        Text(review.creator.nickname)
                            .font(.pretendard(size: .body2, weight: .bold))
                            .foregroundStyle(.custom(.gray(.gray90)))

                        Text(
                            "평점 \(String(format: "%.1f", review.userTotalRating)) · " +
                            "리뷰 \(review.userTotalReviewCount)개"
                        )
                        .font(.pretendard(size: .body3, weight: .regular))
                        .foregroundStyle(.custom(.gray(.gray60)))
                    }

                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            AppIcon.starFill
                                .resizable()
                                .frame(width: 14, height: 14)
                                .foregroundStyle(.custom(
                                    index < review.rating
                                        ? .brand(.brightForsythia)
                                        : .gray(.gray30)
                                ))
                        }
                    }
                }

                Spacer()

                Text(TimeFormatter.toRelativeTimeString(from: review.createdAt))
                    .font(.pretendard(size: .body3, weight: .regular))
                    .foregroundStyle(.custom(.gray(.gray45)))
            }

            // 주문 메뉴
            if !review.orderMenuList.isEmpty {
                HStack(spacing: AppPadding.small.value) {
                    ForEach(review.orderMenuList, id: \.self) { menu in
                        Text(menu)
                            .font(.pretendard(size: .body3, weight: .regular))
                            .foregroundStyle(.custom(.gray(.gray60)))
                            .padding(.horizontal, AppPadding.small.value)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(.custom(.gray(.gray15)))
                            )
                    }
                }
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

// MARK: - Preview
#Preview {
    NavigationStack {
        ReviewView(
            store: Store(
                initialState: ReviewFeature.State(
                    restaurantId: "1",
                    statistics: [
                        ReviewStatisticsItem(rating: 5, count: 45),
                        ReviewStatisticsItem(rating: 4, count: 30),
                        ReviewStatisticsItem(rating: 3, count: 15),
                        ReviewStatisticsItem(rating: 2, count: 8),
                        ReviewStatisticsItem(rating: 1, count: 2)
                    ],
                    reviews: [
                        ReviewForListResponse(
                            reviewId: "1",
                            content: "정말 맛있어요! 매일 먹어도 질리지 않을 것 같아요. 사장님도 친절하시고 분위기도 좋습니다.",
                            rating: 5,
                            reviewImageURLs: [],
                            orderMenuList: ["아메리카노", "카페라떼"],
                            creator: Profile(
                                userId: "user1",
                                nickname: "김푸드",
                                profileImage: nil
                            ),
                            userTotalReviewCount: 24,
                            userTotalRating: 4.5,
                            createdAt: Date().addingTimeInterval(-1800), // 30분 전
                            updatedAt: Date().addingTimeInterval(-1800)
                        ),
                        ReviewForListResponse(
                            reviewId: "2",
                            content: "맛있었어요!",
                            rating: 4,
                            reviewImageURLs: [],
                            orderMenuList: ["치킨", "감자튀김"],
                            creator: Profile(
                                userId: "user2",
                                nickname: "박맛집",
                                profileImage: nil
                            ),
                            userTotalReviewCount: 10,
                            userTotalRating: 4.2,
                            createdAt: Date().addingTimeInterval(-18000), // 5시간 전
                            updatedAt: Date().addingTimeInterval(-18000)
                        ),
                        ReviewForListResponse(
                            reviewId: "3",
                            content: "분위기는 좋은데 가격이 조금 비싼 것 같아요. 그래도 한 번쯤 가볼 만해요.",
                            rating: 3,
                            reviewImageURLs: [],
                            orderMenuList: ["파스타", "샐러드", "와인"],
                            creator: Profile(
                                userId: "user3",
                                nickname: "이리뷰",
                                profileImage: nil
                            ),
                            userTotalReviewCount: 50,
                            userTotalRating: 3.8,
                            createdAt: Date().addingTimeInterval(-100000), // 하루 전
                            updatedAt: Date().addingTimeInterval(-100000)
                        ),
                        ReviewForListResponse(
                            reviewId: "4",
                            content: "완전 강추합니다!",
                            rating: 5,
                            reviewImageURLs: [],
                            orderMenuList: ["피자", "콜라"],
                            creator: Profile(
                                userId: "user4",
                                nickname: "최맛집",
                                profileImage: nil
                            ),
                            userTotalReviewCount: 35,
                            userTotalRating: 4.7,
                            createdAt: Date().addingTimeInterval(-86400 * 5), // 5일 전 (2025년 형식)
                            updatedAt: Date().addingTimeInterval(-86400 * 5)
                        )
                    ],
                    isLoadingStatistics: false,
                    isLoadingReviews: false,
                    nextCursor: "0"
                )
            ) {
                ReviewFeature()
            }
        )
    }
}
