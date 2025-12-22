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
        var selectedCategory: StoreCategory?
        var isShowingAllCategories = false
    }

    // MARK: - Action
    enum Action {
        case searchTextChanged(String)
        case searchSubmitted
        case onAppear
        case trendingTimerTick
        case setTrendingSearches([String])
        case trendingSearchTapped(String)
        case categorySelected(StoreCategory?)
        case toggleCategoryExpansion
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
                let mockData = ["스타벅스", "투썸플레이스", "메가커피", "이디야", "할리스"]
                return .send(.setTrendingSearches(mockData))

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
                // 카테고리 필터링 로직
                print("선택된 카테고리: \(category?.rawValue ?? "전체")")
                return .none

            case .toggleCategoryExpansion:
                state.isShowingAllCategories.toggle()
                return .none
            }
        }
    }
    
    // MARK: - Dependencies
    @Dependency(\.continuousClock) var clock
    
    enum Alert: Sendable {}
}

// MARK: - Destinations
extension HomeFeature {
    @Reducer
    enum Destination {
        
    }
}
