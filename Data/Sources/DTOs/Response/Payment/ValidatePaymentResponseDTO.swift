//
//  ValidatePaymentResponseDTO.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Domain
import Core

struct ValidatePaymentResponseDTO: ResponseDTO {
    private let paymentId: String
    private let orderItem: OrderItemForPaymentDTO
    private let createdAt: String
    private let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case paymentId = "payment_id"
        case orderItem = "order_item"
        case createdAt
        case updatedAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.paymentId = try container.decode(String.self, forKey: .paymentId)
        self.orderItem = try container.decode(OrderItemForPaymentDTO.self, forKey: .orderItem)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
}

extension ValidatePaymentResponseDTO {
    var toDomain: ValidatePaymentResponse {
        let formatter = Core.DateFormatterProvider.iso8601
        return .init(paymentId: paymentId,
                     orderItem: orderItem.toDomain,
                     createdAt: formatter.date(from: createdAt) ?? Date(),
                     updatedAt: formatter.date(from: updatedAt) ?? Date()
        )
    }
}

struct OrderItemForPaymentDTO: ResponseDTO {
    private let orderId: String
    private let orderCode: String
    private let totalPrice: Int
    private let restaurant: RestaurantForValidationDTO
    private let orderMenuList: [MenuForOrderDTO]
    private let paidAt: String
    private let createdAt: String
    private let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case orderCode = "order_code"
        case totalPrice = "total_price"
        case restaurant = "store"
        case orderMenuList = "order_menu_list"
        case paidAt
        case createdAt
        case updatedAt
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.orderId = try container.decode(String.self, forKey: .orderId)
        self.orderCode = try container.decode(String.self, forKey: .orderCode)
        self.totalPrice = try container.decode(Int.self, forKey: .totalPrice)
        self.restaurant = try container.decode(RestaurantForValidationDTO.self, forKey: .restaurant)
        self.orderMenuList = try container.decode([MenuForOrderDTO].self, forKey: .orderMenuList)
        self.paidAt = try container.decode(String.self, forKey: .paidAt)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
}

extension OrderItemForPaymentDTO {
    var toDomain: OrderItemForPayment {
        let formatter = Core.DateFormatterProvider.iso8601
        return .init(orderId: orderId,
                     orderCode: orderCode,
                     totalPrice: totalPrice,
                     restaurant: restaurant.toDomain,
                     orderMenuList: orderMenuList.map { $0.toDomain },
                     paidAt: formatter.date(from: paidAt) ?? Date(),
                     createdAt: formatter.date(from: createdAt) ?? Date(),
                     updatedAt: formatter.date(from: updatedAt) ?? Date()
        )
    }
}
