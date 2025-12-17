//
//  ReviewPageRequest.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public struct ReviewPageRequest {
    public let next: String?
    public let limit: String?
    public let orderBy: ReviewOrderBy?
    
    public init(next: String?, limit: String?, orderBy: ReviewOrderBy?) {
        self.next = next
        self.limit = limit
        self.orderBy = orderBy
    }
}

public enum ReviewOrderBy: String {
    case latest = "최신순"
    case ratingHigh = "별점 높은 순"
    case ratingLow = "별점 낮은 순"
}
