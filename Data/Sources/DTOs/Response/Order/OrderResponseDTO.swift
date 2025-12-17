//
//  OrderResponseDTO.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Domain
import Core

struct OrderResponseDTO: ResponseDTO {
    private let orderId: String
    private let orderCode: String
    private let totalPrice: Int
    private let createdAt: String
    private let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case orderCode = "order_code"
        case totalPrice = "total_price"
        case createdAt
        case updatedAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.orderId = try container.decode(String.self, forKey: .orderId)
        self.orderCode = try container.decode(String.self, forKey: .orderCode)
        self.totalPrice = try container.decode(Int.self, forKey: .totalPrice)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
}

extension OrderResponseDTO {
    var toDomain: OrderResponse {
        let formatter = Core.DateFormatterProvider.iso8601
        return .init(orderId: orderId,
                     orderCode: orderCode,
                     totalPrice: totalPrice,
                     createdAt: formatter.date(from: createdAt) ?? Date(),
                     updatedAt: formatter.date(from: updatedAt) ?? Date()
        )
    }
}
