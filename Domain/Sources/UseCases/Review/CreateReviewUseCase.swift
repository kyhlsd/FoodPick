//
//  CreateReviewUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public protocol CreateReviewUseCase: Sendable {
    func execute(restaurantId: String, request: ReviewRequest) async throws -> ReviewResponse
}

public final class CreateReviewUseCaseImpl: CreateReviewUseCase, @unchecked Sendable {
    private let reviewRepository: ReviewRepository

    public init(reviewRepository: ReviewRepository) {
        self.reviewRepository = reviewRepository
    }

    public func execute(restaurantId: String, request: ReviewRequest) async throws -> ReviewResponse {
        return try await reviewRepository.createReview(restaurantId: restaurantId, request: request)
    }
}
