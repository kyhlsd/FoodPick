//
//  Store.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

import Foundation

public struct Store {
    public let storeId: String
    public let category: StoreCategory
    public let name: String
    public let close: String
    public let storeImageURLs: [String]
    public let isPicchelin: Bool
    public let isPick: Bool
    public let pickCount: Int
    public let hashTags: [String]
    public let totalRating: Float
    public let totalOrderCount: Int
    public let totalReviewCount: Int
    public let geoLocation: GeoLocation
    public let distance: Float
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(storeId: String, category: StoreCategory, name: String, close: String, storeImageURLs: [String], isPicchelin: Bool, isPick: Bool, pickCount: Int, hashTags: [String], totalRating: Float, totalOrderCount: Int, totalReviewCount: Int, geoLocation: GeoLocation, distance: Float, createdAt: Date, updatedAt: Date) {
        self.storeId = storeId
        self.category = category
        self.name = name
        self.close = close
        self.storeImageURLs = storeImageURLs
        self.isPicchelin = isPicchelin
        self.isPick = isPick
        self.pickCount = pickCount
        self.hashTags = hashTags
        self.totalRating = totalRating
        self.totalOrderCount = totalOrderCount
        self.totalReviewCount = totalReviewCount
        self.geoLocation = geoLocation
        self.distance = distance
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
