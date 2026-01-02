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
        @Presents var destination: Destination.State?
    }

    // MARK: - Action
    enum Action {
        case onAppear
        case fetchOrders
        case ordersLoaded([Order])
        case ordersFailed(Error)
        case alert(PresentationAction<OrderFeature.Alert>)
        case writeReviewTapped(restaurantId: String, orderCode: String)
        case viewReviewDetailTapped(restaurantId: String, reviewId: String)
        case viewOrderDetailTapped(Order)
        case destination(PresentationAction<Destination.Action>)
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

            case let .writeReviewTapped(restaurantId, orderCode):
                state.destination = .reviewWrite(
                    ReviewWriteFeature.State(
                        mode: .create(restaurantId: restaurantId, orderCode: orderCode)
                    )
                )
                return .none

            case let .viewReviewDetailTapped(restaurantId, reviewId):
                state.destination = .reviewDetail(
                    ReviewDetailFeature.State(
                        restaurantId: restaurantId,
                        reviewId: reviewId
                    )
                )
                return .none

            case let .viewOrderDetailTapped(order):
                state.destination = .orderDetail(
                    OrderDetailFeature.State(order: order)
                )
                return .none

            case .alert, .destination:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        .ifLet(\.$destination, action: \.destination) {
            Destination.body
        }
    }

    enum Alert: Sendable {}

    // MARK: - Destination
    @Reducer
    enum Destination: Sendable {
        case reviewWrite(ReviewWriteFeature)
        case reviewDetail(ReviewDetailFeature)
        case orderDetail(OrderDetailFeature)
    }
}
