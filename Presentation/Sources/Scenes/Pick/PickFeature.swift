//
//  PickFeature.swift
//  Presentation
//
//  Created by Claude on 12/20/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct PickFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        // 임시 상태
    }

    // MARK: - Action
    enum Action: Sendable {
        // 임시 액션
    }

    init() {}

    // MARK: - Body
    var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
