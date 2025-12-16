//
//  PostDetailDTO.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Domain
import Core

struct PostDetailDTO: ResponseDTO {
    private let postId: String
    private let category: String
    private let title: String
    private let content: String
    private let store: StoreDTO
    private let geolocation: GeolocationDTO
    private let creator: ProfileDTO
    private let files: [String]
    private let isLike: Bool
    private let likeCount: Int
    private let comments: [CommentDTO]
    private let createdAt: String
    private let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case category
        case title
        case content
        case store
        case geolocation
        case creator
        case files
        case isLike = "is_like"
        case likeCount = "like_count"
        case comments
        case createdAt
        case updatedAt
    }
}

extension PostDetailDTO {
    var toDomain: PostDetail {
        let formatter = Core.DateFormatterProvider.iso8601
        return .init(postId: postId,
                     category: category,
                     title: title,
                     content: content,
                     store: store.toDomain,
                     geolocation: geolocation.toDomain,
                     creator: creator.toDomain,
                     files: files,
                     isLike: isLike,
                     likeCount: likeCount,
                     comments: comments.map { $0.toDomain },
                     createdAt: formatter.date(from: createdAt) ?? Date(),
                     updatedAt: formatter.date(from: updatedAt) ?? Date()
        )
    }
}
