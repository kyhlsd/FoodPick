//
//  ReviewForRestaurantDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Foundation
import Domain
import Core

struct ReviewForRestaurantDTO: ResponseDTO {
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
}

extension ReviewForRestaurantDTO {
    var toDomain: ReviewForRestaurant {
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
