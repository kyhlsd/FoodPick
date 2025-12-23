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
                    let popularRestaurants = store.popularRestaurants
                    let isLoadingPopularRestaurants = store.isLoadingPopularRestaurants

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
                            currentIndex: currentTrendingIndex,
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

//                            NearbyRestaurantView(
//                                restaurants: nearbyRestaurants,
//                                orderBy: orderBy,
//                                isLoading: isLoadingNearbyRestaurants
//                            ) { id, like in
//                                store.send(.toggleRestaurantLike(id, like))
//                            }
//                            .padding(.horizontal, xLarge)
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

private struct CategorySelectionView: View {
    let isShowingAllCategories: Bool
    let selectedCategory: RestaurantCategory?
    let onCategorySelected: (RestaurantCategory?) -> Void
    let onToggleExpansion: () -> Void

    private var displayedCategories: [CategoryItem] {
        let restaurantCategories = RestaurantCategory.allCases.map { CategoryItem.restaurant($0) }

        if isShowingAllCategories {
            return [.all] + restaurantCategories + [.collapse]
        } else {
            return [.all] + Array(restaurantCategories.prefix(3)) + [.more]
        }
    }

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible()), count: 5),
            spacing: AppPadding.large.value
        ) {
            ForEach(displayedCategories, id: \.self) { item in
                CategoryItemView(
                    item: item,
                    isSelected: item.category == selectedCategory && !item.isMoreButton
                ) {
                    if item.isMoreButton {
                        onToggleExpansion()
                    } else {
                        onCategorySelected(item.category)
                    }
                }
            }
        }
    }
}

private enum CategoryItem: Hashable {
    case all
    case restaurant(RestaurantCategory)
    case more
    case collapse

    var displayName: String {
        switch self {
        case .all: return "전체"
        case .restaurant(let category): return category.rawValue
        case .more: return "more"
        case .collapse: return "접기"
        }
    }

    var isMoreButton: Bool {
        switch self {
        case .more, .collapse: return true
        default: return false
        }
    }

    var category: RestaurantCategory? {
        switch self {
        case .restaurant(let category): return category
        default: return nil
        }
    }
    
    @ViewBuilder
    var icon: some View {
        switch self {
        case .all:
            AppIcon.total
        case .restaurant(let category):
            switch category {
            case .cafe:
                AppIcon.coffee
            case .fastfood:
                AppIcon.fastfood
            case .desert:
                AppIcon.desert
            case .bakery:
                AppIcon.bakery
            case .korean:
                AppIcon.coffee
            case .japanese:
                AppIcon.coffee
            case .chinese:
                AppIcon.coffee
            case .chicken:
                AppIcon.coffee
            case .pizza:
                AppIcon.coffee
            case .etc:
                AppIcon.coffee
            }
        case .more:
            AppIcon.more
                .foregroundStyle(.custom(.brand(.blackSprout)))
                .font(.system(size: 24))
        case .collapse:
            AppIcon.up
                .foregroundStyle(.custom(.brand(.blackSprout)))
                .font(.system(size: 20))
        }
    }
}

private struct CategoryItemView: View {
    let item: CategoryItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: AppPadding.tiny.value) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.custom(.gray(.gray0)))
                    .frame(width: 56, height: 56)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ?
                                .custom(.brand(.blackSprout)) :
                                    .custom(.gray(.gray30)),
                                    lineWidth: 1.5
                            )
                    }
                    .overlay {
                        item.icon
                    }
                
                Text(item.displayName)
                    .font(.pretendard(size: .body3, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? .custom(.brand(.blackSprout)) : .custom(.gray(.gray60)))
                    .lineLimit(1)
            }
        }
    }
}

private struct PopularRestaurantView: View {
    let restaurants: [Restaurant]
    let selectedCategory: RestaurantCategory?
    let isLoading: Bool
    let onLikeToggle: (String, Bool) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
            Text("실시간 인기 가게")
                .font(.pretendard(size: .body2, weight: .bold))
                .foregroundStyle(.custom(.gray(.gray90)))

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .custom(.brand(.blackSprout))))
                    .frame(maxWidth: .infinity)
                    .frame(height: 176)
            } else if restaurants.isEmpty {
                Text("인기 가게가 없습니다")
                    .font(.pretendard(size: .body2, weight: .medium))
                    .foregroundStyle(.custom(.gray(.gray60)))
                    .frame(maxWidth: .infinity)
                    .frame(height: 176)
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: AppPadding.large.value) {
                            ForEach(restaurants, id: \.restaurantId) { restaurant in
                                PopularRestaurantItemView(
                                    restaurant: restaurant,
                                    onLikeToggle: onLikeToggle
                                )
                                .id(restaurant.restaurantId)
                            }
                        }
                    }
                    .frame(height: 176)
                    .onChange(of: selectedCategory) { _ in
                        if let firstRestaurant = restaurants.first {
                            proxy.scrollTo(firstRestaurant.restaurantId, anchor: .leading)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct NearbyRestaurantView: View {
    let restaurants: [Restaurant]
    let orderBy: RestaurantOrderBy
    let isLoading: Bool
    let onLikeToggle: (String, Bool) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
            HStack {
                Text("픽업 가게")
                    .font(.pretendard(size: .body3, weight: .bold))
                    .foregroundStyle(.custom(.gray(.gray90)))
                
                Spacer()
                
                HStack(spacing: AppPadding.tiny.value) {
                    Text(orderBy.rawValue)
                        .font(.pretendard(size: .caption1, weight: .semiBold))
                        .foregroundStyle(.custom(.brand(.blackSprout)))
                    
                    AppIcon.list
                        .resizable()
                        .frame(width: 12, height: 9.5)
                        .foregroundStyle(.custom(.brand(.blackSprout)))
                }
            }
            
            HStack {
                Button {
                    
                } label: {
                    HStack(spacing: AppPadding.tiny.value) {
                        AppIcon.checkMarkFill
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(.custom(.brand(.blackSprout)))
                        
                        Text("픽슐랭")
                            .font(.pretendard(size: .caption1, weight: .semiBold))
                            .foregroundStyle(.custom(.brand(.blackSprout)))
                    }
                }
                
                Button {
                    
                } label: {
                    HStack(spacing: AppPadding.tiny.value) {
                        AppIcon.checkMarkEmpty
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(.custom(.brand(.brightSprout)))
                        
                        Text("My Pick")
                            .font(.pretendard(size: .caption1, weight: .semiBold))
                            .foregroundStyle(.custom(.brand(.brightSprout)))
                    }
                }
            }

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .custom(.brand(.blackSprout))))
                    .frame(maxWidth: .infinity)
                    .frame(height: 176)
            } else if restaurants.isEmpty {
                Text("주위 가게가 없습니다")
                    .font(.pretendard(size: .body2, weight: .medium))
                    .foregroundStyle(.custom(.gray(.gray60)))
                    .frame(maxWidth: .infinity)
                    .frame(height: 176)
            } else {
                LazyVStack(spacing: AppPadding.large.value) {
                    ForEach(restaurants, id: \.restaurantId) { restaurant in
                        RestaurantDetailItemView(
                            restaurant: restaurant,
                            onLikeToggle: onLikeToggle
                        )
                    }
                }
                .frame(height: 176)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    HomeView(
        store: Store(initialState: HomeFeature.State()) {
            HomeFeature()
        }
    )
}
