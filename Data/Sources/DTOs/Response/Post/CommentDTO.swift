//
//  CommentDTO.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Domain
import Core

struct CommentDTO: ResponseDTO {
    private let commentId: String
    private let content: String
    private let createdAt: String
    private let creator: ProfileDTO
    private let replies: [CommentDTO]?
    
    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case content
        case createdAt
        case creator
        case replies
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.commentId = try container.decode(String.self, forKey: .commentId)
        self.content = try container.decode(String.self, forKey: .content)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.creator = try container.decode(ProfileDTO.self, forKey: .creator)
        self.replies = try container.decodeIfPresent([CommentDTO].self, forKey: .replies)
    }
}

extension CommentDTO {
    var toDomain: Comment {
        let formatter = Core.DateFormatterProvider.iso8601
        return .init(commentId: commentId,
                     content: content,
                     createdAt: formatter.date(from: createdAt) ?? Date(),
                     creator: creator.toDomain,
                     replies: replies?.map { $0.toDomain }
        )
    }
}
