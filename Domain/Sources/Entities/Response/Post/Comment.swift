//
//  Comment.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public struct Comment: Sendable {
    public let commentId: String
    public let content: String
    public let createdAt: Date
    public let creator: Profile
    public let replies: [Comment]?
    
    public init(commentId: String, content: String, createdAt: Date, creator: Profile, replies: [Comment]?) {
        self.commentId = commentId
        self.content = content
        self.createdAt = createdAt
        self.creator = creator
        self.replies = replies
    }
}
