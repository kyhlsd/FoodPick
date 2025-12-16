//
//  FetchUserPostsUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public protocol FetchUserPostsUseCase: Sendable {
    func execute(userId: String, request: BasicRequest) async throws -> ResponseListWithCursor<Post>
}

public final class FetchUserPostsUseCaseImpl: FetchUserPostsUseCase, @unchecked Sendable {
    private let postRepository: PostRepository

    public init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }

    public func execute(userId: String, request: BasicRequest) async throws -> ResponseListWithCursor<Post> {
        return try await postRepository.fetchUserPosts(userId: userId, request: request)
    }
}
