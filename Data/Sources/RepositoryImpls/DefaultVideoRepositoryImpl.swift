//
//  DefaultVideoRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Domain

public final class DefaultVideoRepositoryImpl: VideoRepository, @unchecked Sendable {
    private let networkManager = NetworkManager.shared

    public init() {}

    public func fetchVideoList(request: VideoPageRequest) async throws -> VideoListResponse {
        guard let response = try await networkManager.request(
            VideoRouter.videoList(dto: .init(from: request)),
            responseType: VideoListResponseDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func fetchVideoStream(id: String) async throws -> StreamResponse {
        guard let response = try await networkManager.request(
            VideoRouter.stream(id: id),
            responseType: StreamResponseDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func likeVideo(id: String, like: Bool) async throws -> LikeStatus {
        guard let response = try await networkManager.request(
            VideoRouter.like(id: id, like: like),
            responseType: LikeStatusDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func fetchSubtitle(path: String) async throws -> String {
        guard let response = try await networkManager.request(
            VideoRouter.subtitle(path: path),
            responseType: String.self
        ) else {
            throw APIError.empty
        }
        return response
    }
}
