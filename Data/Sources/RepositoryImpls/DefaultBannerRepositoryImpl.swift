//
//  DefaultBannerRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Domain

public final class DefaultBannerRepositoryImpl: BannerRepository, @unchecked Sendable {
    private let networkManager = NetworkManager.shared

    public init() {}

    public func fetchMainBanners() async throws -> [Banner] {
        guard let response = try await networkManager.request(
            BannerRouter.banner,
            responseType: ResponseListDTO<BannerDTO>.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }
}
