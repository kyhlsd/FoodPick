//
//  ImageServiceDependency.swift
//  Presentation
//
//  Created by 김영훈 on 12/23/25.
//

import Domain
import Data
import ComposableArchitecture

extension DependencyValues {
    // MARK: - Image Service
    var imageService: ImageService {
        get { self[ImageServiceKey.self] }
        set { self[ImageServiceKey.self] = newValue }
    }
}

// MARK: - Keys
private enum ImageServiceKey: DependencyKey {
    static let liveValue: ImageService = {
        @Dependency(\.tokenRepository) var tokenRepository
        return KingfisherImageService(tokenRepository: tokenRepository)
    }()
}
