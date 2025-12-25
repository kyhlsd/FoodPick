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
        var nearbyRestaurants: [Restaurant] = []
        var nearbyRestaurantsNextCursor: String?
        var isLoadingNearbyRestaurants = false
        var isLoadingMoreNearbyRestaurants = false
        var orderBy: RestaurantOrderBy = .distance
        var isShowingOrderByMenu = false
        var isPicchelinFilterEnabled = false
        var isMyPickFilterEnabled = false
        var banner = BannerFeature.State()

        @Presents var alert: AlertState<HomeFeature.Alert>?

        var canLoadMoreNearbyRestaurants: Bool {
            !isLoadingMoreNearbyRestaurants && nearbyRestaurantsNextCursor != "0" && nearbyRestaurantsNextCursor != nil
        }

        var filteredNearbyRestaurants: [Restaurant] {
            var filtered = nearbyRestaurants

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
        case fetchNearbyRestaurants
        case loadMoreNearbyRestaurants
        case nearbyRestaurantsLoaded(ResponseListWithCursor<Restaurant>, isLoadingMore: Bool)
        case nearbyRestaurantsLoadFailed(Error)
        case orderByChanged(RestaurantOrderBy)
        case toggleOrderByMenu
        case togglePicchelinFilter
        case toggleMyPickFilter
        case toggleRestaurantLike(String, Bool)
        case restaurantLikeToggled(String, LikeStatus)
        case restaurantLikeToggleFailed(Error)
        case banner(BannerFeature.Action)
        case alert(PresentationAction<HomeFeature.Alert>)
    }

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Scope(state: \.banner, action: \.banner) {
            BannerFeature()
        }

        Reduce { state, action in
            switch action {
            case let .searchTextChanged(text):
                state.searchText = text
                return .none

            case .searchSubmitted:
                return .none

            case let .trendingSearchTapped(keyword):
                state.searchText = keyword
                return .send(.searchSubmitted)

            case .onAppear:
                return .merge(
                    .send(.fetchPopularSearches),
                    .send(.fetchPopularRestaurants),
                    .send(.fetchNearbyRestaurants)
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
                return .merge(
                    .send(.fetchPopularRestaurants),
                    .send(.fetchNearbyRestaurants)
                )

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
                state.alert = AlertState {
                    TextState("인기 가게 로드 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
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
                state.alert = AlertState {
                    TextState("인기 검색어 로드 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
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
                // 인기 가게 업데이트
                if let index = state.popularRestaurants.firstIndex(where: { $0.restaurantId == id }) {
                    let wasLiked = state.popularRestaurants[index].isPick
                    state.popularRestaurants[index].isPick = likeStatus.likeStatus

                    // pickCount 업데이트 (좋아요 추가 시 +1, 취소 시 -1)
                    if !wasLiked && likeStatus.likeStatus {
                        state.popularRestaurants[index].pickCount += 1
                    } else if wasLiked && !likeStatus.likeStatus {
                        state.popularRestaurants[index].pickCount -= 1
                    }
                }

                // 주변 가게 업데이트
                if let index = state.nearbyRestaurants.firstIndex(where: { $0.restaurantId == id }) {
                    let wasLiked = state.nearbyRestaurants[index].isPick
                    state.nearbyRestaurants[index].isPick = likeStatus.likeStatus

                    // pickCount 업데이트 (좋아요 추가 시 +1, 취소 시 -1)
                    if !wasLiked && likeStatus.likeStatus {
                        state.nearbyRestaurants[index].pickCount += 1
                    } else if wasLiked && !likeStatus.likeStatus {
                        state.nearbyRestaurants[index].pickCount -= 1
                    }
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

            case .fetchNearbyRestaurants:
                state.isLoadingNearbyRestaurants = true
                state.nearbyRestaurantsNextCursor = nil
                return .run { [orderBy = state.orderBy, category = state.selectedCategory] send in
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
                        await send(.nearbyRestaurantsLoaded(response, isLoadingMore: false))
                    } catch {
                        await send(.nearbyRestaurantsLoadFailed(error))
                    }
                }

            case .loadMoreNearbyRestaurants:
                guard state.canLoadMoreNearbyRestaurants else { return .none }
                state.isLoadingMoreNearbyRestaurants = true

                let orderBy = state.orderBy
                let category = state.selectedCategory
                let cursor = state.nearbyRestaurantsNextCursor

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
                        await send(.nearbyRestaurantsLoaded(response, isLoadingMore: true))
                    } catch {
                        await send(.nearbyRestaurantsLoadFailed(error))
                    }
                }

            case let .nearbyRestaurantsLoaded(response, isLoadingMore):
                state.isLoadingNearbyRestaurants = false
                state.isLoadingMoreNearbyRestaurants = false
                state.nearbyRestaurantsNextCursor = response.nextCursor

                if isLoadingMore {
                    state.nearbyRestaurants.append(contentsOf: response.data)
                } else {
                    state.nearbyRestaurants = response.data
                }
                return .none

            case let .nearbyRestaurantsLoadFailed(error):
                state.isLoadingNearbyRestaurants = false
                state.isLoadingMoreNearbyRestaurants = false
                state.alert = AlertState {
                    TextState("주변 가게 로드 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case let .orderByChanged(orderBy):
                state.orderBy = orderBy
                state.isShowingOrderByMenu = false
                return .send(.fetchNearbyRestaurants)

            case .toggleOrderByMenu:
                state.isShowingOrderByMenu.toggle()
                return .none

            case .togglePicchelinFilter:
                state.isPicchelinFilterEnabled.toggle()
                return .none

            case .toggleMyPickFilter:
                state.isMyPickFilterEnabled.toggle()
                return .none

            case .banner:
                return .none

            case .alert:
                return .none
            }
        }
        .ifLet(\.alert, action: \.alert)
    }
    
    // MARK: - Dependencies
    @Dependency(\.continuousClock) var clock
    @Dependency(\.fetchPopularRestaurants) var fetchPopularRestaurantsUseCase
    @Dependency(\.fetchPopularSearches) var fetchPopularSearchesUseCase
    @Dependency(\.fetchRestaurants) var fetchRestaurantsUseCase
    @Dependency(\.toggleRestaurantLike) var toggleRestaurantLikeUseCase

    enum Alert: Sendable {}
}

// MARK: - Destinations
extension HomeFeature {
    @Reducer
    enum Destination {
        
    }
}

extension HomeFeature.Destination.State: Sendable {}
