//
//  Order.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public struct Order {
    public let orderId: String
    public let orderCode: String
    public let totalPrice: Int
    public let review: ReviewForOrder?
    public let restaurant: Restaurant
    public let orderMenuList: [MenuForOrder]
    public let currentOrderStatus: OrderStatus
    public let orderStatusTimeline: [OrderStatusTimelineItem]
    public let paidAt: Date
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(orderId: String, orderCode: String, totalPrice: Int, review: ReviewForOrder?, restaurant: Restaurant, orderMenuList: [MenuForOrder], currentOrderStatus: OrderStatus, orderStatusTimeline: [OrderStatusTimelineItem], paidAt: Date, createdAt: Date, updatedAt: Date) {
        self.orderId = orderId
        self.orderCode = orderCode
        self.totalPrice = totalPrice
        self.review = review
        self.restaurant = restaurant
        self.orderMenuList = orderMenuList
        self.currentOrderStatus = currentOrderStatus
        self.orderStatusTimeline = orderStatusTimeline
        self.paidAt = paidAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct ReviewForOrder {
    public let id: String
    public let rating: Int
    
    public init(id: String, rating: Int) {
        self.id = id
        self.rating = rating
    }
}
