//
//  FetchPostsUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public protocol FetchPostsUseCase: Sendable {
    func execute(request: ByLocationRequest) async throws -> ResponseListWithCursor<Post>
}

public final class FetchPostsUseCaseImpl: FetchPostsUseCase, @unchecked Sendable {
    private let postRepository: PostRepository

    public init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }

    public func execute(request: ByLocationRequest) async throws -> ResponseListWithCursor<Post> {
        return try await postRepository.fetchPosts(request: request)
    }
}
