//
//  ReviewFilesResponse.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public struct ReviewFilesResponse {
    public let reviewImageURLs: [String]
    
    public init(reviewImageURLs: [String]) {
        self.reviewImageURLs = reviewImageURLs
    }
}
