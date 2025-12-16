//
//  StoreForPostDTO.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Domain
import Core

struct StoreForPostDTO: ResponseDTO {
    private let id: String
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
    private let geolocation: GeolocationDTO
    private let distance: Float?
    private let createdAt: String
    private let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
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
        case geolocation
        case distance
        case createdAt
        case updatedAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.category = try container.decode(String.self, forKey: .category)
        self.name = try container.decode(String.self, forKey: .name)
        self.close = try container.decode(String.self, forKey: .close)
        self.storeImageURLs = try container.decode([String].self, forKey: .storeImageURLs)
        self.isPicchelin = try container.decode(Bool.self, forKey: .isPicchelin)
        self.isPick = try container.decode(Bool.self, forKey: .isPick)
        self.pickCount = try container.decode(Int.self, forKey: .pickCount)
        self.hashTags = try container.decode([String].self, forKey: .hashTags)
        self.totalRating = try container.decode(Float.self, forKey: .totalRating)
        self.totalOrderCount = try container.decode(Int.self, forKey: .totalOrderCount)
        self.totalReviewCount = try container.decode(Int.self, forKey: .totalReviewCount)
        self.geolocation = try container.decode(GeolocationDTO.self, forKey: .geolocation)
        self.distance = try container.decodeIfPresent(Float.self, forKey: .distance)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
}

extension StoreForPostDTO {
    var toDomain: Store {
        let formatter = Core.DateFormatterProvider.iso8601
        return .init(storeId: id,
                     category: StoreCategory(rawValue: category) ?? .etc,
                     name: name,
                     close: close,
                     storeImageURLs: storeImageURLs,
                     isPicchelin: isPicchelin,
                     isPick: isPick,
                     pickCount: pickCount,
                     hashTags: hashTags,
                     totalRating: totalRating,
                     totalOrderCount: totalOrderCount,
                     totalReviewCount: totalReviewCount,
                     geolocation: geolocation.toDomain,
                     distance: distance,
                     createdAt: formatter.date(from: createdAt) ?? Date(),
                     updatedAt: formatter.date(from: updatedAt) ?? Date())
    }
}
