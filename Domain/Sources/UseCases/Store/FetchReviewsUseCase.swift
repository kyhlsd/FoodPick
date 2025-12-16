//
//  FetchReviewsUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public protocol FetchReviewsUseCase: Sendable {
    func execute(userId: String, request: BasicRequest) async throws -> ResponseListWithCursor<Review>
}

public final class FetchReviewsUseCaseImpl: FetchReviewsUseCase, @unchecked Sendable {
    private let storeRepository: StoreRepository

    public init(storeRepository: StoreRepository) {
        self.storeRepository = storeRepository
    }

    public func execute(userId: String, request: BasicRequest) async throws -> ResponseListWithCursor<Review> {
        return try await storeRepository.fetchReviews(userId: userId, request: request)
    }
}
