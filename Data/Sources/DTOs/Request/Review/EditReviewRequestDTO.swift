//
//  EditReviewRequestDTO.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Domain

struct EditReviewRequestDTO: Encodable {
    private let content: String?
    private let rating: Int?
    private let reviewImageURLs: [String]?
    
    enum CodingKeys: String, CodingKey {
        case content
        case rating
        case reviewImageURLs = "review_image_urls"
    }
}

extension EditReviewRequestDTO {
    init(from domain: EditReviewRequest) {
        self.init(content: domain.content,
                  rating: domain.rating,
                  reviewImageURLs: domain.reviewImageURLs
        )
    }
}
