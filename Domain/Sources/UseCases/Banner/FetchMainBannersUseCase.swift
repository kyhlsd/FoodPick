//
//  FetchMainBannersUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public protocol FetchMainBannersUseCase: Sendable {
    func execute() async throws -> [Banner]
}

public final class FetchMainBannersUseCaseImpl: FetchMainBannersUseCase, @unchecked Sendable {
    private let bannerRepository: BannerRepository

    public init(bannerRepository: BannerRepository) {
        self.bannerRepository = bannerRepository
    }

    public func execute() async throws -> [Banner] {
        return try await bannerRepository.fetchMainBanners()
    }
}
