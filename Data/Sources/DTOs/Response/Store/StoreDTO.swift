//
//  StoreDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Foundation
import Domain
import Core

struct StoreDTO: ResponseDTO {
    private let storeId: String
    private let category: String
    private let name: String
    private let close: String
    private let storeImageURLs: [String]
    private let isPicchelin: Bool
    private let isPick: Bool
    private let pickCount: Int
    private let hashTags: [String]
    private let totalRating: Float
    private let totalOrderCount: Int
    private let totalReviewCount: Int
    private let geoLocation: GeoLocationDTO
    private let distance: Float
    private let createdAt: String
    private let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case storeId = "store_id"
        case category
        case name
        case close
        case storeImageURLs = "store_image_urls"
        case isPicchelin = "is_picchelin"
        case isPick = "is_pick"
        case pickCount = "pick_count"
        case hashTags
        case totalRating = "total_rating"
        case totalOrderCount = "total_order_count"
        case totalReviewCount = "total_review_count"
        case geoLocation
        case distance
        case createdAt
        case updatedAt
    }
}

extension StoreDTO {
    var toDomain: Store {
        let formatter = Core.DateFormatterProvider.iso8601
        return .init(storeId: storeId,
                     category: StoreCategory(rawValue: category) ?? .etc,
                     name: name,
                     close: close,
                     storeImageURLs: storeImageURLs,
                     isPicchelin: isPicchelin,
                     isPick: isPick,
                     pickCount: pickCount,
                     hashTags: hashTags,
                     totalRating: totalRating, totalOrderCount: totalOrderCount,
                     totalReviewCount: totalReviewCount,
                     geoLocation: geoLocation.toDomain,
                     distance: distance,
                     createdAt: formatter.date(from: createdAt) ?? Date(),
                     updatedAt: formatter.date(from: updatedAt) ?? Date())
    }
}
