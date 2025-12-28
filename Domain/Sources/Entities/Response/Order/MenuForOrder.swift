//
//  MenuForOrder.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public struct MenuForOrder: Sendable {
    public let menu: MenuDetailForOrder
    public let quantity: Int

    public init(menu: MenuDetailForOrder, quantity: Int) {
        self.menu = menu
        self.quantity = quantity
    }
}

public struct MenuDetailForOrder: Sendable {
    public let id: String
    public let category: String
    public let name: String
    public let description: String
    public let originInformation: String
    public let price: Int
    public let tags: [String]
    public let menuImageURL: String
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String, category: String, name: String, description: String, originInformation: String, price: Int, tags: [String], menuImageURL: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.category = category
        self.name = name
        self.description = description
        self.originInformation = originInformation
        self.price = price
        self.tags = tags
        self.menuImageURL = menuImageURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
