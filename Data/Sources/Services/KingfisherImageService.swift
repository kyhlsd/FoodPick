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

    // In-flight requests: 진행 중인 요청을 추적
    private actor RequestCache {
        private var inFlightRequests: [String: Task<URLRequest, Error>] = [:]

        func getOrCreate(
            for imagePath: String,
            create: @escaping () async throws -> URLRequest
        ) async throws -> URLRequest {
            // 이미 진행 중인 요청이 있으면 그 결과를 기다림
            if let existingTask = inFlightRequests[imagePath] {
                return try await existingTask.value
            }

            // 새 요청 시작
            let task = Task<URLRequest, Error> {
                defer {
                    Task {
                        await self.removeTask(for: imagePath)
                    }
                }
                return try await create()
            }

            inFlightRequests[imagePath] = task
            return try await task.value
        }

        private func removeTask(for imagePath: String) {
            inFlightRequests.removeValue(forKey: imagePath)
        }
    }

    private let requestCache = RequestCache()

    public init(tokenRepository: TokenRepository) {
        self.tokenRepository = tokenRepository
    }

    public func makeAuthenticatedRequest(for imagePath: String) async throws -> URLRequest {
        return try await requestCache.getOrCreate(for: imagePath) { [weak self] in
            guard let self = self else {
                throw ImageServiceError.invalidURL("Service deallocated")
            }

            let router = PathRouter.file(path: imagePath)
            var request = try router.asURLRequest()

            let accessToken = try await self.tokenRepository.getAccessToken()
            request.setValue(accessToken, forHTTPHeaderField: "Authorization")

            return request
        }
    }
}

// MARK: - Error
public enum ImageServiceError: Error {
    case invalidURL(String)
}
