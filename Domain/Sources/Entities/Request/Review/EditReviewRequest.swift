//
//  EditReviewRequest.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public struct EditReviewRequest {
    public let content: String?
    public let rating: Int?
    public let reviewImageURLs: [String]?
    
    public init(content: String?, rating: Int?, reviewImageURLs: [String]?) {
        self.content = content
        self.rating = rating
        self.reviewImageURLs = reviewImageURLs
    }
}
