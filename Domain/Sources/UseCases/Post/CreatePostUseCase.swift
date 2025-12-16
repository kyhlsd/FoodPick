//
//  CreatePostUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public protocol CreatePostUseCase: Sendable {
    func execute(request: CreatePostRequest) async throws -> PostDetail
}

public final class CreatePostUseCaseImpl: CreatePostUseCase, @unchecked Sendable {
    private let postRepository: PostRepository

    public init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }

    public func execute(request: CreatePostRequest) async throws -> PostDetail {
        return try await postRepository.createPost(request: request)
    }
}
