//
//  VideoPageRequestDTO.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Domain

struct VideoPageRequestDTO {
    private let next: String?
    private let limit: String?
}

extension VideoPageRequestDTO {
    init(from domain: VideoPageRequest) {
        let limit: String?
        if let domainLimit = domain.limit {
            limit = String(domainLimit)
        } else {
            limit = nil
        }
        self.init(next: domain.next, limit: limit)
    }
    
    var toQueryItems: [URLQueryItem] {
        var items = [URLQueryItem]()
        if let next {
            items.append(.init(name: "next", value: next))
        }
        if let limit {
            items.append(.init(name: "limit", value: limit))
        }
        return items
    }
}
