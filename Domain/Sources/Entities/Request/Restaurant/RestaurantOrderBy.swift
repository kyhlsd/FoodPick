//
//  RestaurantOrderBy.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public enum RestaurantOrderBy: String, CaseIterable, Sendable {
    case distance = "거리순"
    case orders = "주문수"
    case reviews = "리뷰수"
}
