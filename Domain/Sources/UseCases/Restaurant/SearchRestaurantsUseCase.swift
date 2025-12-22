//
//  SearchRestaurantsUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public protocol SearchRestaurantsUseCase: Sendable {
    func execute(name: String) async throws -> [Restaurant]
}

public final class SearchRestaurantsUseCaseImpl: SearchRestaurantsUseCase, @unchecked Sendable {
    private let restaurantRepository: RestaurantRepository

    public init(restaurantRepository: RestaurantRepository) {
        self.restaurantRepository = restaurantRepository
    }

    public func execute(name: String) async throws -> [Restaurant] {
        return try await restaurantRepository.searchRestaurants(name: name)
    }
}
