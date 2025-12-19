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
                ContentView()

            case .loggedOut:
                NavigationStack {
                    if let loginStore = store.scope(state: \.loggedOut, action: \.loggedOut) {
                        LoginView(store: loginStore)
                    }
                }
            }
        }
        .onOpenURL { url in
            store.send(.handleOpenURL(url))
        }
    }
}
