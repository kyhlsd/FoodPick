//
//  ByLocationRequestDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Foundation
import Domain

struct ByLocationRequestDTO {
    private let category: String?
    private let longitude: String?
    private let latitude: String?
    private let maxDistance: String?
    private let next: String?
    private let limit: String?
    private let orderBy: String
}

extension ByLocationRequestDTO {
    init(from domain: RestaurantByLocationRequest) {
        let longitude: String?
        if let domainLongitude = domain.longitude {
            longitude = String(domainLongitude)
        } else {
            longitude = nil
        }

        let latitude: String?
        if let domainLatitude = domain.latitude {
            latitude = String(domainLatitude)
        } else {
            latitude = nil
        }

        let maxDistance: String?
        if let domainMaxDistance = domain.maxDistance {
            maxDistance = String(domainMaxDistance)
        } else {
            maxDistance = nil
        }

        let limit: String?
        if let domainLimit = domain.limit {
            limit = String(domainLimit)
        } else {
            limit = nil
        }

        self.init(category: domain.category?.rawValue, longitude: longitude, latitude: latitude, maxDistance: maxDistance, next: domain.next, limit: limit, orderBy: domain.orderBy.rawValue)
    }
    
    init(from domain: PostByLocationRequest) {
        let longitude: String?
        if let domainLongitude = domain.longitude {
            longitude = String(domainLongitude)
        } else {
            longitude = nil
        }
        
        let latitude: String?
        if let domainLatitude = domain.latitude {
            latitude = String(domainLatitude)
        } else {
            latitude = nil
        }
        
        let maxDistance: String?
        if let domainMaxDistance = domain.maxDistance {
            maxDistance = String(domainMaxDistance)
        } else {
            maxDistance = nil
        }
        
        let limit: String?
        if let domainLimit = domain.limit {
            limit = String(domainLimit)
        } else {
            limit = nil
        }
        
        self.init(category: domain.category?.rawValue, longitude: longitude, latitude: latitude, maxDistance: maxDistance, next: domain.next, limit: limit, orderBy: domain.orderBy.rawValue)
    }
    
    var toQueryItems: [URLQueryItem] {
        var items = [URLQueryItem]()
        if let category {
            items.append(.init(name: "category", value: category))
        }
        if let longitude {
            items.append(.init(name: "longitude", value: longitude))
        }
        if let latitude {
            items.append(.init(name: "latitude", value: latitude))
        }
        if let maxDistance {
            items.append(.init(name: "maxDistance", value: maxDistance))
        }
        if let next {
            items.append(.init(name: "next", value: next))
        }
        if let limit {
            items.append(.init(name: "limit", value: limit))
        }
        items.append(.init(name: "order_by", value: orderBy))
        
        return items
    }
}
