//
//  EditPostRequest.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public struct EditPostRequest: Sendable {
    public let category: RestaurantCategory?
    public let title: String?
    public let content: String?
    public let restaurantId: String?
    public let latitude: Double?
    public let longitude: Double?
    public let files: [String]?
    
    public init(category: RestaurantCategory? = nil, title: String? = nil, content: String? = nil, restaurantId: String? = nil, latitude: Double? = nil, longitude: Double? = nil, files: [String]? = nil) {
        self.category = category
        self.title = title
        self.content = content
        self.restaurantId = restaurantId
        self.latitude = latitude
        self.longitude = longitude
        self.files = files
    }
}
