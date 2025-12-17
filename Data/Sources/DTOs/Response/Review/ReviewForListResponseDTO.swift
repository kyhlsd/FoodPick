//
//  ReviewForListResponseDTO.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Domain
import Core

struct ReviewForListResponseDTO: ResponseDTO {
    private let reviewId: String
    private let content: String
    private let rating: Int
    private let reviewImageURLs: [String]
    private let orderMenuList: [String]
    private let creator: ProfileDTO
    private let userTotalReviewCount: Int
    private let userTotalRating: Float
    private let createdAt: String
    private let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case reviewId = "review_id"
        case content
        case rating
        case reviewImageURLs = "review_image_urls"
        case orderMenuList = "order_menu_list"
        case creator
        case userTotalReviewCount = "user_total_review_count"
        case userTotalRating = "user_total_rating"
        case createdAt
        case updatedAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.reviewId = try container.decode(String.self, forKey: .reviewId)
        self.content = try container.decode(String.self, forKey: .content)
        self.rating = try container.decode(Int.self, forKey: .rating)
        self.reviewImageURLs = try container.decode([String].self, forKey: .reviewImageURLs)
        self.orderMenuList = try container.decode([String].self, forKey: .orderMenuList)
        self.creator = try container.decode(ProfileDTO.self, forKey: .creator)
        self.userTotalReviewCount = try container.decode(Int.self, forKey: .userTotalReviewCount)
        self.userTotalRating = try container.decode(Float.self, forKey: .userTotalRating)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
}

extension ReviewForListResponseDTO {
    var toDomain: ReviewForListResponse {
        let formatter = Core.DateFormatterProvider.iso8601
        return .init(reviewId: reviewId,
                     content: content,
                     rating: rating,
                     reviewImageURLs: reviewImageURLs,
                     orderMenuList: orderMenuList,
                     creator: creator.toDomain,
                     userTotalReviewCount: userTotalReviewCount,
                     userTotalRating: userTotalRating,
                     createdAt: formatter.date(from: createdAt) ?? Date(),
                     updatedAt: formatter.date(from: updatedAt) ?? Date()
        )
    }
}
