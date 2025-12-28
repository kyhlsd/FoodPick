//
//  RestaurantForValidation.swift
//  Domain
//
//  Created by 김영훈 on 12/28/25.
//

import Foundation

public struct RestaurantForValidation: Sendable {
    public let restaurantId: String
    public let category: RestaurantCategory
    public let name: String
    public let close: String
    public let restaurantImageURLs: [String]
    public let geolocation: Geolocation
    public let distance: Float?
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        restaurantId: String,
        category: RestaurantCategory,
        name: String,
        close: String,
        restaurantImageURLs: [String],
        geolocation: Geolocation,
        distance: Float?,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.restaurantId = restaurantId
        self.category = category
        self.name = name
        self.close = close
        self.restaurantImageURLs = restaurantImageURLs
        self.geolocation = geolocation
        self.distance = distance
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
