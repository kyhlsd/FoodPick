//
//  PopularRestaurantFeature.swift
//  Presentation
//
//  Created by 김영훈 on 12/25/25.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct PopularRestaurantFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        var restaurants: [Restaurant] = []
        var isLoading = false
    }

    // MARK: - Action
    enum Action {
        case fetch(category: RestaurantCategory?)
        case restaurantsLoaded([Restaurant])
        case restaurantsLoadFailed(Error)
        case updateRestaurantLikeStatus(String, Bool, Int)
    }

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .fetch(category):
                state.isLoading = true
                return .run { send in
                    do {
                        let restaurants = try await fetchPopularRestaurantsUseCase.execute(category: category)
                        await send(.restaurantsLoaded(restaurants))
                    } catch {
                        await send(.restaurantsLoadFailed(error))
                    }
                }

            case let .restaurantsLoaded(restaurants):
                state.isLoading = false
                state.restaurants = restaurants
                return .none

            case .restaurantsLoadFailed:
                state.isLoading = false
                return .none

            case let .updateRestaurantLikeStatus(id, isPick, pickCount):
                if let index = state.restaurants.firstIndex(where: { $0.restaurantId == id }) {
                    state.restaurants[index].isPick = isPick
                    state.restaurants[index].pickCount = pickCount
                }
                return .none
            }
        }
    }

    // MARK: - Dependencies
    @Dependency(\.fetchPopularRestaurants) var fetchPopularRestaurantsUseCase
}
