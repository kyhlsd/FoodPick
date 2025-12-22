//
//  FetchPopularRestaurantsUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public protocol FetchPopularRestaurantsUseCase: Sendable {
    func execute(category: RestaurantCategory?) async throws -> [Restaurant]
}

public final class FetchPopularRestaurantsUseCaseImpl: FetchPopularRestaurantsUseCase, @unchecked Sendable {
    private let restaurantRepository: RestaurantRepository

    public init(restaurantRepository: RestaurantRepository) {
        self.restaurantRepository = restaurantRepository
    }

    public func execute(category: RestaurantCategory?) async throws -> [Restaurant] {
        return try await restaurantRepository.fetchPopularRestaurants(category: category)
    }
}
