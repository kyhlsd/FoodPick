//
//  OrderDTO.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Domain
import Core

struct OrderDTO: ResponseDTO {
    private let orderId: String
    private let orderCode: String
    private let totalPrice: Int
    private let review: ReviewForOrderDTO?
    private let restaurant: RestaurantDTO
    private let orderMenuList: [MenuForOrderDTO]
    private let currentOrderStatus: OrderStatusDTO
    private let orderStatusTimeline: [OrderStatusTimelineItemDTO]
    private let paidAt: String
    private let createdAt: String
    private let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case orderCode = "order_code"
        case totalPrice = "total_price"
        case review
        case restaurant = "store"
        case orderMenuList = "order_menu_list"
        case currentOrderStatus = "current_order_status"
        case orderStatusTimeline = "order_status_timeline"
        case paidAt
        case createdAt
        case updatedAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.orderId = try container.decode(String.self, forKey: .orderId)
        self.orderCode = try container.decode(String.self, forKey: .orderCode)
        self.totalPrice = try container.decode(Int.self, forKey: .totalPrice)
        self.review = try container.decodeIfPresent(ReviewForOrderDTO.self, forKey: .review)
        self.restaurant = try container.decode(RestaurantDTO.self, forKey: .restaurant)
        self.orderMenuList = try container.decode([MenuForOrderDTO].self, forKey: .orderMenuList)
        self.currentOrderStatus = try container.decode(OrderStatusDTO.self, forKey: .currentOrderStatus)
        self.orderStatusTimeline = try container.decode([OrderStatusTimelineItemDTO].self, forKey: .orderStatusTimeline)
        self.paidAt = try container.decode(String.self, forKey: .paidAt)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
}

extension OrderDTO {
    var toDomain: Order {
        let formatter = Core.DateFormatterProvider.iso8601
        return .init(orderId: orderId,
                     orderCode: orderCode,
                     totalPrice: totalPrice,
                     review: review?.toDomain,
                     restaurant: restaurant.toDomain,
                     orderMenuList: orderMenuList.map { $0.toDomain },
                     currentOrderStatus: currentOrderStatus.toDomain,
                     orderStatusTimeline: orderStatusTimeline.map { $0.toDomain },
                     paidAt: formatter.date(from: paidAt) ?? Date(),
                     createdAt: formatter.date(from: createdAt) ?? Date(),
                     updatedAt: formatter.date(from: updatedAt) ?? Date()
        )
    }
}

struct ReviewForOrderDTO: ResponseDTO {
    private let id: String
    private let rating: Int
}

extension ReviewForOrderDTO {
    var toDomain: ReviewForOrder {
        return .init(id: id, rating: rating)
    }
}
