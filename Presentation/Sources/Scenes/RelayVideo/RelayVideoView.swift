//
//  RelayVideoView.swift
//  Presentation
//
//  Created by 김영훈 on 12/20/25.
//

import SwiftUI
import ComposableArchitecture

struct RelayVideoView: View {
    let store: StoreOf<RelayVideoFeature>

    init(store: StoreOf<RelayVideoFeature>) {
        self.store = store
    }

    var body: some View {
        WithPerceptionTracking {
            // 임시 뷰 - 추후 제대로 된 Pick 화면으로 교체
            Text("Temp")
        }
    }
}

#Preview {
    RelayVideoView(
        store: Store(initialState: RelayVideoFeature.State()) {
            RelayVideoFeature()
        }
    )
}
