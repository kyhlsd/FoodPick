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
        let urlString = "\(APIInfos.baseURL)/v1/\(imagePath)"

        guard let url = URL(string: urlString) else {
            throw ImageServiceError.invalidURL(imagePath)
        }

        var request = URLRequest(url: url)

        let accessToken = try await tokenRepository.getAccessToken()
        request.setValue(APIInfos.key, forHTTPHeaderField: "SesacKey")
        request.setValue(accessToken, forHTTPHeaderField: "Authorization")

        return request
    }
}

// MARK: - Error
public enum ImageServiceError: Error {
    case invalidURL(String)
}
