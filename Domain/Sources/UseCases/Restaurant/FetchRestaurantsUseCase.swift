//
//  FetchRestaurantsUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public protocol FetchRestaurantsUseCase: Sendable {
    func execute(request: RestaurantByLocationRequest) async throws -> ResponseListWithCursor<Restaurant>
}

public final class FetchRestaurantsUseCaseImpl: FetchRestaurantsUseCase, @unchecked Sendable {
    private let restaurantRepository: RestaurantRepository

    public init(restaurantRepository: RestaurantRepository) {
        self.restaurantRepository = restaurantRepository
    }

    public func execute(request: RestaurantByLocationRequest) async throws -> ResponseListWithCursor<Restaurant> {
        return try await restaurantRepository.fetchRestaurants(request: request)
    }
}
