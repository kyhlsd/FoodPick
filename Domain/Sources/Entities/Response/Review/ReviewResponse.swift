//
//  ReviewResponse.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public struct ReviewResponse {
    public let reviewId: String
    public let content: String
    public let rating: Int
    public let store: Store
    public let reviewImageURLs: [String]
    public let orderMenuList: [String]
    public let creator: Profile
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(reviewId: String, content: String, rating: Int, store: Store, reviewImageURLs: [String], orderMenuList: [String], creator: Profile, createdAt: Date, updatedAt: Date) {
        self.reviewId = reviewId
        self.content = content
        self.rating = rating
        self.store = store
        self.reviewImageURLs = reviewImageURLs
        self.orderMenuList = orderMenuList
        self.creator = creator
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
