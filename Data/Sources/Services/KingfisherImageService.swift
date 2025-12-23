//
//  KingfisherImageService.swift
//  Data
//
//  Created by 김영훈 on 12/23/25.
//

import Foundation
import Domain

public final class KingfisherImageService: ImageService {
    private let tokenRepository: TokenRepository

    public init(tokenRepository: TokenRepository) {
        self.tokenRepository = tokenRepository
    }

    public func makeAuthenticatedRequest(for imagePath: String) async throws -> URLRequest {
        let router = PathRouter.file(path: imagePath)
        var request = try router.asURLRequest()

        let accessToken = try await tokenRepository.getAccessToken()
        request.setValue(accessToken, forHTTPHeaderField: "Authorization")

        return request
    }
}

// MARK: - Error
public enum ImageServiceError: Error {
    case invalidURL(String)
}
