//
//  ChatView.swift
//  Presentation
//
//  Created by 김영훈 on 1/6/26.
//

import SwiftUI
import Domain
import ComposableArchitecture

struct ChatView: View {
    let store: StoreOf<ChatFeature>
    
    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store
            
            ZStack {
                Text(store.roomId)
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}
