//
//  FetchPopularSearchesUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public protocol FetchPopularSearchesUseCase: Sendable {
    func execute() async throws -> [String]
}

public final class FetchPopularSearchesUseCaseImpl: FetchPopularSearchesUseCase, @unchecked Sendable {
    private let restaurantRepository: RestaurantRepository

    public init(restaurantRepository: RestaurantRepository) {
        self.restaurantRepository = restaurantRepository
    }

    public func execute() async throws -> [String] {
        return try await restaurantRepository.fetchPopularSearches()
    }
}
