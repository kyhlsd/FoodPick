//
//  UpdateOrderStatusUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public protocol UpdateOrderStatusUseCase: Sendable {
    func execute(code: String, status: OrderStatus) async throws
}

public final class UpdateOrderStatusUseCaseImpl: UpdateOrderStatusUseCase, @unchecked Sendable {
    private let orderRepository: OrderRepository

    public init(orderRepository: OrderRepository) {
        self.orderRepository = orderRepository
    }

    public func execute(code: String, status: OrderStatus) async throws {
        try await orderRepository.updateOrderStatus(code: code, status: status)
    }
}
