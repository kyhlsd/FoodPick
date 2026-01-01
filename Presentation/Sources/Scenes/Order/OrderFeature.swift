//
//  OrderFeature.swift
//  Presentation
//
//  Created by 김영훈 on 1/1/26.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct OrderFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        var orders: [Order] = []
        var isLoading = false

        var currentOrders: [Order] {
            orders.filter { $0.currentOrderStatus != .pickedUp }
        }

        var pastOrders: [Order] {
            orders.filter { $0.currentOrderStatus == .pickedUp }
        }

        @Presents var alert: AlertState<OrderFeature.Alert>?
    }

    // MARK: - Action
    enum Action {
        case onAppear
        case fetchOrders
        case ordersLoaded([Order])
        case ordersFailed(Error)
        case alert(PresentationAction<OrderFeature.Alert>)
    }

    // MARK: - Dependencies
    @Dependency(\.fetchOrders) var fetchOrdersUseCase

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchOrders)

            case .fetchOrders:
                guard !state.isLoading else { return .none }
                state.isLoading = true

                return .run { send in
                    do {
                        let orders = try await fetchOrdersUseCase.execute()
                        await send(.ordersLoaded(orders))
                    } catch {
                        await send(.ordersFailed(error))
                    }
                }

            case let .ordersLoaded(orders):
                state.isLoading = false
                state.orders = orders
                return .none

            case let .ordersFailed(error):
                state.isLoading = false
                state.alert = AlertState {
                    TextState("주문 로드 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    enum Alert: Sendable {}
}
