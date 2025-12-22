//
//  FetchRestaurantInfoUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public protocol FetchRestaurantInfoUseCase: Sendable {
    func execute(id: String) async throws -> RestaurantDetail
}

public final class FetchRestaurantInfoUseCaseImpl: FetchRestaurantInfoUseCase, @unchecked Sendable {
    private let restaurantRepository: RestaurantRepository

    public init(restaurantRepository: RestaurantRepository) {
        self.restaurantRepository = restaurantRepository
    }

    public func execute(id: String) async throws -> RestaurantDetail {
        return try await restaurantRepository.fetchRestaurantInfo(id: id)
    }
}
