//
//  SearchPostsUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public protocol SearchPostsUseCase: Sendable {
    func execute(title: String) async throws -> [Post]
}

public final class SearchPostsUseCaseImpl: SearchPostsUseCase, @unchecked Sendable {
    private let postRepository: PostRepository

    public init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }

    public func execute(title: String) async throws -> [Post] {
        return try await postRepository.searchPosts(title: title)
    }
}
