//
//  HomeFeature.swift
//  Presentation
//
//  Created by 김영훈 on 12/22/25.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct HomeFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        var searchText = ""
        var trendingSearches: [String] = []
        var currentTrendingIndex = 0
        var selectedCategory: RestaurantCategory?
        var isShowingAllCategories = false
        var popularRestaurants: [Restaurant] = []
        var isLoadingPopularRestaurants = false
    }

    // MARK: - Action
    enum Action {
        case searchTextChanged(String)
        case searchSubmitted
        case onAppear
        case trendingTimerTick
        case setTrendingSearches([String])
        case trendingSearchTapped(String)
        case categorySelected(RestaurantCategory?)
        case toggleCategoryExpansion
        case fetchPopularRestaurants
        case popularRestaurantsLoaded([Restaurant])
        case popularRestaurantsLoadFailed(Error)
        case fetchPopularSearches
        case popularSearchesLoaded([String])
        case popularSearchesLoadFailed(Error)
    }

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .searchTextChanged(text):
                state.searchText = text
                return .none

            case .searchSubmitted:
                // 검색 실행 로직
                print("검색어: \(state.searchText)")
                return .none

            case let .trendingSearchTapped(keyword):
                state.searchText = keyword
                return .send(.searchSubmitted)

            case .onAppear:
                return .merge(
                    .send(.fetchPopularSearches),
                    .send(.fetchPopularRestaurants)
                )

            case let .setTrendingSearches(searches):
                state.trendingSearches = searches
                state.currentTrendingIndex = 0
                return .run { send in
                    for await _ in self.clock.timer(interval: .seconds(2)) {
                        await send(.trendingTimerTick)
                    }
                }

            case .trendingTimerTick:
                guard !state.trendingSearches.isEmpty else { return .none }
                state.currentTrendingIndex += 1
                return .none

            case let .categorySelected(category):
                state.selectedCategory = category
                return .send(.fetchPopularRestaurants)

            case .toggleCategoryExpansion:
                state.isShowingAllCategories.toggle()
                return .none

            case .fetchPopularRestaurants:
                state.isLoadingPopularRestaurants = true
                return .run { [category = state.selectedCategory] send in
                    do {
                        let restaurants = try await fetchPopularRestaurantsUseCase.execute(category: category)
                        await send(.popularRestaurantsLoaded(restaurants))
                    } catch {
                        await send(.popularRestaurantsLoadFailed(error))
                    }
                }

            case let .popularRestaurantsLoaded(restaurants):
                state.isLoadingPopularRestaurants = false
                state.popularRestaurants = restaurants
                return .none

            case let .popularRestaurantsLoadFailed(error):
                state.isLoadingPopularRestaurants = false
                print("인기 가게 로드 실패: \(error)")
                return .none

            case .fetchPopularSearches:
                return .run { send in
                    do {
                        let searches = try await fetchPopularSearchesUseCase.execute()
                        await send(.popularSearchesLoaded(searches))
                    } catch {
                        await send(.popularSearchesLoadFailed(error))
                    }
                }

            case let .popularSearchesLoaded(searches):
                return .send(.setTrendingSearches(searches))

            case let .popularSearchesLoadFailed(error):
                print("인기 검색어 로드 실패: \(error)")
                return .none
            }
        }
    }
    
    // MARK: - Dependencies
    @Dependency(\.continuousClock) var clock
    @Dependency(\.fetchPopularRestaurants) var fetchPopularRestaurantsUseCase
    @Dependency(\.fetchPopularSearches) var fetchPopularSearchesUseCase

    enum Alert: Sendable {}
}

// MARK: - Destinations
extension HomeFeature {
    @Reducer
    enum Destination {
        
    }
}
