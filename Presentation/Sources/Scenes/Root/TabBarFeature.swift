//
//  TabBarFeature.swift
//  Presentation
//
//  Created by 김영훈 on 12/20/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct TabBarFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        var selectedTab: Tab = .home

        @Presents var destination: Destination.State?
    }

    // MARK: - Action
    enum Action {
        case tabSelected(Tab)
        case centerButtonTapped
        case destination(PresentationAction<Destination.Action>)
    }

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none

            case .centerButtonTapped:
                state.destination = .pick(PickFeature.State())
                return .none

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

// MARK: - Tab
extension TabBarFeature {
    enum Tab: CaseIterable, Sendable {
        case home
        case order
        case pick
        case community
        case profile
    }
}

// MARK: - Destinations
extension TabBarFeature {
    @Reducer
    enum Destination {
        case pick(PickFeature)
    }
}

extension TabBarFeature.Destination.State: Sendable {}
