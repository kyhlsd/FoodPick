//
//  LikeVideoUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public protocol LikeVideoUseCase: Sendable {
    func execute(id: String, like: Bool) async throws -> LikeStatus
}

public final class LikeVideoUseCaseImpl: LikeVideoUseCase, @unchecked Sendable {
    private let videoRepository: VideoRepository

    public init(videoRepository: VideoRepository) {
        self.videoRepository = videoRepository
    }

    public func execute(id: String, like: Bool) async throws -> LikeStatus {
        return try await videoRepository.likeVideo(id: id, like: like)
    }
}
