//
//  PostDependency.swift
//  Presentation
//
//  Created by 김영훈 on 12/19/25.
//

import Domain
import Data
import ComposableArchitecture

extension DependencyValues {

    // MARK: - Repository
    var postRepository: PostRepository {
        get { self[PostRepositoryKey.self] }
        set { self[PostRepositoryKey.self] = newValue }
    }

    // MARK: - UseCases
    var fetchPosts: FetchPostsUseCase {
        get { self[FetchPostsKey.self] }
        set { self[FetchPostsKey.self] = newValue }
    }

    var fetchPostDetail: FetchPostDetailUseCase {
        get { self[FetchPostDetailKey.self] }
        set { self[FetchPostDetailKey.self] = newValue }
    }

    var createPost: CreatePostUseCase {
        get { self[CreatePostKey.self] }
        set { self[CreatePostKey.self] = newValue }
    }

    var editPost: EditPostUseCase {
        get { self[EditPostKey.self] }
        set { self[EditPostKey.self] = newValue }
    }

    var deletePost: DeletePostUseCase {
        get { self[DeletePostKey.self] }
        set { self[DeletePostKey.self] = newValue }
    }

    var likePost: LikePostUseCase {
        get { self[LikePostKey.self] }
        set { self[LikePostKey.self] = newValue }
    }

    var searchPosts: SearchPostsUseCase {
        get { self[SearchPostsKey.self] }
        set { self[SearchPostsKey.self] = newValue }
    }

    var fetchUserPosts: FetchUserPostsUseCase {
        get { self[FetchUserPostsKey.self] }
        set { self[FetchUserPostsKey.self] = newValue }
    }

    var fetchMyLikedPosts: FetchMyLikedPostsUseCase {
        get { self[FetchMyLikedPostsKey.self] }
        set { self[FetchMyLikedPostsKey.self] = newValue }
    }

    var uploadPostFiles: UploadFilesUseCase {
        get { self[UploadPostFilesKey.self] }
        set { self[UploadPostFilesKey.self] = newValue }
    }

    var createComment: CreateCommentUseCase {
        get { self[CreateCommentKey.self] }
        set { self[CreateCommentKey.self] = newValue }
    }

    var editComment: EditCommentUseCase {
        get { self[EditCommentKey.self] }
        set { self[EditCommentKey.self] = newValue }
    }

    var deleteComment: DeleteCommentUseCase {
        get { self[DeleteCommentKey.self] }
        set { self[DeleteCommentKey.self] = newValue }
    }
}

// MARK: - Keys
private enum PostRepositoryKey: DependencyKey {
    static let liveValue: PostRepository = DefaultPostRepositoryImpl()
}

private enum FetchPostsKey: DependencyKey {
    static let liveValue: FetchPostsUseCase = {
        @Dependency(\.postRepository) var postRepository
        return FetchPostsUseCaseImpl(postRepository: postRepository)
    }()
}

private enum FetchPostDetailKey: DependencyKey {
    static let liveValue: FetchPostDetailUseCase = {
        @Dependency(\.postRepository) var postRepository
        return FetchPostDetailUseCaseImpl(postRepository: postRepository)
    }()
}

private enum CreatePostKey: DependencyKey {
    static let liveValue: CreatePostUseCase = {
        @Dependency(\.postRepository) var postRepository
        return CreatePostUseCaseImpl(postRepository: postRepository)
    }()
}

private enum EditPostKey: DependencyKey {
    static let liveValue: EditPostUseCase = {
        @Dependency(\.postRepository) var postRepository
        return EditPostUseCaseImpl(postRepository: postRepository)
    }()
}

private enum DeletePostKey: DependencyKey {
    static let liveValue: DeletePostUseCase = {
        @Dependency(\.postRepository) var postRepository
        return DeletePostUseCaseImpl(postRepository: postRepository)
    }()
}

private enum LikePostKey: DependencyKey {
    static let liveValue: LikePostUseCase = {
        @Dependency(\.postRepository) var postRepository
        return LikePostUseCaseImpl(postRepository: postRepository)
    }()
}

private enum SearchPostsKey: DependencyKey {
    static let liveValue: SearchPostsUseCase = {
        @Dependency(\.postRepository) var postRepository
        return SearchPostsUseCaseImpl(postRepository: postRepository)
    }()
}

private enum FetchUserPostsKey: DependencyKey {
    static let liveValue: FetchUserPostsUseCase = {
        @Dependency(\.postRepository) var postRepository
        return FetchUserPostsUseCaseImpl(postRepository: postRepository)
    }()
}

private enum FetchMyLikedPostsKey: DependencyKey {
    static let liveValue: FetchMyLikedPostsUseCase = {
        @Dependency(\.postRepository) var postRepository
        return FetchMyLikedPostsUseCaseImpl(postRepository: postRepository)
    }()
}

private enum UploadPostFilesKey: DependencyKey {
    static let liveValue: UploadFilesUseCase = {
        @Dependency(\.postRepository) var postRepository
        return UploadFilesUseCaseImpl(postRepository: postRepository)
    }()
}

private enum CreateCommentKey: DependencyKey {
    static let liveValue: CreateCommentUseCase = {
        @Dependency(\.postRepository) var postRepository
        return CreateCommentUseCaseImpl(postRepository: postRepository)
    }()
}

private enum EditCommentKey: DependencyKey {
    static let liveValue: EditCommentUseCase = {
        @Dependency(\.postRepository) var postRepository
        return EditCommentUseCaseImpl(postRepository: postRepository)
    }()
}

private enum DeleteCommentKey: DependencyKey {
    static let liveValue: DeleteCommentUseCase = {
        @Dependency(\.postRepository) var postRepository
        return DeleteCommentUseCaseImpl(postRepository: postRepository)
    }()
}
