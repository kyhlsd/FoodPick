//
//  OrderRequest.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public struct OrderRequest {
    public let storeId: String
    public let orderMenuList: [MenuRequest]
    public let totalPrice: Int
    
    public init(storeId: String, orderMenuList: [MenuRequest], totalPrice: Int) {
        self.storeId = storeId
        self.orderMenuList = orderMenuList
        self.totalPrice = totalPrice
    }
}

public struct MenuRequest {
    public let menuId: String
    public let quantity: Int
    
    public init(menuId: String, quantity: Int) {
        self.menuId = menuId
        self.quantity = quantity
    }
}
