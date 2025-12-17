//
//  CreateCommentUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public protocol CreateCommentUseCase: Sendable {
    func execute(postId: String, parentId: String?, content: String) async throws -> Comment
}

public final class CreateCommentUseCaseImpl: CreateCommentUseCase, @unchecked Sendable {
    private let postRepository: PostRepository

    public init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }

    public func execute(postId: String, parentId: String?, content: String) async throws -> Comment {
        return try await postRepository.createComment(postId: postId, parentId: parentId, content: content)
    }
}
