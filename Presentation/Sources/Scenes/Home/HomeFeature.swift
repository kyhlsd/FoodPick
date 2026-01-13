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
        var address = ""
        var searchText = ""
        var trendingSearches: [String] = []
        var currentTrendingIndex = 0
        var selectedCategory: RestaurantCategory?
        var isShowingAllCategories = false
        var popularRestaurant = PopularRestaurantFeature.State()
        var nearbyRestaurant = NearbyRestaurantFeature.State()
        var banner = BannerFeature.State()

        @Presents var destination: Destination.State?
        @Presents var alert: AlertState<HomeFeature.Alert>?
    }

    // MARK: - Action
    enum Action {
        case searchTextChanged(String)
        case searchSubmitted
        case onAppear
        case fetchAddress
        case updateLocation
        case updateLocationSuccess
        case updateLocationFailed(Error)
        case trendingTimerTick
        case setTrendingSearches([String])
        case trendingSearchTapped(String)
        case categorySelected(RestaurantCategory?)
        case toggleCategoryExpansion
        case fetchPopularSearches
        case popularSearchesLoaded([String])
        case popularSearchesLoadFailed(Error)
        case toggleRestaurantLike(String, Bool)
        case restaurantLikeToggled(String, LikeStatus)
        case restaurantLikeToggleFailed(Error)
        case restaurantTapped(String)
        case popularRestaurant(PopularRestaurantFeature.Action)
        case nearbyRestaurant(NearbyRestaurantFeature.Action)
        case banner(BannerFeature.Action)
        case destination(PresentationAction<Destination.Action>)
        case alert(PresentationAction<HomeFeature.Alert>)
    }

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Scope(state: \.popularRestaurant, action: \.popularRestaurant) {
            PopularRestaurantFeature()
        }

        Scope(state: \.nearbyRestaurant, action: \.nearbyRestaurant) {
            NearbyRestaurantFeature()
        }

        Scope(state: \.banner, action: \.banner) {
            BannerFeature()
        }

        Reduce { state, action in
            switch action {
            case let .searchTextChanged(text):
                state.searchText = text
                return .none

            case .searchSubmitted:
                guard !state.searchText.isEmpty else { return .none }
                let searchWord = state.searchText
                state.searchText = ""
                state.destination = .search(
                    SearchRestaurantFeature.State(searchWord: searchWord)
                )
                return .none

            case let .trendingSearchTapped(keyword):
                state.searchText = keyword
                return .send(.searchSubmitted)

            case .onAppear:
                return .merge(
                    .send(.fetchAddress),
                    .send(.fetchPopularSearches),
                    .send(.popularRestaurant(.fetch(category: nil))),
                    .send(.nearbyRestaurant(.fetch(category: nil)))
                )

            case .fetchAddress:
                let userLocation = getUserLocation.execute()
                state.address = userLocation.address
                return .none
                
            case .updateLocation:
                return .run { send in
                    do {
                        _ = try await updateLocation.execute()
                        await send(.updateLocationSuccess)
                    } catch {
                        await send(.updateLocationFailed(error))
                    }
                }

            case .updateLocationSuccess:
                return .merge(
                    .send(.fetchAddress),
                    .send(.popularRestaurant(.fetch(category: nil))),
                    .send(.nearbyRestaurant(.fetch(category: nil)))
                )

            case let .updateLocationFailed(error):
                state.alert = AlertState {
                    TextState("위치 업데이트 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none
                
            case let .setTrendingSearches(searches):
                state.trendingSearches = searches
                state.currentTrendingIndex = 0
                return .merge(
                    .cancel(id: CancelID.trendingTimer),
                    .run { send in
                        for await _ in self.clock.timer(interval: .seconds(2)) {
                            await send(.trendingTimerTick)
                        }
                    }
                    .cancellable(id: CancelID.trendingTimer)
                )

            case .trendingTimerTick:
                guard !state.trendingSearches.isEmpty else { return .none }
                state.currentTrendingIndex += 1
                return .none

            case let .categorySelected(category):
                state.selectedCategory = category
                return .merge(
                    .send(.popularRestaurant(.fetch(category: category))),
                    .send(.nearbyRestaurant(.fetch(category: category)))
                )

            case .toggleCategoryExpansion:
                state.isShowingAllCategories.toggle()
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
                let isPick = likeStatus.likeStatus

                // pickCount 계산: 인기 가게 또는 주변 가게에서 현재 pickCount를 가져옴
                var pickCount = 0
                if let restaurant = state.popularRestaurant.restaurants.first(where: { $0.restaurantId == id }) {
                    pickCount = restaurant.pickCount + (isPick ? 1 : -1)
                } else if let restaurant = state.nearbyRestaurant.restaurants.first(where: { $0.restaurantId == id }) {
                    pickCount = restaurant.pickCount + (isPick ? 1 : -1)
                }

                return .merge(
                    .send(.popularRestaurant(.updateRestaurantLikeStatus(id, isPick, pickCount))),
                    .send(.nearbyRestaurant(.updateRestaurantLikeStatus(id, isPick, pickCount)))
                )

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

            case let .restaurantTapped(restaurantId):
                state.destination = .detail(RestaurantDetailFeature.State(restaurantId: restaurantId))
                return .none

            case .popularRestaurant(.restaurantsLoadFailed(let error)):
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

            case .nearbyRestaurant(.restaurantsLoadFailed(let error)):
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

            case .nearbyRestaurant(.orderByChanged):
                return .send(.nearbyRestaurant(.fetch(category: state.selectedCategory)))

            case .popularRestaurant:
                return .none

            case .nearbyRestaurant:
                return .none

            case .banner:
                return .none

            case .destination(.presented(.search(.restaurantsLoadFailed(let error)))):
                state.alert = AlertState {
                    TextState("검색 결과 로드 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case .destination(.presented(.search(.restaurantLikeToggleFailed(let error)))):
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

            case .destination:
                return .none

            case .alert:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$alert, action: \.alert)
    }

    // MARK: - Dependencies
    @Dependency(\.continuousClock) var clock
    @Dependency(\.getUserLocation) var getUserLocation
    @Dependency(\.updateLocation) var updateLocation
    @Dependency(\.fetchPopularSearches) var fetchPopularSearchesUseCase
    @Dependency(\.toggleRestaurantLike) var toggleRestaurantLikeUseCase

    enum Alert: Sendable {}

    enum CancelID {
        case trendingTimer
    }
}

// MARK: - Destinations
extension HomeFeature {
    @Reducer
    enum Destination {
        case search(SearchRestaurantFeature)
        case detail(RestaurantDetailFeature)
    }
}

extension HomeFeature.Destination.State: Sendable {}
