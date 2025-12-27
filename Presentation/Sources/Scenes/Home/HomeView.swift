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
                                isLoading: isLoadingPopularRestaurants,
                                onLikeToggle: { id, like in
                                    store.send(.toggleRestaurantLike(id, like))
                                },
                                onRestaurantTap: { id in
                                    store.send(.restaurantTapped(id))
                                }
                            )

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
                                onRestaurantTap: { id in
                                    store.send(.restaurantTapped(id))
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
            .navigationDestination(
                item: $store.scope(state: \.destination?.search, action: \.destination.search)
            ) { searchStore in
                SearchRestaurantView(store: searchStore)
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.detail, action: \.destination.detail)
            ) { detailStore in
                RestaurantDetailView(store: detailStore)
            }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

// MARK: - SubViews
private struct LocationView: View {
    var body: some View {
        HStack(spacing: AppPadding.small.value) {
            AppIcon.location
            
            Text("문래역, 영등포구")
                .font(.pretendard(size: .body1, weight: .bold))
            
            Button {
                
            } label: {
                AppIcon.detail
            }
            
            Spacer()
        }
        .foregroundStyle(.custom(.gray(.gray90)))
    }
}

private struct TrendingSearchView: View {
    let trendingSearches: [String]
    let currentIndex: Int
    let onTrendingSearchTapped: (String) -> Void
    
    var body: some View {
        HStack(spacing: 2) {
            AppIcon.glint
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundStyle(.custom(.brand(.deepSprout)))
            
            Text("인기 검색어")
                .font(.pretendard(size: .caption1, weight: .semiBold))
                .foregroundStyle(.custom(.brand(.deepSprout)))
            
            if !trendingSearches.isEmpty {
                let index = currentIndex % trendingSearches.count
                let keyword = trendingSearches[index]
                
                Button {
                    onTrendingSearchTapped(keyword)
                } label: {
                    Text("\(index + 1) \(keyword)")
                        .font(.pretendard(size: .caption1, weight: .semiBold))
                        .foregroundStyle(.custom(.brand(.blackSprout)))
                        .padding(.leading, .small)
                        .frame(height: 20)
                        .id(currentIndex)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            )
                        )
                }
            }
            
            Spacer()
        }
        .animation(.spring(duration: 0.6), value: currentIndex)
        .frame(height: 20)
        .clipped()
    }
}

private struct NearbyRestaurantView: View {
    let restaurants: [Restaurant]
    let orderBy: RestaurantOrderBy
    let isLoading: Bool
    let isLoadingMore: Bool
    let canLoadMore: Bool
    let isShowingOrderByMenu: Bool
    let isPicchelinFilterEnabled: Bool
    let isMyPickFilterEnabled: Bool
    let onOrderByChanged: (RestaurantOrderBy) -> Void
    let onToggleOrderByMenu: () -> Void
    let onPicchelinFilterToggle: () -> Void
    let onMyPickFilterToggle: () -> Void
    let onLikeToggle: (String, Bool) -> Void
    let onRestaurantTap: (String) -> Void
    let onLoadMore: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
            HStack {
                Text("주위 픽업 가게")
                    .font(.pretendard(size: .body2, weight: .bold))
                    .foregroundStyle(.custom(.gray(.gray90)))
                
                Spacer()
                
                DropdownMenu(
                    options: RestaurantOrderBy.allCases,
                    selectedOption: orderBy,
                    isOpen: isShowingOrderByMenu,
                    onToggle: onToggleOrderByMenu,
                    onSelect: onOrderByChanged
                ) { option in
                    HStack(spacing: AppPadding.tiny.value) {
                        AppIcon.list
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(.custom(.brand(.blackSprout)))
                        
                        Text(option.rawValue)
                            .font(.pretendard(size: .caption1, weight: .semiBold))
                            .foregroundStyle(.custom(.brand(.blackSprout)))
                    }
                }
            }
            .dropdown(isOpen: isShowingOrderByMenu, onDismiss: onToggleOrderByMenu)
            
            FilteredRestaurantList(
                restaurants: restaurants,
                isLoading: isLoading,
                isLoadingMore: isLoadingMore,
                isPicchelinFilterEnabled: isPicchelinFilterEnabled,
                isMyPickFilterEnabled: isMyPickFilterEnabled,
                onPicchelinFilterToggle: onPicchelinFilterToggle,
                onMyPickFilterToggle: onMyPickFilterToggle,
                onLikeToggle: onLikeToggle,
                onRestaurantTap: onRestaurantTap,
                onLoadMore: onLoadMore
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
