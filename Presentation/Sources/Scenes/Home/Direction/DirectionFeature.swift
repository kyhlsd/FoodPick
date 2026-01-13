//
//  DirectionFeature.swift
//  Presentation
//
//  Created by 김영훈 on 1/13/26.
//

import Domain
import ComposableArchitecture

@Reducer
struct DirectionFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        var isLoading = true
        let restaurantLocation: Geolocation
        var myLocation: Geolocation?
        
        var centerCoordinate: (longitude: Double, latitude: Double) {
            return (Double(restaurantLocation.longitude), Double(restaurantLocation.latitude))
        }
    }
    
    // MARK: - Action
    enum Action {
        case onAppear
        case mapInitialized
        case dismiss
    }
    
    // MARK: - Dependencies
    @Dependency(\.getUserLocation) var getUserLocation
    @Dependency(\.dismiss) var dismiss
    
    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.myLocation = getUserLocation.execute().geolocation
                return .none
                
            case .mapInitialized:
                state.isLoading = false
                return .none
                
            case .dismiss:
                return .run { _ in
                    await self.dismiss()
                }
            }
        }
    }
    
    enum Alert: Sendable {}
}
