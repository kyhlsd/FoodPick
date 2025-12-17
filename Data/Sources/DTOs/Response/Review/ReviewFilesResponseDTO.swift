//
//  ReviewFilesResponseDTO.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Domain

struct ReviewFilesResponseDTO: ResponseDTO {
    private let reviewImageURLs: [String]
    
    enum CodingKeys: String, CodingKey {
        case reviewImageURLs = "review_image_urls"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.reviewImageURLs = try container.decode([String].self, forKey: .reviewImageURLs)
    }
}

extension ReviewFilesResponseDTO {
    var toDomain: ReviewFilesResponse {
        return .init(reviewImageURLs: reviewImageURLs)
    }
}
