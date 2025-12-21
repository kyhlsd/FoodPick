//
//  RootView.swift
//  Presentation
//
//  Created by 김영훈 on 12/19/25.
//

import SwiftUI
import ComposableArchitecture

public struct RootView: View {
    let store: StoreOf<RootFeature>

    public init() {
        self.store = Store(initialState: RootFeature.State.loading) {
            RootFeature()
        }
    }

    public var body: some View {
        WithPerceptionTracking {
            switch store.state {
            case .loading:
                ProgressView()
                    .onAppear {
                        store.send(.onAppear)
                    }

            case .loggedIn:
                TabBarView(
                    store: Store(initialState: TabBarFeature.State()) {
                        TabBarFeature()
                    }
                )

            case .loggedOut:
                NavigationStack {
                    LoginView(
                        store: Store(initialState: LoginFeature.State()) {
                            LoginFeature()
                        }
                    )
                }
            }
        }
        .onOpenURL { url in
            store.send(.handleOpenURL(url))
        }
    }
}
