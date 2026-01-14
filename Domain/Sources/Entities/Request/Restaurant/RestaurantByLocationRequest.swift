//
//  RestaurantByLocationRequest.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public struct RestaurantByLocationRequest {
    public let category: RestaurantCategory?
    public let longitude: Double?
    public let latitude: Double?
    public let maxDistance: Float?
    public let next: String?
    public let limit: Int?
    public let orderBy: RestaurantOrderBy

    public init(category: RestaurantCategory?, longitude: Double?, latitude: Double?, maxDistance: Float?, next: String?, limit: Int?, orderBy: RestaurantOrderBy) {
        self.category = category
        self.longitude = longitude
        self.latitude = latitude
        self.maxDistance = maxDistance
        self.next = next
        self.limit = limit
        self.orderBy = orderBy
    }
}
