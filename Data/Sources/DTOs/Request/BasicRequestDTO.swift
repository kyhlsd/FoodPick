//
//  BasicRequestDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Foundation
import Domain

struct BasicRequestDTO: Encodable {
    private let category: String?
    private let next: String?
    private let limit: String?
}

extension BasicRequestDTO {
    init(from domain: BasicRequest) {
        let limit: String?
        if let domainLimit = domain.limit {
            limit = String(domainLimit)
        } else {
            limit = nil
        }
        self.init(category: domain.category?.rawValue, next: domain.next, limit: limit)
    }
    
    var toQueryItems: [URLQueryItem] {
        var items = [URLQueryItem]()
        if let category {
            items.append(.init(name: "category", value: category))
        }
        if let next {
            items.append(.init(name: "next", value: next))
        }
        if let limit {
            items.append(.init(name: "limit", value: limit))
        }
        return items
    }
}
