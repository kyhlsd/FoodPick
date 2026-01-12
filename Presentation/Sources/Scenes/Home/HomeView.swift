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
                    VStack(spacing: AppPadding.large.value) {
                        // 위치
                        LocationView(
                            store: store
                        )
                        .padding(.horizontal, .xLarge)

                        // 서치바
                        MySearchBar(
                            text: $store.searchText.sending(\.searchTextChanged)
                        ) {
                            store.send(.searchSubmitted)
                        }
                        .padding(.horizontal, .xLarge)

                        // 인기 검색어
                        TrendingSearchView(store: store)
                            .padding(.horizontal, .xLarge)

                        // 흰색 컨테이너 영역
                        VStack(spacing: AppPadding.xLarge.value) {
                            // 카테고리 선택
                            CategorySelectionView(store: store)
                                .padding(.top, .xLarge)
                                .padding(.horizontal, .xLarge)

                            // 인기 가게
                            PopularRestaurantView(store: store)

                            // 배너
                            BannerListView(
                                store: store.scope(state: \.banner, action: \.banner)
                            )

                            // 주변 식당
                            NearbyRestaurantView(store: store)
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
            .dropdownBackdrop(isOpen: store.nearbyRestaurant.isShowingOrderByMenu) {
                store.send(.nearbyRestaurant(.toggleOrderByMenu))
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
    let store: StoreOf<HomeFeature>
    
    var body: some View {
        WithPerceptionTracking {
            HStack(spacing: AppPadding.small.value) {
                AppIcon.location
                
                Text(store.address)
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
}

private struct TrendingSearchView: View {
    let store: StoreOf<HomeFeature>

    var body: some View {
        WithPerceptionTracking {
            let trendingSearches = store.trendingSearches
            let currentIndex = store.currentTrendingIndex

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
                        store.send(.trendingSearchTapped(keyword))
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
}

private struct NearbyRestaurantView: View {
    let store: StoreOf<HomeFeature>

    var body: some View {
        WithPerceptionTracking {
            let selectedCategory = store.selectedCategory
            
            VStack(alignment: .leading, spacing: AppPadding.medium.value) {
                HStack {
                    Text("주위 픽업 가게")
                        .font(.pretendard(size: .body2, weight: .bold))
                        .foregroundStyle(.custom(.gray(.gray90)))

                    Spacer()

                    DropdownMenu(
                        options: RestaurantOrderBy.allCases,
                        selectedOption: store.nearbyRestaurant.orderBy,
                        isOpen: store.nearbyRestaurant.isShowingOrderByMenu,
                        onToggle: {
                            store.send(.nearbyRestaurant(.toggleOrderByMenu))
                        },
                        onSelect: { orderBy in
                            store.send(.nearbyRestaurant(.orderByChanged(orderBy)))
                        },
                        label: { option in
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
                    )
                }
                .dropdownHost(isOpen: store.nearbyRestaurant.isShowingOrderByMenu) {
                    store.send(.nearbyRestaurant(.toggleOrderByMenu))
                }

                FilteredRestaurantList(
                    restaurants: store.nearbyRestaurant.restaurants,
                    isLoading: store.nearbyRestaurant.isLoading,
                    isLoadingMore: store.nearbyRestaurant.isLoadingMore,
                    isPicchelinFilterEnabled: store.nearbyRestaurant.isPicchelinFilterEnabled,
                    isMyPickFilterEnabled: store.nearbyRestaurant.isMyPickFilterEnabled,
                    onPicchelinFilterToggle: {
                        store.send(.nearbyRestaurant(.togglePicchelinFilter))
                    },
                    onMyPickFilterToggle: {
                        store.send(.nearbyRestaurant(.toggleMyPickFilter))
                    },
                    onLikeToggle: { id, like in
                        store.send(.toggleRestaurantLike(id, like))
                    },
                    onRestaurantTap: {
                        store.send(.restaurantTapped($0))
                    },
                    onLoadMore: {
                        store.send(.nearbyRestaurant(.loadMore(category: selectedCategory)))
                    }
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
