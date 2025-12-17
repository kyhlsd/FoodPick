//
//  ValidatePaymentResponse.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public struct ValidatePaymentResponse {
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

public struct OrderItemForPayment {
    public let orderId: String
    public let orderCode: String
    public let totalPrice: Int
    public let store: Store
    public let orderMenuList: [MenuForOrder]
    public let paidAt: Date
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(orderId: String, orderCode: String, totalPrice: Int, store: Store, orderMenuList: [MenuForOrder], paidAt: Date, createdAt: Date, updatedAt: Date) {
        self.orderId = orderId
        self.orderCode = orderCode
        self.totalPrice = totalPrice
        self.store = store
        self.orderMenuList = orderMenuList
        self.paidAt = paidAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
