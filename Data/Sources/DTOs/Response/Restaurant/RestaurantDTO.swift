//
//  RestaurantDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Foundation
import Domain
import Core

struct RestaurantDTO: ResponseDTO {
    private let restaurantId: String
    private let category: String
    private let name: String
    private let close: String
    private let restaurantImageURLs: [String]
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
        case restaurantId = "store_id"
        case id
        case category
        case name
        case close
        case restaurantImageURLs = "store_image_urls"
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
        self.restaurantId = try container.decodeIfPresent(String.self, forKey: .restaurantId)
            ?? container.decode(String.self, forKey: .id)
        self.category = try container.decode(String.self, forKey: .category)
        self.name = try container.decode(String.self, forKey: .name)
        self.close = try container.decode(String.self, forKey: .close)
        self.restaurantImageURLs = try container.decode([String].self, forKey: .restaurantImageURLs)
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

extension RestaurantDTO {
    var toDomain: Restaurant {
        let formatter = Core.DateFormatterProvider.iso8601
        return .init(restaurantId: restaurantId,
                     category: RestaurantCategory(rawValue: category) ?? .etc,
                     name: name,
                     close: close,
                     restaurantImageURLs: restaurantImageURLs,
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
