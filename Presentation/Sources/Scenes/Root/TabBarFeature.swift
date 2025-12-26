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
        var home = HomeFeature.State()

        @Presents var destination: Destination.State?

        var isTabBarVisible: Bool {
            // HomeFeature의 detail이나 search destination이 있으면 탭바 숨김
            return home.destination == nil
        }
    }

    // MARK: - Action
    enum Action {
        case tabSelected(Tab)
        case centerButtonTapped
        case destination(PresentationAction<Destination.Action>)
        case home(HomeFeature.Action)
    }
    
    // MARK: - Body
    var body: some ReducerOf<Self> {
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }

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

            case .home:
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
