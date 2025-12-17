//
//  ReviewStatisticsItemDTO.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Domain

struct ReviewStatisticsItemDTO: ResponseDTO {
    private let rating: Int
    private let count: Int
}

extension ReviewStatisticsItemDTO {
    var toDomain: ReviewStatisticsItem {
        return .init(rating: rating, count: count)
    }
}
