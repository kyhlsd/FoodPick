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
        var paymentRequest: PaymentRequest?

        var cartTotalPrice: Int {
            cartItems.reduce(0) { $0 + ($1.menu.price * $1.quantity) }
        }

        var cartTotalCount: Int {
            cartItems.reduce(0) { $0 + $1.quantity }
        }

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
        case paymentCompleted(PaymentResponse)
        case paymentValidated(ValidatePaymentResponse)
        case paymentValidationFailed(Error)
        case paymentSuccessConfirmed
        case alert(PresentationAction<CartFeature.Alert>)
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.createOrder) var createOrderUseCase
    @Dependency(\.createPaymentRequest) var createPaymentRequestUseCase
    @Dependency(\.validatePayment) var validatePaymentUseCase

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

                state.paymentRequest = paymentRequest
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

            case let .paymentCompleted(response):
                state.paymentRequest = nil

                if response.isSuccess, let impUID = response.impUID {
                    // 결제 성공 - 서버에 검증 요청
                    return .run { send in
                        do {
                            let validationResponse = try await validatePaymentUseCase.execute(impUid: impUID)
                            await send(.paymentValidated(validationResponse))
                        } catch {
                            await send(.paymentValidationFailed(error))
                        }
                    }
                } else {
                    // 결제 실패
                    state.alert = AlertState {
                        TextState("결제 실패")
                    } actions: {
                        ButtonState(role: .cancel) {
                            TextState("확인")
                        }
                    } message: {
                        TextState(response.errorMessage ?? "결제에 실패했습니다")
                    }
                    return .none
                }

            case .paymentValidated:
                // 결제 검증 성공
                state.alert = AlertState {
                    TextState("결제 완료")
                } actions: {
                    ButtonState(action: .paymentSuccessConfirmed) {
                        TextState("확인")
                    }
                } message: {
                    TextState("결제가 성공적으로 완료되었습니다")
                }
                return .none

            case let .paymentValidationFailed(error):
                state.alert = AlertState {
                    TextState("결제 검증 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case .paymentSuccessConfirmed:
                // 결제 성공 확인 - 장바구니 초기화하고 화면 닫기
                state.cartItems = []
                return .run { _ in
                    await dismiss()
                }

            case .alert(.presented(.paymentSuccessConfirmed)):
                return .send(.paymentSuccessConfirmed)

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    enum Alert: Sendable {
        case paymentSuccessConfirmed
    }
}
