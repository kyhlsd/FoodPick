//
//  ReviewFeature.swift
//  Presentation
//
//  Created by 김영훈 on 12/28/25.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct ReviewFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        let restaurantId: String
        var statistics: [ReviewStatisticsItem] = []
        var reviews: [ReviewForListResponse] = []
        var myUserId: String?
        var isLoadingStatistics = false
        var isLoadingReviews = false
        var nextCursor: String?
        var orderBy: ReviewOrderBy = .latest
        var isShowingOrderByMenu = false
        var selectedReviewId: String?

        var canLoadMore: Bool {
            !isLoadingReviews && nextCursor != "0" && nextCursor != nil
        }

        func isMyReview(_ review: ReviewForListResponse) -> Bool {
            guard let myUserId else { return false }
            return review.creator.userId == myUserId
        }

        @Presents var alert: AlertState<ReviewFeature.Alert>?
        @Presents var destination: Destination.State?
    }

    // MARK: - Action
    enum Action {
        case onAppear
        case fetchMyProfile
        case myProfileLoaded(MyProfile)
        case myProfileFailed(Error)
        case fetchStatistics
        case statisticsLoaded([ReviewStatisticsItem])
        case statisticsFailed(Error)
        case fetchReviews
        case reviewsLoaded(ResponseListWithCursor<ReviewForListResponse>, isLoadingMore: Bool)
        case reviewsFailed(Error)
        case loadMoreReviews
        case orderByChanged(ReviewOrderBy)
        case toggleOrderByMenu
        case moreButtonTapped(reviewId: String)
        case actionSheetDismissed
        case editReviewTapped(reviewId: String)
        case deleteReviewTapped(reviewId: String)
        case alert(PresentationAction<ReviewFeature.Alert>)
        case destination(PresentationAction<Destination.Action>)
    }

    // MARK: - Dependencies
    @Dependency(\.fetchReviewStatistics) var fetchReviewStatisticsUseCase
    @Dependency(\.fetchReviewList) var fetchReviewListUseCase
    @Dependency(\.fetchMyProfile) var fetchMyProfileUseCase
    @Dependency(\.deleteReview) var deleteReviewUseCase

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .send(.fetchMyProfile),
                    .send(.fetchStatistics),
                    .send(.fetchReviews)
                )

            case .fetchMyProfile:
                return .run { send in
                    do {
                        let profile = try await fetchMyProfileUseCase.execute()
                        await send(.myProfileLoaded(profile))
                    } catch {
                        await send(.myProfileFailed(error))
                    }
                }

            case let .myProfileLoaded(profile):
                state.myUserId = profile.userId
                return .none

            case .myProfileFailed:
                // 프로필 로드 실패해도 리뷰는 볼 수 있어야 함
                return .none

            case .fetchStatistics:
                guard !state.isLoadingStatistics else { return .none }
                state.isLoadingStatistics = true

                return .run { [restaurantId = state.restaurantId] send in
                    do {
                        let statistics = try await fetchReviewStatisticsUseCase.execute(restaurantId: restaurantId)
                        await send(.statisticsLoaded(statistics))
                    } catch {
                        await send(.statisticsFailed(error))
                    }
                }

            case let .statisticsLoaded(statistics):
                state.isLoadingStatistics = false
                state.statistics = statistics
                return .none

            case let .statisticsFailed(error):
                state.isLoadingStatistics = false
                state.alert = AlertState {
                    TextState("통계 로드 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case .fetchReviews:
                guard !state.isLoadingReviews else { return .none }
                state.isLoadingReviews = true
                state.nextCursor = nil

                let request = ReviewPageRequest(
                    next: nil,
                    limit: 20,
                    orderBy: state.orderBy
                )

                return .run { [restaurantId = state.restaurantId] send in
                    do {
                        let response = try await fetchReviewListUseCase.execute(
                            restaurantId: restaurantId,
                            request: request
                        )
                        await send(.reviewsLoaded(response, isLoadingMore: false))
                    } catch {
                        await send(.reviewsFailed(error))
                    }
                }

            case let .reviewsLoaded(response, isLoadingMore):
                state.isLoadingReviews = false
                state.nextCursor = response.nextCursor

                if isLoadingMore {
                    state.reviews.append(contentsOf: response.data)
                } else {
                    state.reviews = response.data
                }
                return .none

            case let .reviewsFailed(error):
                state.isLoadingReviews = false
                state.alert = AlertState {
                    TextState("리뷰 로드 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case .loadMoreReviews:
                guard state.canLoadMore, let cursor = state.nextCursor else {
                    return .none
                }
                state.isLoadingReviews = true

                let request = ReviewPageRequest(
                    next: cursor,
                    limit: 20,
                    orderBy: state.orderBy
                )

                return .run { [restaurantId = state.restaurantId] send in
                    do {
                        let response = try await fetchReviewListUseCase.execute(
                            restaurantId: restaurantId,
                            request: request
                        )
                        await send(.reviewsLoaded(response, isLoadingMore: true))
                    } catch {
                        await send(.reviewsFailed(error))
                    }
                }

            case let .orderByChanged(orderBy):
                state.orderBy = orderBy
                state.isShowingOrderByMenu = false
                return .send(.fetchReviews)

            case .toggleOrderByMenu:
                state.isShowingOrderByMenu.toggle()
                return .none

            case let .moreButtonTapped(reviewId):
                state.selectedReviewId = reviewId
                return .none

            case .actionSheetDismissed:
                state.selectedReviewId = nil
                return .none

            case let .editReviewTapped(reviewId):
                state.selectedReviewId = nil
                state.destination = .reviewWrite(
                    ReviewWriteFeature.State(
                        mode: .edit(
                            restaurantId: state.restaurantId,
                            reviewId: reviewId
                        )
                    )
                )
                return .none

            case let .deleteReviewTapped(reviewId):
                state.selectedReviewId = nil

                return .run { [restaurantId = state.restaurantId] send in
                    do {
                        try await deleteReviewUseCase.execute(
                            restaurantId: restaurantId,
                            reviewId: reviewId
                        )
                        // 삭제 후 리뷰 목록과 통계 다시 불러오기
                        await send(.fetchStatistics)
                        await send(.fetchReviews)
                    } catch {
                        await send(.reviewsFailed(error))
                    }
                }

            case .alert, .destination:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        .ifLet(\.$destination, action: \.destination) {
            Destination.body
        }
    }

    enum Alert: Sendable {}

    // MARK: - Destination
    @Reducer
    enum Destination: Sendable {
        case reviewWrite(ReviewWriteFeature)
    }
}
