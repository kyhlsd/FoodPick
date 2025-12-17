//
//  EditCommentUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public protocol EditCommentUseCase: Sendable {
    func execute(postId: String, commentId: String, content: String) async throws -> Comment
}

public final class EditCommentUseCaseImpl: EditCommentUseCase, @unchecked Sendable {
    private let postRepository: PostRepository

    public init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }

    public func execute(postId: String, commentId: String, content: String) async throws -> Comment {
        return try await postRepository.editComment(postId: postId, commentId: commentId, content: content)
    }
}
