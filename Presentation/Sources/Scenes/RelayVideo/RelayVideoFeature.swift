//
//  RelayVideoFeature.swift
//  Presentation
//
//  Created by 김영훈 on 12/20/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct RelayVideoFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        // 임시 상태
    }

    // MARK: - Action
    enum Action: Sendable {
        // 임시 액션
    }

    // MARK: - Body
    var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
