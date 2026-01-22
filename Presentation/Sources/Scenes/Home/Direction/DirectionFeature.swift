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
        let restaurantInfo: RestaurantDetail
        var startGeolocation: Geolocation?
        var currentGeolocation: Geolocation?
        var isTracking = false
        var directions: DirectionResponse?
        
        var restaurantLocation: Geolocation {
            return restaurantInfo.geolocation
        }
        
        var totalTime: Int {
            directions?.features.compactMap { $0.properties.totalTime }.reduce(0, +) ?? 0
        }
        
        var totalDistance: Int {
            directions?.features.compactMap { $0.properties.totalDistance }.reduce(0, +) ?? 0
        }
        
        @Presents var alert: AlertState<DirectionFeature.Alert>?
    }
    
    // MARK: - Action
    enum Action {
        case onAppear
        case mapInitialized
        case trackingTapped
        case userLocationUpdated(Geolocation)
        case fetchDirections
        case directionsLoaded(DirectionResponse)
        case directionsFailed(Error)
        case dismiss
        case alert(PresentationAction<DirectionFeature.Alert>)
    }
    
    // MARK: - Dependencies
    @Dependency(\.getUserLocation) var getUserLocation
    @Dependency(\.fetchDirections) var fetchDirections
    @Dependency(\.locationStream) var locationStream
    @Dependency(\.stopTracking) var stopTracking
    @Dependency(\.dismiss) var dismiss
    
    private enum CancelID { case tracking }
    
    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchDirections)
                
            case .mapInitialized:
                state.isLoading = false
                return .none
                
            case .trackingTapped:
                state.isTracking.toggle()
                if state.isTracking {
                    return .run { send in
                        for await location in locationStream.execute() {
                            await send(.userLocationUpdated(location))
                        }
                    }
                    .cancellable(id: CancelID.tracking)
                } else {
                    stopTracking.execute()
                    return .cancel(id: CancelID.tracking)
                }
                
            case let .userLocationUpdated(location):
                state.currentGeolocation = location
                return .none
                
            case .fetchDirections:
                let startLocation = getUserLocation.execute()
                state.startGeolocation = startLocation.geolocation
                let request = DirectionRequest(
                    startX: startLocation.geolocation.longitude,
                    startY: startLocation.geolocation.latitude,
                    endX: state.restaurantLocation.longitude,
                    endY: state.restaurantLocation.latitude,
                    startName: startLocation.address,
                    endName: state.restaurantInfo.address
                )
                return .run { send in
                    do {
                        let response = try await fetchDirections.execute(request)
                        await send(.directionsLoaded(response))
                    } catch {
                        await send(.directionsFailed(error))
                    }
                }
                
            case let .directionsLoaded(directions):
                state.directions = directions
                return .none
                
            case let .directionsFailed(error):
                state.isLoading = false
                state.alert = AlertState {
                    TextState("길찾기 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none
                
            case .dismiss:
                return .merge(
                    .cancel(id: CancelID.tracking),
                    .run { _ in
                        stopTracking.execute()
                        await dismiss()
                    }
                )
                
            case .alert:
                return .none
            }
        }
        .ifLet(\.alert, action: \.alert)
    }
    
    enum Alert: Sendable {}
}
