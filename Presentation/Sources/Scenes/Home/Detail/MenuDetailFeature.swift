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

        var totalPrice: Int {
            menu.price * quantity
        }
    }

    // MARK: - Action
    enum Action {
        case quantityIncreased
        case quantityDecreased
    }

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .quantityIncreased:
                state.quantity += 1
                return .none

            case .quantityDecreased:
                if state.quantity > 1 {
                    state.quantity -= 1
                }
                return .none
            }
        }
    }
}
