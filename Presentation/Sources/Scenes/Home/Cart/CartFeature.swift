//
//  CartFeature.swift
//  Presentation
//
//  Created by 김영훈 on 12/27/25.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct CartFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        var cartItems: [(menu: Menu, quantity: Int)] = []

        var cartTotalPrice: Int {
            cartItems.reduce(0) { $0 + ($1.menu.price * $1.quantity) }
        }

        var cartTotalCount: Int {
            cartItems.reduce(0) { $0 + $1.quantity }
        }

        @Presents var destination: Destination.State?
        @Presents var alert: AlertState<CartFeature.Alert>?
    }

    // MARK: - Action
    enum Action: Sendable {
        case quantityIncreased(menuId: String)
        case quantityDecreased(menuId: String)
        case removeFromCart(menuId: String)
        case checkoutTapped
        case orderCreated(OrderResponse)
        case orderCreationFailed(Error)
        case destination(PresentationAction<Destination.Action>)
        case alert(PresentationAction<CartFeature.Alert>)
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.createOrder) var createOrderUseCase
    @Dependency(\.createPaymentRequest) var createPaymentRequestUseCase

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .quantityIncreased(menuId):
                if let index = state.cartItems.firstIndex(where: { $0.menu.menuId == menuId }) {
                    state.cartItems[index].quantity += 1
                }
                return .none

            case let .quantityDecreased(menuId):
                if let index = state.cartItems.firstIndex(where: { $0.menu.menuId == menuId }) {
                    if state.cartItems[index].quantity > 1 {
                        state.cartItems[index].quantity -= 1
                    }
                }
                return .none

            case let .removeFromCart(menuId):
                state.cartItems.removeAll { $0.menu.menuId == menuId }
                return .none

            case .checkoutTapped:
                guard let restaurantId = state.cartItems.first?.menu.restaurantId else {
                    return .none
                }

                // 주문 요청 생성
                let orderMenuList = state.cartItems.map { item in
                    MenuRequest(menuId: item.menu.menuId, quantity: item.quantity)
                }
                let orderRequest = OrderRequest(
                    restaurantId: restaurantId,
                    orderMenuList: orderMenuList,
                    totalPrice: state.cartTotalPrice
                )

                // 주문 생성
                return .run { send in
                    do {
                        let orderResponse = try await createOrderUseCase.execute(request: orderRequest)
                        await send(.orderCreated(orderResponse))
                    } catch {
                        await send(.orderCreationFailed(error))
                    }
                }

            case let .orderCreated(orderResponse):
                // 주문 생성 성공 - 결제 요청 생성
                let menuNames = state.cartItems.map { $0.menu.name }
                let paymentRequest = createPaymentRequestUseCase.execute(
                    orderCode: orderResponse.orderCode,
                    menuNames: menuNames,
                    totalAmount: orderResponse.totalPrice
                )

                state.destination = .payment(PaymentFeature.State(paymentRequest: paymentRequest))
                return .none

            case let .orderCreationFailed(error):
                // 주문 생성 실패
                state.alert = AlertState {
                    TextState("주문 생성 실패")
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

            case .destination(.presented(.payment(.paymentSuccessConfirmed))):
                // 결제 성공 - 장바구니 초기화하고 화면 닫기
                state.cartItems = []
                return .run { _ in
                    await dismiss()
                }

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$alert, action: \.alert)
    }

    enum Alert: Sendable {}
}

// MARK: - Destinations
extension CartFeature {
    @Reducer
    enum Destination {
        case payment(PaymentFeature)
    }
}

extension CartFeature.Destination.State: Sendable {}
