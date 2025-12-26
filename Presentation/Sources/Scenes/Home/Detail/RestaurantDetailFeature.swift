//
//  RestaurantDetailFeature.swift
//  Presentation
//
//  Created by 김영훈 on 12/26/25.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct RestaurantDetailFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        let restaurantId: String
        var restaurantInfo: RestaurantDetail?
        var isLoading = false
        var currentImageIndex = 0
        var selectedMenuCategory: String?
        var isSearching = false
        var menuSearchText = ""

        @Presents var alert: AlertState<RestaurantDetailFeature.Alert>?
        @Presents var destination: Destination.State?

        var menuCategories: [String] {
            guard let restaurantInfo = restaurantInfo else { return [] }
            let categories = Set(restaurantInfo.menuList.map { $0.category })
            return categories.sorted()
        }

        var filteredMenuList: [Menu] {
            guard let restaurantInfo = restaurantInfo else { return [] }

            // "검색한 메뉴" 카테고리이고 검색어가 있는 경우
            if selectedMenuCategory == "검색한 메뉴", !menuSearchText.isEmpty {
                return restaurantInfo.menuList.filter { menu in
                    menu.name.localizedCaseInsensitiveContains(menuSearchText) ||
                    menu.description.localizedCaseInsensitiveContains(menuSearchText) ||
                    menu.category.localizedCaseInsensitiveContains(menuSearchText) ||
                    menu.originInfo.localizedCaseInsensitiveContains(menuSearchText)
                }
            }

            // 다른 카테고리 선택 시
            if let selectedMenuCategory = selectedMenuCategory, selectedMenuCategory != "검색한 메뉴" {
                return restaurantInfo.menuList.filter { $0.category == selectedMenuCategory }
            }

            // 카테고리 선택 안 한 경우 전체
            return restaurantInfo.menuList
        }

        var menuCategoryTitle: String? {
            // "검색한 메뉴" 선택 시
            if selectedMenuCategory == "검색한 메뉴", !menuSearchText.isEmpty {
                return "\(menuSearchText)(으)로 검색한 메뉴"
            }

            // 다른 카테고리 선택 시
            if let selectedMenuCategory = selectedMenuCategory, selectedMenuCategory != "검색한 메뉴" {
                return selectedMenuCategory
            }

            // 전체 (선택 안 함)
            return nil
        }
    }

    // MARK: - Action
    enum Action {
        case onAppear
        case fetchRestaurantInfo
        case restaurantInfoLoaded(RestaurantDetail)
        case restaurantInfoLoadFailed(Error)
        case imageIndexChanged(Int)
        case toggleRestaurantLike
        case restaurantLikeToggled(LikeStatus)
        case restaurantLikeToggleFailed(Error)
        case menuCategorySelected(String)
        case toggleMenuSearch
        case menuSearchTextChanged(String)
        case menuSearchSubmitted
        case menuTapped(Menu)
        case alert(PresentationAction<RestaurantDetailFeature.Alert>)
        case destination(PresentationAction<Destination.Action>)
    }

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchRestaurantInfo)

            case .fetchRestaurantInfo:
                state.isLoading = true
                return .run { [restaurantId = state.restaurantId] send in
                    do {
                        let restaurantInfo = try await fetchRestaurantInfoUseCase.execute(id: restaurantId)
                        await send(.restaurantInfoLoaded(restaurantInfo))
                    } catch {
                        await send(.restaurantInfoLoadFailed(error))
                    }
                }

            case let .restaurantInfoLoaded(restaurantInfo):
                state.isLoading = false
                state.restaurantInfo = restaurantInfo
                return .none

            case let .restaurantInfoLoadFailed(error):
                state.isLoading = false
                state.alert = AlertState {
                    TextState("가게 정보 로드 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case let .imageIndexChanged(index):
                state.currentImageIndex = index
                return .none

            case .toggleRestaurantLike:
                guard let currentLikeStatus = state.restaurantInfo?.isPick else { return .none }
                let newLikeStatus = !currentLikeStatus
                return .run { [restaurantId = state.restaurantId] send in
                    do {
                        let likeStatus = try await toggleRestaurantLikeUseCase.execute(id: restaurantId,
                                                                                       like: newLikeStatus)
                        await send(.restaurantLikeToggled(likeStatus))
                    } catch {
                        await send(.restaurantLikeToggleFailed(error))
                    }
                }

            case let .restaurantLikeToggled(likeStatus):
                if var restaurantInfo = state.restaurantInfo {
                    restaurantInfo.isPick = likeStatus.likeStatus
                    restaurantInfo.pickCount += likeStatus.likeStatus ? 1 : -1
                    state.restaurantInfo = restaurantInfo
                }
                return .none

            case let .restaurantLikeToggleFailed(error):
                state.alert = AlertState {
                    TextState("좋아요 변경 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case let .menuCategorySelected(category):
                // 이미 선택된 카테고리를 다시 누르면 선택 해제
                if state.selectedMenuCategory == category {
                    state.selectedMenuCategory = nil
                } else {
                    state.selectedMenuCategory = category
                }
                // 다른 카테고리 선택 시 검색 모드 종료 (검색어는 유지)
                state.isSearching = false
                return .none

            case .toggleMenuSearch:
                // 이미 검색 모드일 때 다시 누르면 검색 해제
                if state.isSearching {
                    state.isSearching = false
                    state.selectedMenuCategory = nil
                    state.menuSearchText = ""
                } else {
                    state.isSearching = true
                    state.selectedMenuCategory = "검색한 메뉴"
                }
                return .none

            case let .menuSearchTextChanged(text):
                state.menuSearchText = text
                return .none

            case .menuSearchSubmitted:
                guard !state.menuSearchText.isEmpty else { return .none }
                // 검색 제출 시 "검색한 메뉴" 카테고리로 변경
                state.selectedMenuCategory = "검색한 메뉴"
                return .none

            case let .menuTapped(menu):
                state.destination = .menuDetail(MenuDetailFeature.State(menu: menu))
                return .none

            case .alert:
                return .none

            case .destination:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        .ifLet(\.$destination, action: \.destination)
    }

    // MARK: - Dependencies
    @Dependency(\.fetchRestaurantInfo) var fetchRestaurantInfoUseCase
    @Dependency(\.toggleRestaurantLike) var toggleRestaurantLikeUseCase

    enum Alert: Sendable {}
}

// MARK: - Destinations
extension RestaurantDetailFeature {
    @Reducer
    enum Destination {
        case menuDetail(MenuDetailFeature)
    }
}

extension RestaurantDetailFeature.Destination.State: Sendable {}
