//
//  Post.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public struct Post {
    public let postId: String
    public let category: String
    public let title: String
    public let content: String
    public let store: Store
    public let geolocation: Geolocation
    public let creator: Profile
    public let files: [String]
    public let isLike: Bool
    public let likeCount: Int
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(postId: String, category: String, title: String, content: String, store: Store, geolocation: Geolocation, creator: Profile, files: [String], isLike: Bool, likeCount: Int, createdAt: Date, updatedAt: Date) {
        self.postId = postId
        self.category = category
        self.title = title
        self.content = content
        self.store = store
        self.geolocation = geolocation
        self.creator = creator
        self.files = files
        self.isLike = isLike
        self.likeCount = likeCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
