//
//  PostDTO.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Domain
import Core

struct PostDTO: ResponseDTO {
    private let postId: String
    private let category: String
    private let title: String
    private let content: String
    private let store: StoreForPostDTO
    private let geolocation: GeolocationDTO
    private let creator: ProfileDTO
    private let files: [String]
    private let isLike: Bool
    private let likeCount: Int
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
        case createdAt
        case updatedAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.postId = try container.decode(String.self, forKey: .postId)
        self.category = try container.decode(String.self, forKey: .category)
        self.title = try container.decode(String.self, forKey: .title)
        self.content = try container.decode(String.self, forKey: .content)
        self.store = try container.decode(StoreForPostDTO.self, forKey: .store)
        self.geolocation = try container.decode(GeolocationDTO.self, forKey: .geolocation)
        self.creator = try container.decode(ProfileDTO.self, forKey: .creator)
        self.files = try container.decode([String].self, forKey: .files)
        self.isLike = try container.decode(Bool.self, forKey: .isLike)
        self.likeCount = try container.decode(Int.self, forKey: .likeCount)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
}

extension PostDTO {
    var toDomain: Post {
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
                     createdAt: formatter.date(from: createdAt) ?? Date(),
                     updatedAt: formatter.date(from: updatedAt) ?? Date()
        )
    }
}
