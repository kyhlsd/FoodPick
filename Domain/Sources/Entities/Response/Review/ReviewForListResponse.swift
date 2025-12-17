//
//  ReviewForListResponse.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public struct ReviewForListResponse {
    public let reviewId: String
    public let content: String
    public let rating: Int
    public let reviewImageURLs: [String]
    public let orderMenuList: [String]
    public let creator: Profile
    public let userTotalReviewCount: Int
    public let userTotalRating: Float
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(reviewId: String, content: String, rating: Int, reviewImageURLs: [String], orderMenuList: [String], creator: Profile, userTotalReviewCount: Int, userTotalRating: Float, createdAt: Date, updatedAt: Date) {
        self.reviewId = reviewId
        self.content = content
        self.rating = rating
        self.reviewImageURLs = reviewImageURLs
        self.orderMenuList = orderMenuList
        self.creator = creator
        self.userTotalReviewCount = userTotalReviewCount
        self.userTotalRating = userTotalRating
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
