//
//  DefaultPostRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Domain
import Core

public final class DefaultPostRepositoryImpl: PostRepository, @unchecked Sendable {
    private let networkManager = NetworkManager.shared

    public init() {}

    // MARK: - Post
    public func uploadFiles(datas: [(Data, MediaType)], onProgress: (@Sendable (Double) -> Void)?) async throws -> [String] {
        guard let response = try await networkManager.request(
            PostRouter.files(datas: datas),
            responseType: FilesResponseDTO.self,
            onProgress: onProgress
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func createPost(request: CreatePostRequest) async throws -> PostDetail {
        let dto = CreatePostRequestDTO(from: request)
        guard let response = try await networkManager.request(
            PostRouter.create(dto: dto),
            responseType: PostDetailDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func fetchPosts(request: PostByLocationRequest) async throws -> ResponseListWithCursor<Post> {
        let dto = ByLocationRequestDTO(from: request)
        guard let response = try await networkManager.request(
            PostRouter.posts(dto: dto),
            responseType: ResponseListWithCursorDTO<PostDTO>.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func searchPosts(title: String) async throws -> [Post] {
        guard let response = try await networkManager.request(
            PostRouter.search(title: title),
            responseType: ResponseListDTO<PostDTO>.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func fetchPostDetail(id: String) async throws -> PostDetail {
        guard let response = try await networkManager.request(
            PostRouter.detail(id: id),
            responseType: PostDetailDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func editPost(id: String, request: EditPostRequest) async throws -> PostDetail {
        let dto = EditPostRequestDTO(from: request)
        guard let response = try await networkManager.request(
            PostRouter.edit(id: id, dto: dto),
            responseType: PostDetailDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func deletePost(id: String) async throws {
        try await networkManager.request(PostRouter.delete(id: id))
    }

    public func likePost(id: String, like: Bool) async throws -> LikeStatus {
        guard let response = try await networkManager.request(
            PostRouter.like(id: id, like: like),
            responseType: LikeStatusDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func fetchUserPosts(userId: String, request: BasicRequest) async throws -> ResponseListWithCursor<Post> {
        let dto = BasicRequestDTO(from: request)
        guard let response = try await networkManager.request(
            PostRouter.userPosts(id: userId, dto: dto),
            responseType: ResponseListWithCursorDTO<PostDTO>.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func fetchMyLikes(request: BasicRequest) async throws -> ResponseListWithCursor<Post> {
        let dto = BasicRequestDTO(from: request)
        guard let response = try await networkManager.request(
            PostRouter.myLikes(dto: dto),
            responseType: ResponseListWithCursorDTO<PostDTO>.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    // MARK: - Comment
    public func createComment(postId: String, parentId: String?, content: String) async throws -> Comment {
        guard let response = try await networkManager.request(
            PostRouter.createComment(postId: postId, parentId: parentId, content: content),
            responseType: CommentDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func editComment(postId: String, commentId: String, content: String) async throws -> Comment {
        guard let response = try await networkManager.request(
            PostRouter.editComment(postId: postId, commentId: commentId, content: content),
            responseType: CommentDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func deleteComment(postId: String, commentId: String) async throws {
        try await networkManager.request(PostRouter.deleteComment(postId: postId, commentId: commentId))
    }
}
