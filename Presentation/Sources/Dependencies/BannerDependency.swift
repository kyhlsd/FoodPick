//
//  BannerDependency.swift
//  Presentation
//
//  Created by 김영훈 on 12/19/25.
//

import Domain
import Data
import ComposableArchitecture

extension DependencyValues {

    // MARK: - Repository
    var bannerRepository: BannerRepository {
        get { self[BannerRepositoryKey.self] }
        set { self[BannerRepositoryKey.self] = newValue }
    }

    // MARK: - UseCases
    var fetchMainBanners: FetchMainBannersUseCase {
        get { self[FetchMainBannersKey.self] }
        set { self[FetchMainBannersKey.self] = newValue }
    }
}

// MARK: - Keys
private enum BannerRepositoryKey: DependencyKey {
    static let liveValue: BannerRepository = DefaultBannerRepositoryImpl()
}

private enum FetchMainBannersKey: DependencyKey {
    static let liveValue: FetchMainBannersUseCase = {
        @Dependency(\.bannerRepository) var bannerRepository
        return FetchMainBannersUseCaseImpl(bannerRepository: bannerRepository)
    }()
}
