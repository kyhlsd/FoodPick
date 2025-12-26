//
//  RestaurantDetail.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

import Foundation

public struct RestaurantDetail: Sendable {
    public let restaurantId: String
    public let category: RestaurantCategory
    public let name: String
    public let description: String
    public let hashTags: [String]
    public let open: String
    public let close: String
    public let address: String
    public let estimatedPickupTime: Int
    public let parkingGuide: String
    public let restaurantImageURLs: [String]
    public let isPicchelin: Bool
    public var isPick: Bool
    public var pickCount: Int
    public let totalReviewCount: Int
    public let totalOrderCount: Int
    public let totalRating: Float
    public let creator: Profile
    public let geolocation: Geolocation
    public let menuList: [Menu]
    public let createdAt: Date
    public let updatedAt: Date

    public init(restaurantId: String, category: RestaurantCategory, name: String, description: String, hashTags: [String], open: String, close: String, address: String, estimatedPickupTime: Int, parkingGuide: String, restaurantImageURLs: [String], isPicchelin: Bool, isPick: Bool, pickCount: Int, totalReviewCount: Int, totalOrderCount: Int, totalRating: Float, creator: Profile, geoLocation: Geolocation, menuList: [Menu], createdAt: Date, updatedAt: Date) {
        self.restaurantId = restaurantId
        self.category = category
        self.name = name
        self.description = description
        self.hashTags = hashTags
        self.open = open
        self.close = close
        self.address = address
        self.estimatedPickupTime = estimatedPickupTime
        self.parkingGuide = parkingGuide
        self.restaurantImageURLs = restaurantImageURLs
        self.isPicchelin = isPicchelin
        self.isPick = isPick
        self.pickCount = pickCount
        self.totalReviewCount = totalReviewCount
        self.totalOrderCount = totalOrderCount
        self.totalRating = totalRating
        self.creator = creator
        self.geolocation = geoLocation
        self.menuList = menuList
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
