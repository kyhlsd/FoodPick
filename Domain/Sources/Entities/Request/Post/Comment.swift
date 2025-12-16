//
//  Comment.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public struct Comment {
    public let commentId: String
    public let content: String
    public let createdAt: Date
    public let creator: Profile
    public let replies: [Reply]
    
    public struct Reply {
        private let commentId: String
        private let content: String
        private let createdAt: Date
        private let creator: Profile
        
        public init(commentId: String, content: String, createdAt: Date, creator: Profile) {
            self.commentId = commentId
            self.content = content
            self.createdAt = createdAt
            self.creator = creator
        }
    }
    
    public init(commentId: String, content: String, createdAt: Date, creator: Profile, replies: [Reply]) {
        self.commentId = commentId
        self.content = content
        self.createdAt = createdAt
        self.creator = creator
        self.replies = replies
    }
}
