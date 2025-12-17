//
//  CreateOrderUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public protocol CreateOrderUseCase: Sendable {
    func execute(request: OrderRequest) async throws -> OrderResponse
}

public final class CreateOrderUseCaseImpl: CreateOrderUseCase, @unchecked Sendable {
    private let orderRepository: OrderRepository

    public init(orderRepository: OrderRepository) {
        self.orderRepository = orderRepository
    }

    public func execute(request: OrderRequest) async throws -> OrderResponse {
        return try await orderRepository.createOrder(request: request)
    }
}
