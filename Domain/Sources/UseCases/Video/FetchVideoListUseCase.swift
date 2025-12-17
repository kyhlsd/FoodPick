//
//  FetchVideoListUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public protocol FetchVideoListUseCase: Sendable {
    func execute(request: VideoPageRequest) async throws -> VideoListResponse
}

public final class FetchVideoListUseCaseImpl: FetchVideoListUseCase, @unchecked Sendable {
    private let videoRepository: VideoRepository

    public init(videoRepository: VideoRepository) {
        self.videoRepository = videoRepository
    }

    public func execute(request: VideoPageRequest) async throws -> VideoListResponse {
        return try await videoRepository.fetchVideoList(request: request)
    }
}
