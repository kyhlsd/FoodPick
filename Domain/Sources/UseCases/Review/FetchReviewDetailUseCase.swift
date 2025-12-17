//
//  FetchReviewDetailUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public protocol FetchReviewDetailUseCase: Sendable {
    func execute(storeId: String, reviewId: String) async throws -> ReviewResponse
}

public final class FetchReviewDetailUseCaseImpl: FetchReviewDetailUseCase, @unchecked Sendable {
    private let reviewRepository: ReviewRepository

    public init(reviewRepository: ReviewRepository) {
        self.reviewRepository = reviewRepository
    }

    public func execute(storeId: String, reviewId: String) async throws -> ReviewResponse {
        return try await reviewRepository.fetchReviewDetail(storeId: storeId, reviewId: reviewId)
    }
}
