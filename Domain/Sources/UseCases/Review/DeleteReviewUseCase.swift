//
//  DeleteReviewUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public protocol DeleteReviewUseCase: Sendable {
    func execute(storeId: String, reviewId: String) async throws
}

public final class DeleteReviewUseCaseImpl: DeleteReviewUseCase, @unchecked Sendable {
    private let reviewRepository: ReviewRepository

    public init(reviewRepository: ReviewRepository) {
        self.reviewRepository = reviewRepository
    }

    public func execute(storeId: String, reviewId: String) async throws {
        try await reviewRepository.deleteReview(storeId: storeId, reviewId: reviewId)
    }
}
