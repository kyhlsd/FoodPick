//
//  PickView.swift
//  Presentation
//
//  Created by 김영훈 on 12/20/25.
//

import SwiftUI
import ComposableArchitecture

struct PickView: View {
    let store: StoreOf<PickFeature>

    init(store: StoreOf<PickFeature>) {
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
    PickView(
        store: Store(initialState: PickFeature.State()) {
            PickFeature()
        }
    )
}
