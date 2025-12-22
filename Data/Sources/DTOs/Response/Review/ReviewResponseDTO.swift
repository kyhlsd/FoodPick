//
//  ReviewResponseDTO.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Domain
import Core

struct ReviewResponseDTO: ResponseDTO {
    private let reviewId: String
    private let content: String
    private let rating: Int
    private let restaurant: RestaurantDTO
    private let reviewImageURLs: [String]
    private let orderMenuList: [String]
    private let creator: ProfileDTO
    private let createdAt: String
    private let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case reviewId = "review_id"
        case content
        case rating
        case restaurant = "store"
        case reviewImageURLs = "review_image_urls"
        case orderMenuList = "order_menu_list"
        case creator
        case createdAt
        case updatedAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.reviewId = try container.decode(String.self, forKey: .reviewId)
        self.content = try container.decode(String.self, forKey: .content)
        self.rating = try container.decode(Int.self, forKey: .rating)
        self.restaurant = try container.decode(RestaurantDTO.self, forKey: .restaurant)
        self.reviewImageURLs = try container.decode([String].self, forKey: .reviewImageURLs)
        self.orderMenuList = try container.decode([String].self, forKey: .orderMenuList)
        self.creator = try container.decode(ProfileDTO.self, forKey: .creator)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
}

extension ReviewResponseDTO {
    var toDomain: ReviewResponse {
        let formatter = Core.DateFormatterProvider.iso8601
        return .init(reviewId: reviewId,
                     content: content,
                     rating: rating,
                     restaurant: restaurant.toDomain,
                     reviewImageURLs: reviewImageURLs,
                     orderMenuList: orderMenuList,
                     creator: creator.toDomain,
                     createdAt: formatter.date(from: createdAt) ?? Date(),
                     updatedAt: formatter.date(from: updatedAt) ?? Date()
        )
    }
}
