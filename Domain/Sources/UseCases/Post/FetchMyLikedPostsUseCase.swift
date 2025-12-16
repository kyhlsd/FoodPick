//
//  FetchMyLikedPostsUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public protocol FetchMyLikedPostsUseCase: Sendable {
    func execute(request: BasicRequest) async throws -> ResponseListWithCursor<Post>
}

public final class FetchMyLikedPostsUseCaseImpl: FetchMyLikedPostsUseCase, @unchecked Sendable {
    private let postRepository: PostRepository

    public init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }

    public func execute(request: BasicRequest) async throws -> ResponseListWithCursor<Post> {
        return try await postRepository.fetchMyLikes(request: request)
    }
}
