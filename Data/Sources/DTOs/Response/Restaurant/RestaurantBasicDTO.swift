//
//  RestaurantBasicDTO.swift
//  Data
//
//  Created by 김영훈 on 12/28/25.
//

import Foundation
import Domain
import Core

struct RestaurantBasicDTO: ResponseDTO {
    private let restaurantId: String
    private let category: String
    private let name: String
    private let close: String
    private let restaurantImageURLs: [String]
    private let geolocation: GeolocationDTO
    private let createdAt: String
    private let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case restaurantId = "store_id"
        case id
        case category
        case name
        case close
        case restaurantImageURLs = "store_image_urls"
        case geolocation
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
        self.geolocation = try container.decode(GeolocationDTO.self, forKey: .geolocation)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
}

extension RestaurantBasicDTO {
    var toDomain: RestaurantBasic {
        let formatter = Core.DateFormatterProvider.iso8601
        return .init(restaurantId: restaurantId,
                     category: RestaurantCategory(rawValue: category) ?? .etc,
                     name: name,
                     close: close,
                     restaurantImageURLs: restaurantImageURLs,
                     geolocation: geolocation.toDomain,
                     createdAt: formatter.date(from: createdAt) ?? Date(),
                     updatedAt: formatter.date(from: updatedAt) ?? Date())
    }
}
