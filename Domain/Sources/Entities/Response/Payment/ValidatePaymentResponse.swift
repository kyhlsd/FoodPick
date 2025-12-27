//
//  ValidatePaymentResponse.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public struct ValidatePaymentResponse: Sendable {
    public let paymentId: String
    public let orderItem: OrderItemForPayment
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(paymentId: String, orderItem: OrderItemForPayment, createdAt: Date, updatedAt: Date) {
        self.paymentId = paymentId
        self.orderItem = orderItem
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct OrderItemForPayment: Sendable {
    public let orderId: String
    public let orderCode: String
    public let totalPrice: Int
    public let restaurant: Restaurant
    public let orderMenuList: [MenuForOrder]
    public let paidAt: Date
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(orderId: String, orderCode: String, totalPrice: Int, restaurant: Restaurant, orderMenuList: [MenuForOrder], paidAt: Date, createdAt: Date, updatedAt: Date) {
        self.orderId = orderId
        self.orderCode = orderCode
        self.totalPrice = totalPrice
        self.restaurant = restaurant
        self.orderMenuList = orderMenuList
        self.paidAt = paidAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
