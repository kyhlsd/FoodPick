//
//  MenuDetailFeature.swift
//  Presentation
//
//  Created by 김영훈 on 12/26/25.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct MenuDetailFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        let menu: Menu
        var quantity: Int = 1
        var isInCart: Bool = false

        var totalPrice: Int {
            menu.price * quantity
        }
    }

    // MARK: - Action
    enum Action: Sendable {
        case quantityIncreased
        case quantityDecreased
        case addToCartTapped
    }

    @Dependency(\.dismiss) var dismiss

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .quantityIncreased:
                state.quantity += 1
                return .none

            case .quantityDecreased:
                // 장바구니에 담긴 메뉴(수정 모드)인 경우 0까지 감소 가능
                // 새로 담는 메뉴인 경우 최소 1개
                let minimumQuantity = state.isInCart ? 0 : 1
                if state.quantity > minimumQuantity {
                    state.quantity -= 1
                }
                return .none

            case .addToCartTapped:
                return .run { _ in
                    await dismiss()
                }
            }
        }
    }
}
