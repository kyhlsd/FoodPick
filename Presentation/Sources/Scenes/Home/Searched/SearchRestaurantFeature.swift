//
//  SearchRestaurantFeature.swift
//  Presentation
//
//  Created by 김영훈 on 12/25/25.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct SearchRestaurantFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        var searchWord: String
        var restaurants: [Restaurant] = []
        var isLoading = false
        var isPicchelinFilterEnabled = false
        var isMyPickFilterEnabled = false

        var filteredRestaurants: [Restaurant] {
            var filtered = restaurants

            if isPicchelinFilterEnabled {
                filtered = filtered.filter { $0.isPicchelin }
            }

            if isMyPickFilterEnabled {
                filtered = filtered.filter { $0.isPick }
            }

            return filtered
        }
    }

    // MARK: - Action
    enum Action {
        case onAppear
        case search
        case restaurantsLoaded([Restaurant])
        case restaurantsLoadFailed(Error)
        case togglePicchelinFilter
        case toggleMyPickFilter
        case toggleRestaurantLike(String, Bool)
        case restaurantLikeToggled(String, LikeStatus)
        case restaurantLikeToggleFailed(Error)
        case updateRestaurantLikeStatus(String, Bool, Int)
    }

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.search)

            case .search:
                state.isLoading = true
                let searchWord = state.searchWord

                return .run { send in
                    do {
                        let restaurants = try await searchRestaurantsUseCase.execute(name: searchWord)
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

            case .togglePicchelinFilter:
                state.isPicchelinFilterEnabled.toggle()
                return .none

            case .toggleMyPickFilter:
                state.isMyPickFilterEnabled.toggle()
                return .none

            case let .toggleRestaurantLike(id, like):
                return .run { send in
                    do {
                        let likeStatus = try await toggleRestaurantLikeUseCase.execute(id: id, like: like)
                        await send(.restaurantLikeToggled(id, likeStatus))
                    } catch {
                        await send(.restaurantLikeToggleFailed(error))
                    }
                }

            case let .restaurantLikeToggled(id, likeStatus):
                let isPick = likeStatus.likeStatus

                if let index = state.restaurants.firstIndex(where: { $0.restaurantId == id }) {
                    let restaurant = state.restaurants[index]
                    let pickCount = restaurant.pickCount + (isPick ? 1 : -1)
                    state.restaurants[index].isPick = isPick
                    state.restaurants[index].pickCount = pickCount
                }
                return .none

            case .restaurantLikeToggleFailed:
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
    @Dependency(\.searchRestaurants) var searchRestaurantsUseCase
    @Dependency(\.toggleRestaurantLike) var toggleRestaurantLikeUseCase
}
