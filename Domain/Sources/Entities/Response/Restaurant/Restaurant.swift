//
//  Restaurant.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

import Foundation

public struct Restaurant: Sendable {
    public let restaurantId: String
    public let category: RestaurantCategory
    public let name: String
    public let close: String
    public let restaurantImageURLs: [String]
    public let isPicchelin: Bool
    public let isPick: Bool
    public let pickCount: Int
    public let hashTags: [String]
    public let totalRating: Float
    public let totalOrderCount: Int
    public let totalReviewCount: Int
    public let geolocation: Geolocation
    public let distance: Float?
    public let createdAt: Date
    public let updatedAt: Date

    public init(restaurantId: String, category: RestaurantCategory, name: String, close: String, restaurantImageURLs: [String], isPicchelin: Bool, isPick: Bool, pickCount: Int, hashTags: [String], totalRating: Float, totalOrderCount: Int, totalReviewCount: Int, geolocation: Geolocation, distance: Float?, createdAt: Date, updatedAt: Date) {
        self.restaurantId = restaurantId
        self.category = category
        self.name = name
        self.close = close
        self.restaurantImageURLs = restaurantImageURLs
        self.isPicchelin = isPicchelin
        self.isPick = isPick
        self.pickCount = pickCount
        self.hashTags = hashTags
        self.totalRating = totalRating
        self.totalOrderCount = totalOrderCount
        self.totalReviewCount = totalReviewCount
        self.geolocation = geolocation
        self.distance = distance
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
