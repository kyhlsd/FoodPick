//
//  OrderDetailFeature.swift
//  Presentation
//
//  Created by 김영훈 on 1/2/26.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct OrderDetailFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        let order: Order

        @Presents var alert: AlertState<OrderDetailFeature.Alert>?
    }

    // MARK: - Action
    enum Action {
        case alert(PresentationAction<OrderDetailFeature.Alert>)
    }

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    enum Alert: Sendable {}
}
