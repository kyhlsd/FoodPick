//
//  ToggleRestaurantLikeUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public protocol ToggleRestaurantLikeUseCase: Sendable {
    func execute(id: String, like: Bool) async throws -> LikeStatus
}

public final class ToggleRestaurantLikeUseCaseImpl: ToggleRestaurantLikeUseCase, @unchecked Sendable {
    private let restaurantRepository: RestaurantRepository

    public init(restaurantRepository: RestaurantRepository) {
        self.restaurantRepository = restaurantRepository
    }

    public func execute(id: String, like: Bool) async throws -> LikeStatus {
        return try await restaurantRepository.toggleRestaurantLike(id: id, like: like)
    }
}
