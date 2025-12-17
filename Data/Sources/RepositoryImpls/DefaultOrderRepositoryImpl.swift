//
//  DefaultOrderRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Domain

public final class DefaultOrderRepositoryImpl: OrderRepository, @unchecked Sendable {
    private let networkManager = NetworkManager.shared

    public init() {}

    public func createOrder(request: OrderRequest) async throws -> OrderResponse {
        guard let response = try await networkManager.request(
            OrderRouter.order(dto: .init(from: request)),
            responseType: OrderResponseDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func fetchOrders() async throws -> [Order] {
        guard let response = try await networkManager.request(
            OrderRouter.fetch,
            responseType: ResponseListDTO<OrderDTO>.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func updateOrderStatus(code: String, status: OrderStatus) async throws {
        try await networkManager.request(
            OrderRouter.edit(code: code, status: .init(from: status))
        )
    }
}
