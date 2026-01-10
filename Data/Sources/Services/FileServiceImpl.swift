//
//  FileServiceImpl.swift
//  Data
//
//  Created by 김영훈 on 12/23/25.
//

import Foundation
import Domain

public final class FileServiceImpl: FileService {
    private let tokenRepository: TokenRepository

    public init(tokenRepository: TokenRepository) {
        self.tokenRepository = tokenRepository
    }

    public func makeAuthenticatedRequest(for path: String) async throws -> URLRequest {
        let router = PathRouter.file(path: path)
        var request = try router.asURLRequest()

        let accessToken = try await tokenRepository.getAccessToken()
        request.setValue(accessToken, forHTTPHeaderField: "Authorization")

        return request
    }

    public func makeFullURL(from path: String) throws -> URL {
        let fullPath = "\(APIInfos.baseURL)/v1\(path)"
        guard let url = URL(string: fullPath) else {
            throw FileServiceError.invalidURL(fullPath)
        }
        return url
    }
}

// MARK: - Error
public enum FileServiceError: Error {
    case invalidURL(String)
}
