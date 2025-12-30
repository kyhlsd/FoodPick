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
        var isLoadingStatistics = false
        var isLoadingReviews = false
        var nextCursor: String?
        var orderBy: ReviewOrderBy = .latest
        var isShowingOrderByMenu = false

        var canLoadMore: Bool {
            !isLoadingReviews && nextCursor != "0" && nextCursor != nil
        }

        @Presents var alert: AlertState<ReviewFeature.Alert>?
    }

    // MARK: - Action
    enum Action {
        case onAppear
        case fetchStatistics
        case statisticsLoaded([ReviewStatisticsItem])
        case statisticsFailed(Error)
        case fetchReviews
        case reviewsLoaded(ResponseListWithCursor<ReviewForListResponse>, isLoadingMore: Bool)
        case reviewsFailed(Error)
        case loadMoreReviews
        case orderByChanged(ReviewOrderBy)
        case toggleOrderByMenu
        case alert(PresentationAction<ReviewFeature.Alert>)
    }

    // MARK: - Dependencies
    @Dependency(\.fetchReviewStatistics) var fetchReviewStatisticsUseCase
    @Dependency(\.fetchReviewList) var fetchReviewListUseCase

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .send(.fetchStatistics),
                    .send(.fetchReviews)
                )

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

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    enum Alert: Sendable {}
}
