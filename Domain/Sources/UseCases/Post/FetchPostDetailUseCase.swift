//
//  FetchPostDetailUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public protocol FetchPostDetailUseCase: Sendable {
    func execute(id: String) async throws -> PostDetail
}

public final class FetchPostDetailUseCaseImpl: FetchPostDetailUseCase, @unchecked Sendable {
    private let postRepository: PostRepository

    public init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }

    public func execute(id: String) async throws -> PostDetail {
        return try await postRepository.fetchPostDetail(id: id)
    }
}
