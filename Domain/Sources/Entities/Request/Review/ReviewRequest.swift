//
//  ReviewRequest.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public struct ReviewRequest {
    public let content: String
    public let rating: Int
    public let reviewImageURLs: [String]
    public let orderCode: String
    
    public init(content: String, rating: Int, reviewImageURLs: [String], orderCode: String) {
        self.content = content
        self.rating = rating
        self.reviewImageURLs = reviewImageURLs
        self.orderCode = orderCode
    }
}
