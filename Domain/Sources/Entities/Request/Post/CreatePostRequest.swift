//
//  CreatePostRequest.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public struct CreatePostRequest: Sendable {
    public let category: RestaurantCategory
    public let title: String
    public let content: String
    public let restaurantId: String
    public let latitude: Float
    public let longitude: Float
    public let files: [String]
    
    public init(category: RestaurantCategory, title: String, content: String, restaurantId: String, latitude: Float, longitude: Float, files: [String]) {
        self.category = category
        self.title = title
        self.content = content
        self.restaurantId = restaurantId
        self.latitude = latitude
        self.longitude = longitude
        self.files = files
    }
}
