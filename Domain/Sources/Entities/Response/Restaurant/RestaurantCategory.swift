//
//  RestaurantCategory.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public enum RestaurantCategory: String, CaseIterable, Sendable {
    case cafe = "카페"
    case fastfood = "패스트푸드"
    case desert = "디저트"
    case bakery = "베이커리"
    case korean = "한식"
    case japanese = "일식"
    case chinese = "중식"
    case chicken = "치킨"
    case pizza = "피자"
    case etc = "기타"
}
