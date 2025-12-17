//
//  EditReviewUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public protocol EditReviewUseCase: Sendable {
    func execute(storeId: String, reviewId: String, request: EditReviewRequest) async throws -> ReviewResponse
}

public final class EditReviewUseCaseImpl: EditReviewUseCase, @unchecked Sendable {
    private let reviewRepository: ReviewRepository

    public init(reviewRepository: ReviewRepository) {
        self.reviewRepository = reviewRepository
    }

    public func execute(storeId: String, reviewId: String, request: EditReviewRequest) async throws -> ReviewResponse {
        return try await reviewRepository.editReview(storeId: storeId, reviewId: reviewId, request: request)
    }
}
