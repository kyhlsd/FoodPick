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
    }

    // MARK: - Action
    enum Action: Sendable {
        case quantityIncreased(menuId: String)
        case quantityDecreased(menuId: String)
        case removeFromCart(menuId: String)
        case checkoutTapped
    }

    @Dependency(\.dismiss) var dismiss

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
                // TODO: 결제 화면으로 이동
                return .none
            }
        }
    }
}
