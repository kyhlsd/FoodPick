//
//  DeletePostUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public protocol DeletePostUseCase: Sendable {
    func execute(id: String) async throws
}

public final class DeletePostUseCaseImpl: DeletePostUseCase, @unchecked Sendable {
    private let postRepository: PostRepository

    public init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }

    public func execute(id: String) async throws {
        try await postRepository.deletePost(id: id)
    }
}
