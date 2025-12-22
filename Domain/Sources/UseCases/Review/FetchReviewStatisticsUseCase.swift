//
//  FetchReviewStatisticsUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public protocol FetchReviewStatisticsUseCase: Sendable {
    func execute(restaurantId: String) async throws -> [ReviewStatisticsItem]
}

public final class FetchReviewStatisticsUseCaseImpl: FetchReviewStatisticsUseCase, @unchecked Sendable {
    private let reviewRepository: ReviewRepository

    public init(reviewRepository: ReviewRepository) {
        self.reviewRepository = reviewRepository
    }

    public func execute(restaurantId: String) async throws -> [ReviewStatisticsItem] {
        return try await reviewRepository.fetchStatistics(restaurantId: restaurantId)
    }
}
