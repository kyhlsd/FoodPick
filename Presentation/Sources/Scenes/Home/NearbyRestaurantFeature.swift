//
//  NearbyRestaurantFeature.swift
//  Presentation
//
//  Created by 김영훈 on 12/25/25.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct NearbyRestaurantFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        var restaurants: [Restaurant] = []
        var nextCursor: String?
        var isLoading = false
        var isLoadingMore = false
        var orderBy: RestaurantOrderBy = .distance
        var isShowingOrderByMenu = false
        var isPicchelinFilterEnabled = false
        var isMyPickFilterEnabled = false
        
        var canLoadMore: Bool {
            !isLoadingMore && nextCursor != "0" && nextCursor != nil
        }
        
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
        case fetch(category: RestaurantCategory?)
        case loadMore(category: RestaurantCategory?)
        case restaurantsLoaded(ResponseListWithCursor<Restaurant>, isLoadingMore: Bool)
        case restaurantsLoadFailed(Error)
        case orderByChanged(RestaurantOrderBy)
        case toggleOrderByMenu
        case togglePicchelinFilter
        case toggleMyPickFilter
        case updateRestaurantLikeStatus(String, Bool, Int)
    }
    
    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .fetch(category):
                state.isLoading = true
                state.nextCursor = nil
                
                let orderBy = state.orderBy
                
                return .run { send in
                    do {
                        let request = RestaurantByLocationRequest(
                            category: category,
                            longitude: nil,
                            latitude: nil,
                            maxDistance: nil,
                            next: nil,
                            limit: 10,
                            orderBy: orderBy
                        )
                        let response = try await fetchRestaurantsUseCase.execute(request: request)
                        await send(.restaurantsLoaded(response, isLoadingMore: false))
                    } catch {
                        await send(.restaurantsLoadFailed(error))
                    }
                }
                
            case let .loadMore(category):
                guard state.canLoadMore else { return .none }
                state.isLoadingMore = true
                
                let orderBy = state.orderBy
                let cursor = state.nextCursor
                
                return .run { send in
                    do {
                        let request = RestaurantByLocationRequest(
                            category: category,
                            longitude: nil,
                            latitude: nil,
                            maxDistance: nil,
                            next: cursor,
                            limit: 10,
                            orderBy: orderBy
                        )
                        let response = try await fetchRestaurantsUseCase.execute(request: request)
                        await send(.restaurantsLoaded(response, isLoadingMore: true))
                    } catch {
                        await send(.restaurantsLoadFailed(error))
                    }
                }
                
            case let .restaurantsLoaded(response, isLoadingMore):
                state.isLoading = false
                state.isLoadingMore = false
                state.nextCursor = response.nextCursor
                
                if isLoadingMore {
                    state.restaurants.append(contentsOf: response.data)
                } else {
                    state.restaurants = response.data
                }
                return .none
                
            case .restaurantsLoadFailed:
                state.isLoading = false
                state.isLoadingMore = false
                return .none
                
            case let .orderByChanged(orderBy):
                state.orderBy = orderBy
                state.isShowingOrderByMenu = false
                return .none
                
            case .toggleOrderByMenu:
                state.isShowingOrderByMenu.toggle()
                return .none
                
            case .togglePicchelinFilter:
                state.isPicchelinFilterEnabled.toggle()
                return .none
                
            case .toggleMyPickFilter:
                state.isMyPickFilterEnabled.toggle()
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
    @Dependency(\.fetchRestaurants) var fetchRestaurantsUseCase
}
