//
//  ReviewRequestDTO.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Domain

struct ReviewRequestDTO: Encodable {
    private let content: String
    private let rating: Int
    private let reviewImageURLs: [String]
    private let orderCode: String
    
    enum CodingKeys: String, CodingKey {
        case content
        case rating
        case reviewImageURLs = "review_image_urls"
        case orderCode = "order_code"
    }
}

extension ReviewRequestDTO {
    init(from domain: ReviewRequest) {
        self.init(content: domain.content,
                  rating: domain.rating,
                  reviewImageURLs: domain.reviewImageURLs,
                  orderCode: domain.orderCode
        )
    }
}
