//
//  FetchReviewListUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public protocol FetchReviewListUseCase: Sendable {
    func execute(restaurantId: String, request: ReviewPageRequest) async throws -> ResponseListWithCursor<ReviewForListResponse>
}

public final class FetchReviewListUseCaseImpl: FetchReviewListUseCase, @unchecked Sendable {
    private let reviewRepository: ReviewRepository

    public init(reviewRepository: ReviewRepository) {
        self.reviewRepository = reviewRepository
    }

    public func execute(restaurantId: String, request: ReviewPageRequest) async throws -> ResponseListWithCursor<ReviewForListResponse> {
        return try await reviewRepository.fetchReviewList(restaurantId: restaurantId, request: request)
    }
}
