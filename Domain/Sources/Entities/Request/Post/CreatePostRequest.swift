//
//  CreatePostRequest.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public struct CreatePostRequest {
    public let category: StoreCategory
    public let title: String
    public let content: String
    public let storeId: String
    public let latitude: Float
    public let longitude: Float
    public let files: [String]
    
    public init(category: StoreCategory, title: String, content: String, storeId: String, latitude: Float, longitude: Float, files: [String]) {
        self.category = category
        self.title = title
        self.content = content
        self.storeId = storeId
        self.latitude = latitude
        self.longitude = longitude
        self.files = files
    }
}
