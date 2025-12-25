//
//  HomeView.swift
//  Presentation
//
//  Created by 김영훈 on 12/22/25.
//

import SwiftUI
import Domain
import ComposableArchitecture

struct HomeView: View {
    let store: StoreOf<HomeFeature>

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store

            ZStack {
                Color.custom(.brand(.brightSprout))
                    .ignoresSafeArea()

                ScrollView {
                    let trendingSearches = store.trendingSearches
                    let currentTrendingIndex = store.currentTrendingIndex
                    let isShowingAllCategories = store.isShowingAllCategories
                    let selectedCategory = store.selectedCategory
                    let popularRestaurants = store.popularRestaurant.restaurants
                    let isLoadingPopularRestaurants = store.popularRestaurant.isLoading
                    let filteredNearbyRestaurants = store.nearbyRestaurant.filteredRestaurants
                    let isLoadingNearbyRestaurants = store.nearbyRestaurant.isLoading
                    let isLoadingMoreNearbyRestaurants = store.nearbyRestaurant.isLoadingMore
                    let canLoadMoreNearbyRestaurants = store.nearbyRestaurant.canLoadMore
                    let orderBy = store.nearbyRestaurant.orderBy
                    let isShowingOrderByMenu = store.nearbyRestaurant.isShowingOrderByMenu
                    let isPicchelinFilterEnabled = store.nearbyRestaurant.isPicchelinFilterEnabled
                    let isMyPickFilterEnabled = store.nearbyRestaurant.isMyPickFilterEnabled

                    VStack(spacing: AppPadding.large.value) {
                        // 위치
                        LocationView()
                            .padding(.horizontal, .xLarge)

                        // 서치바
                        MySearchBar(
                            text: $store.searchText.sending(\.searchTextChanged)
                        ) {
                            store.send(.searchSubmitted)
                        }
                        .padding(.horizontal, .xLarge)

                        // 인기 검색어
                        TrendingSearchView(
                            trendingSearches: trendingSearches,
                            currentIndex: currentTrendingIndex
                        ) {
                            store.send(.trendingSearchTapped($0))
                        }
                        .padding(.horizontal, .xLarge)

                        // 흰색 컨테이너 영역
                        VStack(spacing: AppPadding.xLarge.value) {
                            // 카테고리 선택
                            CategorySelectionView(
                                isShowingAllCategories: isShowingAllCategories,
                                selectedCategory: selectedCategory,
                                onCategorySelected: { category in
                                    store.send(.categorySelected(category))
                                },
                                onToggleExpansion: {
                                    store.send(.toggleCategoryExpansion)
                                }
                            )
                            .padding(.top, .xLarge)
                            .padding(.horizontal, .xLarge)

                            // 인기 가게
                            PopularRestaurantView(
                                restaurants: popularRestaurants,
                                selectedCategory: selectedCategory,
                                isLoading: isLoadingPopularRestaurants
                            ) { id, like in
                                store.send(.toggleRestaurantLike(id, like))
                            }
                            .padding(.horizontal, .xLarge)

                            // 배너
                            BannerListView(
                                store: store.scope(state: \.banner, action: \.banner)
                            )

                            // 주변 식당
                            NearbyRestaurantView(
                                restaurants: filteredNearbyRestaurants,
                                orderBy: orderBy,
                                isLoading: isLoadingNearbyRestaurants,
                                isLoadingMore: isLoadingMoreNearbyRestaurants,
                                canLoadMore: canLoadMoreNearbyRestaurants,
                                isShowingOrderByMenu: isShowingOrderByMenu,
                                isPicchelinFilterEnabled: isPicchelinFilterEnabled,
                                isMyPickFilterEnabled: isMyPickFilterEnabled,
                                onOrderByChanged: { orderBy in
                                    store.send(.nearbyRestaurant(.orderByChanged(orderBy)))
                                },
                                onToggleOrderByMenu: {
                                    store.send(.nearbyRestaurant(.toggleOrderByMenu))
                                },
                                onPicchelinFilterToggle: {
                                    store.send(.nearbyRestaurant(.togglePicchelinFilter))
                                },
                                onMyPickFilterToggle: {
                                    store.send(.nearbyRestaurant(.toggleMyPickFilter))
                                },
                                onLikeToggle: { id, like in
                                    store.send(.toggleRestaurantLike(id, like))
                                },
                                onLoadMore: {
                                    store.send(.nearbyRestaurant(.loadMore(category: selectedCategory)))
                                }
                            )
                            .padding(.horizontal, .xLarge)

                            // 탭바가 가리지 않도록 추가
                            Rectangle()
                                .fill(.clear)
                                .frame(height: 110)
                        }
                        .frame(maxWidth: .infinity)
                        .background(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 20,
                                topTrailingRadius: 20
                            )
                            .fill(.custom(.gray(.gray15)))
                            .ignoresSafeArea(edges: .bottom)
                        )
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                .onAppear {
                    store.send(.onAppear)
                }
            }
            .hideKeyboardOnTap()
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

// MARK: - Preview
#Preview {
    HomeView(
        store: Store(initialState: HomeFeature.State()) {
            HomeFeature()
        }
    )
}
