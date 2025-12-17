//
//  FetchVideoStreamUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public protocol FetchVideoStreamUseCase: Sendable {
    func execute(id: String) async throws -> StreamResponse
}

public final class FetchVideoStreamUseCaseImpl: FetchVideoStreamUseCase, @unchecked Sendable {
    private let videoRepository: VideoRepository

    public init(videoRepository: VideoRepository) {
        self.videoRepository = videoRepository
    }

    public func execute(id: String) async throws -> StreamResponse {
        return try await videoRepository.fetchVideoStream(id: id)
    }
}
