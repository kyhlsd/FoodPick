//
//  OrderResponse.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public struct OrderResponse {
    public let orderId: String
    public let orderCode: String
    public let totalPrice: Int
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(orderId: String, orderCode: String, totalPrice: Int, createdAt: Date, updatedAt: Date) {
        self.orderId = orderId
        self.orderCode = orderCode
        self.totalPrice = totalPrice
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
