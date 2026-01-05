//
//  PostDetail.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public struct PostDetail: Sendable {
    public let postId: String
    public let category: String
    public let title: String
    public let content: String
    public let restaurant: Restaurant
    public let geolocation: Geolocation
    public let creator: Profile
    public let files: [String]
    public var isLike: Bool
    public var likeCount: Int
    public var comments: [Comment]
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(postId: String, category: String, title: String, content: String, restaurant: Restaurant, geolocation: Geolocation, creator: Profile, files: [String], isLike: Bool, likeCount: Int, comments: [Comment], createdAt: Date, updatedAt: Date) {
        self.postId = postId
        self.category = category
        self.title = title
        self.content = content
        self.restaurant = restaurant
        self.geolocation = geolocation
        self.creator = creator
        self.files = files
        self.isLike = isLike
        self.likeCount = likeCount
        self.comments = comments
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
