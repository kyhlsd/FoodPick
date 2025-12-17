//
//  FetchOrdersUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public protocol FetchOrdersUseCase: Sendable {
    func execute() async throws -> [Order]
}

public final class FetchOrdersUseCaseImpl: FetchOrdersUseCase, @unchecked Sendable {
    private let orderRepository: OrderRepository

    public init(orderRepository: OrderRepository) {
        self.orderRepository = orderRepository
    }

    public func execute() async throws -> [Order] {
        return try await orderRepository.fetchOrders()
    }
}
