//
//  Menu.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

import Foundation

public struct Menu {
    public let menuId: String
    public let restaurantId: String
    public let category: String
    public let name: String
    public let description: String
    public let originInfo: String
    public let price: Int
    public let isSoldOut: Bool
    public let tags: [String]
    public let menuImageURL: String
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(menuId: String, restaurantId: String, category: String, name: String, description: String, originInfo: String, price: Int, isSoldOut: Bool, tags: [String], menuImageURL: String, createdAt: Date, updatedAt: Date) {
        self.menuId = menuId
        self.restaurantId = restaurantId
        self.category = category
        self.name = name
        self.description = description
        self.originInfo = originInfo
        self.price = price
        self.isSoldOut = isSoldOut
        self.tags = tags
        self.menuImageURL = menuImageURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
