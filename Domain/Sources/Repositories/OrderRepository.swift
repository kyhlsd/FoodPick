//
//  OrderRepository.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public protocol OrderRepository: Sendable {
    func createOrder(request: OrderRequest) async throws -> OrderResponse
    func fetchOrders() async throws -> [Order]
    func updateOrderStatus(code: String, status: OrderStatus) async throws
}
