//
//  EditPostUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public protocol EditPostUseCase: Sendable {
    func execute(id: String, request: EditPostRequest) async throws -> PostDetail
}

public final class EditPostUseCaseImpl: EditPostUseCase, @unchecked Sendable {
    private let postRepository: PostRepository

    public init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }

    public func execute(id: String, request: EditPostRequest) async throws -> PostDetail {
        return try await postRepository.editPost(id: id, request: request)
    }
}
