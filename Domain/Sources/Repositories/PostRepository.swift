//
//  PostRepository.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Core

public protocol PostRepository {
    func uploadFiles(datas: [(Data, MediaType)], onProgress: (@Sendable (Double) -> Void)?) async throws -> [String]
    func createPost(request: CreatePostRequest) async throws -> PostDetail
    func fetchPosts(request: ByLocationRequest) async throws -> ResponseListWithCursor<Post>
    func searchPosts(title: String) async throws -> [Post]
    func fetchPostDetail(id: String) async throws -> PostDetail
    func editPost(id: String, request: EditPostRequest) async throws -> PostDetail
    func deletePost(id: String) async throws
    func likePost(id: String, like: Bool) async throws -> LikeStatus
    func fetchUserPosts(userId: String, request: BasicRequest) async throws -> ResponseListWithCursor<Post>
    func fetchMyLikes(request: BasicRequest) async throws -> ResponseListWithCursor<Post>
}
