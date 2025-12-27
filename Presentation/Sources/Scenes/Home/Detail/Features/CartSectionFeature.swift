//
//  CartSectionFeature.swift
//  Presentation
//
//  Created by 김영훈 on 12/27/25.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct CartSectionFeature: Sendable {
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
    }

    // MARK: - Action
    enum Action: Sendable {
        case addToCart(menu: Menu, quantity: Int)
        case removeFromCart(menuId: String)
        case updateQuantity(menuId: String, quantity: Int)
        case clearCart
        case viewCartTapped
        case checkoutTapped
    }

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .addToCart(menu, quantity):
                // 이미 장바구니에 있는 메뉴인지 확인
                if let index = state.cartItems.firstIndex(where: { $0.menu.menuId == menu.menuId }) {
                    // 수량 증가
                    state.cartItems[index].quantity += quantity
                } else {
                    // 새로운 메뉴 추가
                    state.cartItems.append((menu: menu, quantity: quantity))
                }
                return .none

            case let .removeFromCart(menuId):
                state.cartItems.removeAll { $0.menu.menuId == menuId }
                return .none

            case let .updateQuantity(menuId, quantity):
                if let index = state.cartItems.firstIndex(where: { $0.menu.menuId == menuId }) {
                    if quantity > 0 {
                        state.cartItems[index].quantity = quantity
                    } else {
                        state.cartItems.remove(at: index)
                    }
                }
                return .none

            case .clearCart:
                state.cartItems = []
                return .none

            case .viewCartTapped:
                // 장바구니 화면으로 이동 (부모 리듀서에서 처리)
                return .none

            case .checkoutTapped:
                // 결제 로직 (추후 구현)
                return .none
            }
        }
    }
}
