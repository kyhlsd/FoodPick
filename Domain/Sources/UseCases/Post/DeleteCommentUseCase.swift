//
//  DeleteCommentUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public protocol DeleteCommentUseCase: Sendable {
    func execute(postId: String, commentId: String) async throws
}

public final class DeleteCommentUseCaseImpl: DeleteCommentUseCase, @unchecked Sendable {
    private let postRepository: PostRepository

    public init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }

    public func execute(postId: String, commentId: String) async throws {
        try await postRepository.deleteComment(postId: postId, commentId: commentId)
    }
}
