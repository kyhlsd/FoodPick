//
//  ReviewDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Foundation
import Domain
import Core

struct ReviewDTO: ResponseDTO {
    private let reviewId: String
    private let content: String
    private let rating: Int
    private let store: StoreDTO
    private let reviewImageURLs: [String]
    private let orderMenuList: [String]
    private let creator: ProfileDTO
    private let createdAt: String
    private let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case reviewId = "review_id"
        case content
        case rating
        case store
        case reviewImageURLs = "review_image_urls"
        case orderMenuList = "order_menu_list"
        case creator
        case createdAt
        case updatedAt
    }
}

extension ReviewDTO {
    var toDomain: Review {
        let formatter = Core.DateFormatterProvider.iso8601
        return .init(reviewId: reviewId,
                     content: content,
                     rating: rating,
                     store: store.toDomain,
                     reviewImageURLs: reviewImageURLs,
                     orderMenuList: orderMenuList,
                     creator: creator.toDomain,
                     createdAt: formatter.date(from: createdAt) ?? Date(),
                     updatedAt: formatter.date(from: updatedAt) ?? Date()
        )
    }
}
