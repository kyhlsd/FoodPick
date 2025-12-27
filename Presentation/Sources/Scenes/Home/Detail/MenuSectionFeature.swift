//
//  MenuSectionFeature.swift
//  Presentation
//
//  Created by 김영훈 on 12/27/25.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct MenuSectionFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        var restaurantInfo: RestaurantDetail?
        var selectedMenuCategory: String?
        var isSearching = false
        var menuSearchText = ""

        // Computed properties
        var menuCategories: [String] {
            guard let restaurantInfo else { return [] }
            let categories = Set(restaurantInfo.menuList.map { $0.category })
            return Array(categories).sorted()
        }

        var filteredMenuList: [Menu] {
            guard let restaurantInfo else { return [] }

            if isSearching {
                // 검색 모드: 검색어로 필터링
                if menuSearchText.isEmpty {
                    return restaurantInfo.menuList
                }
                return restaurantInfo.menuList.filter {
                    $0.name.localizedCaseInsensitiveContains(menuSearchText)
                }
            } else {
                // 카테고리 모드
                guard let selectedCategory = selectedMenuCategory else {
                    return restaurantInfo.menuList
                }
                return restaurantInfo.menuList.filter { $0.category == selectedCategory }
            }
        }

        var menuCategoryTitle: String? {
            if isSearching {
                if menuSearchText.isEmpty {
                    return "전체 메뉴"
                }
                return "검색한 메뉴: \(menuSearchText)"
            } else {
                return selectedMenuCategory
            }
        }
    }

    // MARK: - Action
    enum Action {
        case menuCategorySelected(String)
        case toggleMenuSearch
        case menuSearchTextChanged(String)
        case menuSearchSubmitted
        case menuTapped(Menu)
    }

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .menuCategorySelected(category):
                state.selectedMenuCategory = category
                state.isSearching = false
                state.menuSearchText = ""
                return .none

            case .toggleMenuSearch:
                state.isSearching.toggle()
                if state.isSearching {
                    state.selectedMenuCategory = nil
                } else {
                    state.menuSearchText = ""
                    // 검색 종료 시 첫 번째 카테고리 선택
                    if let firstCategory = state.menuCategories.first {
                        state.selectedMenuCategory = firstCategory
                    }
                }
                return .none

            case let .menuSearchTextChanged(text):
                state.menuSearchText = text
                return .none

            case .menuSearchSubmitted:
                return .none

            case .menuTapped:
                // 부모 리듀서에서 처리
                return .none
            }
        }
    }
}
