//
//  LikePostUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public protocol LikePostUseCase: Sendable {
    func execute(id: String, like: Bool) async throws -> LikeStatus
}

public final class LikePostUseCaseImpl: LikePostUseCase, @unchecked Sendable {
    private let postRepository: PostRepository

    public init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }

    public func execute(id: String, like: Bool) async throws -> LikeStatus {
        return try await postRepository.likePost(id: id, like: like)
    }
}
