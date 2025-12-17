//
//  VideoResponse.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public struct VideoResponse {
    public let id: String
    public let fileName: String
    public let title: String
    public let description: String
    public let duration: Float
    public let thumbnailURL: String
    public let availableQualities: [String]
    public let viewCount: Int
    public let likeCount: Int
    public let isLiked: Bool
    public let createdAt: Date
    
    public init(id: String, fileName: String, title: String, description: String, duration: Float, thumbnailURL: String, availableQualities: [String], viewCount: Int, likeCount: Int, isLiked: Bool, createdAt: Date) {
        self.id = id
        self.fileName = fileName
        self.title = title
        self.description = description
        self.duration = duration
        self.thumbnailURL = thumbnailURL
        self.availableQualities = availableQualities
        self.viewCount = viewCount
        self.likeCount = likeCount
        self.isLiked = isLiked
        self.createdAt = createdAt
    }
}

public struct VideoListResponse {
    public let data: [VideoResponse]
    public let nextCursor: String?
    
    public init(data: [VideoResponse], nextCursor: String?) {
        self.data = data
        self.nextCursor = nextCursor
    }
}
