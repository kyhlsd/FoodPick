//
//  StoreDetailDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Foundation
import Domain
import Core

struct StoreDetailDTO: ResponseDTO {
    private let storeId: String
    private let category: String
    private let name: String
    private let description: String
    private let hashTags: [String]
    private let open: String
    private let close: String
    private let address: String
    private let estimatedPickupTime: Int
    private let parkingGuide: String
    private let storeImageURLs: [String]
    private let isPicchelin: Bool
    private let isPick: Bool
    private let pickCount: Int
    private let totalReviewCount: Int
    private let totalOrderCount: Int
    private let totalRating: Float
    private let creator: ProfileDTO
    private let geolocation: GeolocationDTO
    private let menuList: [MenuDTO]
    private let createdAt: String
    private let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case storeId = "store_id"
        case category
        case name
        case description
        case hashTags
        case open
        case close
        case address
        case estimatedPickupTime = "estimated_pickup_time"
        case parkingGuide = "parking_guide"
        case storeImageURLs = "store_image_urls"
        case isPicchelin = "is_picchelin"
        case isPick = "is_pick"
        case pickCount = "pick_count"
        case totalReviewCount = "total_review_count"
        case totalOrderCount = "total_order_count"
        case totalRating = "total_rating"
        case creator
        case geolocation
        case menuList = "menu_list"
        case createdAt
        case updatedAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.storeId = try container.decode(String.self, forKey: .storeId)
        self.category = try container.decode(String.self, forKey: .category)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.hashTags = try container.decode([String].self, forKey: .hashTags)
        self.open = try container.decode(String.self, forKey: .open)
        self.close = try container.decode(String.self, forKey: .close)
        self.address = try container.decode(String.self, forKey: .address)
        self.estimatedPickupTime = try container.decode(Int.self, forKey: .estimatedPickupTime)
        self.parkingGuide = try container.decode(String.self, forKey: .parkingGuide)
        self.storeImageURLs = try container.decode([String].self, forKey: .storeImageURLs)
        self.isPicchelin = try container.decode(Bool.self, forKey: .isPicchelin)
        self.isPick = try container.decode(Bool.self, forKey: .isPick)
        self.pickCount = try container.decode(Int.self, forKey: .pickCount)
        self.totalReviewCount = try container.decode(Int.self, forKey: .totalReviewCount)
        self.totalOrderCount = try container.decode(Int.self, forKey: .totalOrderCount)
        self.totalRating = try container.decode(Float.self, forKey: .totalRating)
        self.creator = try container.decode(ProfileDTO.self, forKey: .creator)
        self.geolocation = try container.decode(GeolocationDTO.self, forKey: .geolocation)
        self.menuList = try container.decode([MenuDTO].self, forKey: .menuList)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
}

extension StoreDetailDTO {
    var toDomain: StoreDetail {
        let formatter = Core.DateFormatterProvider.iso8601
        return .init(storeId: storeId,
                     category: .init(rawValue: category) ?? .etc,
                     name: name,
                     description: description,
                     hashTags: hashTags,
                     open: open,
                     close: close,
                     address: address,
                     estimatedPickupTime: estimatedPickupTime,
                     parkingGuide: parkingGuide,
                     storeImageURLs: storeImageURLs,
                     isPicchelin: isPicchelin,
                     isPick: isPick,
                     pickCount: pickCount,
                     totalReviewCount: totalReviewCount,
                     totalOrderCount: totalOrderCount,
                     totalRating: totalRating,
                     creator: creator.toDomain,
                     geoLocation: geolocation.toDomain,
                     menuList: menuList.map { $0.toDomain },
                     createdAt: formatter.date(from: createdAt) ?? Date(),
                     updatedAt: formatter.date(from: updatedAt) ?? Date()
        )
    }
}
