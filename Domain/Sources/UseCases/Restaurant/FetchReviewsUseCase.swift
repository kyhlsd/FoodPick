//
//  FetchReviewsUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public protocol FetchReviewsUseCase: Sendable {
    func execute(userId: String, request: BasicRequest) async throws -> ResponseListWithCursor<ReviewForRestaurant>
}

public final class FetchReviewsUseCaseImpl: FetchReviewsUseCase, @unchecked Sendable {
    private let restaurantRepository: RestaurantRepository

    public init(restaurantRepository: RestaurantRepository) {
        self.restaurantRepository = restaurantRepository
    }

    public func execute(userId: String, request: BasicRequest) async throws -> ResponseListWithCursor<ReviewForRestaurant> {
        return try await restaurantRepository.fetchReviews(userId: userId, request: request)
    }
}
