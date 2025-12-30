//
//  ReviewPageRequestDTO.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Domain

struct ReviewPageRequestDTO {
    private let next: String?
    private let limit: Int?
    private let orderBy: ReviewOrderByDTO?
}

extension ReviewPageRequestDTO {
    init(from domain: ReviewPageRequest) {
        let orderBy: ReviewOrderByDTO?
        if let domainOrderBy = domain.orderBy {
            orderBy = .init(from: domainOrderBy)
        } else {
            orderBy = nil
        }
        self.init(next: domain.next, limit: domain.limit, orderBy: orderBy)
    }

    var toQueryItems: [URLQueryItem] {
        var items = [URLQueryItem]()
        if let next {
            items.append(.init(name: "next", value: next))
        }
        if let limit {
            items.append(.init(name: "limit", value: String(limit)))
        }
        if let orderBy {
            items.append(.init(name: "order_by", value: orderBy.rawValue))
        }
        return items
    }
}

enum ReviewOrderByDTO: String {
    case latest
    case ratingHigh = "rating_high"
    case ratingLow = "rating_low"
}

extension ReviewOrderByDTO {
    init(from domain: ReviewOrderBy) {
        switch domain {
        case .latest:
            self = .latest
        case .ratingHigh:
            self = .ratingHigh
        case .ratingLow:
            self = .ratingLow
        }
    }
}
