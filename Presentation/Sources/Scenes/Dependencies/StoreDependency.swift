//
//  StoreDependency.swift
//  Presentation
//
//  Created by 김영훈 on 12/19/25.
//

import Domain
import Data
import ComposableArchitecture

extension DependencyValues {

    // MARK: - Repository
    var storeRepository: StoreRepository {
        get { self[StoreRepositoryKey.self] }
        set { self[StoreRepositoryKey.self] = newValue }
    }

    // MARK: - UseCases
    var fetchStores: FetchStoresUseCase {
        get { self[FetchStoresKey.self] }
        set { self[FetchStoresKey.self] = newValue }
    }

    var fetchStoreInfo: FetchStoreInfoUseCase {
        get { self[FetchStoreInfoKey.self] }
        set { self[FetchStoreInfoKey.self] = newValue }
    }

    var toggleStoreLike: ToggleStoreLikeUseCase {
        get { self[ToggleStoreLikeKey.self] }
        set { self[ToggleStoreLikeKey.self] = newValue }
    }

    var searchStores: SearchStoresUseCase {
        get { self[SearchStoresKey.self] }
        set { self[SearchStoresKey.self] = newValue }
    }

    var fetchPopularStores: FetchPopularStoresUseCase {
        get { self[FetchPopularStoresKey.self] }
        set { self[FetchPopularStoresKey.self] = newValue }
    }

    var fetchPopularSearches: FetchPopularSearchesUseCase {
        get { self[FetchPopularSearchesKey.self] }
        set { self[FetchPopularSearchesKey.self] = newValue }
    }

    var fetchMyLikedStores: FetchMyLikesUseCase {
        get { self[FetchMyLikedStoresKey.self] }
        set { self[FetchMyLikedStoresKey.self] = newValue }
    }

    var fetchUserReviews: FetchReviewsUseCase {
        get { self[FetchUserReviewsKey.self] }
        set { self[FetchUserReviewsKey.self] = newValue }
    }
}

// MARK: - Keys
private enum StoreRepositoryKey: DependencyKey {
    static let liveValue: StoreRepository = DefaultStoreRepositoryImpl()
}

private enum FetchStoresKey: DependencyKey {
    static let liveValue: FetchStoresUseCase = {
        @Dependency(\.storeRepository) var storeRepository
        return FetchStoresUseCaseImpl(storeRepository: storeRepository)
    }()
}

private enum FetchStoreInfoKey: DependencyKey {
    static let liveValue: FetchStoreInfoUseCase = {
        @Dependency(\.storeRepository) var storeRepository
        return FetchStoreInfoUseCaseImpl(storeRepository: storeRepository)
    }()
}

private enum ToggleStoreLikeKey: DependencyKey {
    static let liveValue: ToggleStoreLikeUseCase = {
        @Dependency(\.storeRepository) var storeRepository
        return ToggleStoreLikeUseCaseImpl(storeRepository: storeRepository)
    }()
}

private enum SearchStoresKey: DependencyKey {
    static let liveValue: SearchStoresUseCase = {
        @Dependency(\.storeRepository) var storeRepository
        return SearchStoresUseCaseImpl(storeRepository: storeRepository)
    }()
}

private enum FetchPopularStoresKey: DependencyKey {
    static let liveValue: FetchPopularStoresUseCase = {
        @Dependency(\.storeRepository) var storeRepository
        return FetchPopularStoresUseCaseImpl(storeRepository: storeRepository)
    }()
}

private enum FetchPopularSearchesKey: DependencyKey {
    static let liveValue: FetchPopularSearchesUseCase = {
        @Dependency(\.storeRepository) var storeRepository
        return FetchPopularSearchesUseCaseImpl(storeRepository: storeRepository)
    }()
}

private enum FetchMyLikedStoresKey: DependencyKey {
    static let liveValue: FetchMyLikesUseCase = {
        @Dependency(\.storeRepository) var storeRepository
        return FetchMyLikesUseCaseImpl(storeRepository: storeRepository)
    }()
}

private enum FetchUserReviewsKey: DependencyKey {
    static let liveValue: FetchReviewsUseCase = {
        @Dependency(\.storeRepository) var storeRepository
        return FetchReviewsUseCaseImpl(storeRepository: storeRepository)
    }()
}
