//
//  BannerRepository.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public protocol BannerRepository {
    func fetchMainBanners() async throws -> [Banner]
}
