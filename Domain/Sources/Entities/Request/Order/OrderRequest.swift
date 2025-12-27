//
//  OrderRequest.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public struct OrderRequest: Sendable {
    public let restaurantId: String
    public let orderMenuList: [MenuRequest]
    public let totalPrice: Int
    
    public init(restaurantId: String, orderMenuList: [MenuRequest], totalPrice: Int) {
        self.restaurantId = restaurantId
        self.orderMenuList = orderMenuList
        self.totalPrice = totalPrice
    }
}

public struct MenuRequest: Sendable {
    public let menuId: String
    public let quantity: Int
    
    public init(menuId: String, quantity: Int) {
        self.menuId = menuId
        self.quantity = quantity
    }
}
