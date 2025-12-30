//
//  ReviewStatisticsItem.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public struct ReviewStatisticsItem: Sendable {
    public let rating: Int
    public let count: Int
    
    public init(rating: Int, count: Int) {
        self.rating = rating
        self.count = count
    }
}
