//
//  RestaurantDependency.swift
//  Presentation
//
//  Created by 김영훈 on 12/19/25.
//

import Domain
import Data
import ComposableArchitecture

extension DependencyValues {

    // MARK: - Repository
    var restaurantRepository: RestaurantRepository {
        get { self[RestaurantRepositoryKey.self] }
        set { self[RestaurantRepositoryKey.self] = newValue }
    }

    // MARK: - UseCases
    var fetchRestaurants: FetchRestaurantsUseCase {
        get { self[FetchRestaurantsKey.self] }
        set { self[FetchRestaurantsKey.self] = newValue }
    }

    var fetchRestaurantInfo: FetchRestaurantInfoUseCase {
        get { self[FetchRestaurantInfoKey.self] }
        set { self[FetchRestaurantInfoKey.self] = newValue }
    }

    var toggleRestaurantLike: ToggleRestaurantLikeUseCase {
        get { self[ToggleRestaurantLikeKey.self] }
        set { self[ToggleRestaurantLikeKey.self] = newValue }
    }

    var searchRestaurants: SearchRestaurantsUseCase {
        get { self[SearchRestaurantsKey.self] }
        set { self[SearchRestaurantsKey.self] = newValue }
    }

    var fetchPopularRestaurants: FetchPopularRestaurantsUseCase {
        get { self[FetchPopularRestaurantsKey.self] }
        set { self[FetchPopularRestaurantsKey.self] = newValue }
    }

    var fetchPopularSearches: FetchPopularSearchesUseCase {
        get { self[FetchPopularSearchesKey.self] }
        set { self[FetchPopularSearchesKey.self] = newValue }
    }

    var fetchMyLikedRestaurants: FetchMyLikesUseCase {
        get { self[FetchMyLikedRestaurantsKey.self] }
        set { self[FetchMyLikedRestaurantsKey.self] = newValue }
    }

    var fetchUserReviews: FetchReviewsUseCase {
        get { self[FetchUserReviewsKey.self] }
        set { self[FetchUserReviewsKey.self] = newValue }
    }
}

// MARK: - Keys
private enum RestaurantRepositoryKey: DependencyKey {
    static let liveValue: RestaurantRepository = DefaultRestaurantRepositoryImpl()
}

private enum FetchRestaurantsKey: DependencyKey {
    static let liveValue: FetchRestaurantsUseCase = {
        @Dependency(\.restaurantRepository) var restaurantRepository
        return FetchRestaurantsUseCaseImpl(restaurantRepository: restaurantRepository)
    }()
}

private enum FetchRestaurantInfoKey: DependencyKey {
    static let liveValue: FetchRestaurantInfoUseCase = {
        @Dependency(\.restaurantRepository) var restaurantRepository
        return FetchRestaurantInfoUseCaseImpl(restaurantRepository: restaurantRepository)
    }()
}

private enum ToggleRestaurantLikeKey: DependencyKey {
    static let liveValue: ToggleRestaurantLikeUseCase = {
        @Dependency(\.restaurantRepository) var restaurantRepository
        return ToggleRestaurantLikeUseCaseImpl(restaurantRepository: restaurantRepository)
    }()
}

private enum SearchRestaurantsKey: DependencyKey {
    static let liveValue: SearchRestaurantsUseCase = {
        @Dependency(\.restaurantRepository) var restaurantRepository
        return SearchRestaurantsUseCaseImpl(restaurantRepository: restaurantRepository)
    }()
}

private enum FetchPopularRestaurantsKey: DependencyKey {
    static let liveValue: FetchPopularRestaurantsUseCase = {
        @Dependency(\.restaurantRepository) var restaurantRepository
        return FetchPopularRestaurantsUseCaseImpl(restaurantRepository: restaurantRepository)
    }()
}

private enum FetchPopularSearchesKey: DependencyKey {
    static let liveValue: FetchPopularSearchesUseCase = {
        @Dependency(\.restaurantRepository) var restaurantRepository
        return FetchPopularSearchesUseCaseImpl(restaurantRepository: restaurantRepository)
    }()
}

private enum FetchMyLikedRestaurantsKey: DependencyKey {
    static let liveValue: FetchMyLikesUseCase = {
        @Dependency(\.restaurantRepository) var restaurantRepository
        return FetchMyLikesUseCaseImpl(restaurantRepository: restaurantRepository)
    }()
}

private enum FetchUserReviewsKey: DependencyKey {
    static let liveValue: FetchReviewsUseCase = {
        @Dependency(\.restaurantRepository) var restaurantRepository
        return FetchReviewsUseCaseImpl(restaurantRepository: restaurantRepository)
    }()
}
