//
//  ReviewDetailFeature.swift
//  Presentation
//
//  Created by 김영훈 on 1/2/26.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct ReviewDetailFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        let restaurantId: String
        let reviewId: String
        var review: ReviewResponse?
        var isLoading = false

        @Presents var alert: AlertState<ReviewDetailFeature.Alert>?
        @Presents var destination: Destination.State?
    }

    // MARK: - Action
    enum Action {
        case onAppear
        case fetchReview
        case reviewLoaded(ReviewResponse)
        case reviewFailed(Error)
        case editReviewTapped
        case deleteReviewTapped
        case alert(PresentationAction<ReviewDetailFeature.Alert>)
        case destination(PresentationAction<Destination.Action>)
    }

    // MARK: - Dependencies
    @Dependency(\.fetchReviewDetail) var fetchReviewDetailUseCase
    @Dependency(\.deleteReview) var deleteReviewUseCase
    @Dependency(\.dismiss) var dismiss

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchReview)

            case .fetchReview:
                guard !state.isLoading else { return .none }
                state.isLoading = true

                return .run { [restaurantId = state.restaurantId, reviewId = state.reviewId] send in
                    do {
                        let review = try await fetchReviewDetailUseCase.execute(
                            restaurantId: restaurantId,
                            reviewId: reviewId
                        )
                        await send(.reviewLoaded(review))
                    } catch {
                        await send(.reviewFailed(error))
                    }
                }

            case let .reviewLoaded(review):
                state.isLoading = false
                state.review = review
                return .none

            case let .reviewFailed(error):
                state.isLoading = false
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

            case .editReviewTapped:
                guard let review = state.review else { return .none }
                state.destination = .reviewWrite(
                    ReviewWriteFeature.State(
                        mode: .edit(
                            restaurantId: state.restaurantId,
                            reviewId: review.reviewId
                        )
                    )
                )
                return .none

            case .deleteReviewTapped:
                guard let review = state.review else { return .none }

                return .run { [restaurantId = state.restaurantId, reviewId = review.reviewId] send in
                    do {
                        try await deleteReviewUseCase.execute(
                            restaurantId: restaurantId,
                            reviewId: reviewId
                        )
                        await dismiss()
                    } catch {
                        await send(.reviewFailed(error))
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
