//
//  FetchMyLikesUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public protocol FetchMyLikesUseCase: Sendable {
    func execute(request: BasicRequest) async throws -> ResponseListWithCursor<Restaurant>
}

public final class FetchMyLikesUseCaseImpl: FetchMyLikesUseCase, @unchecked Sendable {
    private let restaurantRepository: RestaurantRepository

    public init(restaurantRepository: RestaurantRepository) {
        self.restaurantRepository = restaurantRepository
    }

    public func execute(request: BasicRequest) async throws -> ResponseListWithCursor<Restaurant> {
        return try await restaurantRepository.fetchMyLikes(request: request)
    }
}
