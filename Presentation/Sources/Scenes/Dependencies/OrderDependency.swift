//
//  OrderDependency.swift
//  Presentation
//
//  Created by 김영훈 on 12/19/25.
//

import Domain
import Data
import ComposableArchitecture

extension DependencyValues {

    // MARK: - Repository
    var orderRepository: OrderRepository {
        get { self[OrderRepositoryKey.self] }
        set { self[OrderRepositoryKey.self] = newValue }
    }

    // MARK: - UseCases
    var createOrder: CreateOrderUseCase {
        get { self[CreateOrderKey.self] }
        set { self[CreateOrderKey.self] = newValue }
    }

    var fetchOrders: FetchOrdersUseCase {
        get { self[FetchOrdersKey.self] }
        set { self[FetchOrdersKey.self] = newValue }
    }

    var updateOrderStatus: UpdateOrderStatusUseCase {
        get { self[UpdateOrderStatusKey.self] }
        set { self[UpdateOrderStatusKey.self] = newValue }
    }
}

// MARK: - Keys
private enum OrderRepositoryKey: DependencyKey {
    static let liveValue: OrderRepository = DefaultOrderRepositoryImpl()
}

private enum CreateOrderKey: DependencyKey {
    static let liveValue: CreateOrderUseCase = {
        @Dependency(\.orderRepository) var orderRepository
        return CreateOrderUseCaseImpl(orderRepository: orderRepository)
    }()
}

private enum FetchOrdersKey: DependencyKey {
    static let liveValue: FetchOrdersUseCase = {
        @Dependency(\.orderRepository) var orderRepository
        return FetchOrdersUseCaseImpl(orderRepository: orderRepository)
    }()
}

private enum UpdateOrderStatusKey: DependencyKey {
    static let liveValue: UpdateOrderStatusUseCase = {
        @Dependency(\.orderRepository) var orderRepository
        return UpdateOrderStatusUseCaseImpl(orderRepository: orderRepository)
    }()
}
