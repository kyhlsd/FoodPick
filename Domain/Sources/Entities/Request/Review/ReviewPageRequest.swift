//
//  ReviewPageRequest.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public struct ReviewPageRequest: Sendable {
    public let next: String?
    public let limit: Int?
    public let orderBy: ReviewOrderBy?

    public init(next: String?, limit: Int?, orderBy: ReviewOrderBy?) {
        self.next = next
        self.limit = limit
        self.orderBy = orderBy
    }
}

public enum ReviewOrderBy: String, CaseIterable, Sendable {
    case latest = "최신순"
    case ratingHigh = "별점 높은 순"
    case ratingLow = "별점 낮은 순"
}
