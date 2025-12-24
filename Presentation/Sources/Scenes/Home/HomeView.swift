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
                    let nearbyRestaurants = store.nearbyRestaurants
                    let isLoadingNearbyRestaurants = store.isLoadingNearbyRestaurants
                    let orderBy = store.orderBy
                    let isShowingOrderByMenu = store.isShowingOrderByMenu
                    let isPicchelinFilterEnabled = store.isPicchelinFilterEnabled
                    let isMyPickFilterEnabled = store.isMyPickFilterEnabled
                    
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
                            
                            // 주변 식당
                            NearbyRestaurantView(
                                restaurants: nearbyRestaurants,
                                orderBy: orderBy,
                                isLoading: isLoadingNearbyRestaurants,
                                isShowingOrderByMenu: isShowingOrderByMenu,
                                isPicchelinFilterEnabled: isPicchelinFilterEnabled,
                                isMyPickFilterEnabled: isMyPickFilterEnabled,
                                onOrderByChanged: { orderBy in
                                    store.send(.orderByChanged(orderBy))
                                },
                                onToggleOrderByMenu: {
                                    store.send(.toggleOrderByMenu)
                                },
                                onPicchelinFilterToggle: {
                                    store.send(.togglePicchelinFilter)
                                },
                                onMyPickFilterToggle: {
                                    store.send(.toggleMyPickFilter)
                                },
                                onLikeToggle: { id, like in
                                    store.send(.toggleRestaurantLike(id, like))
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
    let isShowingOrderByMenu: Bool
    let isPicchelinFilterEnabled: Bool
    let isMyPickFilterEnabled: Bool
    let onOrderByChanged: (RestaurantOrderBy) -> Void
    let onToggleOrderByMenu: () -> Void
    let onPicchelinFilterToggle: () -> Void
    let onMyPickFilterToggle: () -> Void
    let onLikeToggle: (String, Bool) -> Void
    
    private var filteredRestaurants: [Restaurant] {
        var filtered = restaurants
        
        if isPicchelinFilterEnabled {
            filtered = filtered.filter { $0.isPicchelin }
        }
        
        if isMyPickFilterEnabled {
            filtered = filtered.filter { $0.isPick }
        }
        
        return filtered
    }
    
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

            HStack {
                Button {
                    onPicchelinFilterToggle()
                } label: {
                    HStack(spacing: AppPadding.tiny.value) {
                        if isPicchelinFilterEnabled {
                            AppIcon.checkMarkFill
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundStyle(.custom(.brand(.blackSprout)))
                        } else {
                            AppIcon.checkMarkEmpty
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundStyle(.custom(.gray(.gray60)))
                        }
                        
                        Text("픽슐랭")
                            .font(.pretendard(size: .caption1, weight: .semiBold))
                            .foregroundStyle(isPicchelinFilterEnabled
                                             ? .custom(.brand(.blackSprout))
                                             : .custom(.gray(.gray60))
                            )
                    }
                }
                
                Button {
                    onMyPickFilterToggle()
                } label: {
                    HStack(spacing: AppPadding.tiny.value) {
                        if isMyPickFilterEnabled {
                            AppIcon.checkMarkFill
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundStyle(.custom(.brand(.blackSprout)))
                        } else {
                            AppIcon.checkMarkEmpty
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundStyle(.custom(.gray(.gray60)))
                        }
                        
                        Text("My Pick")
                            .font(.pretendard(size: .caption1, weight: .semiBold))
                            .foregroundStyle(isMyPickFilterEnabled
                                             ? .custom(.brand(.blackSprout))
                                             : .custom(.gray(.gray60))
                            )
                    }
                }
            }
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .custom(.brand(.blackSprout))))
                    .frame(maxWidth: .infinity)
                    .frame(height: 235)
            } else if filteredRestaurants.isEmpty {
                Text("주위 가게가 없습니다")
                    .font(.pretendard(size: .body2, weight: .medium))
                    .foregroundStyle(.custom(.gray(.gray60)))
                    .frame(maxWidth: .infinity)
                    .frame(height: 235)
            } else {
                LazyVStack(spacing: AppPadding.large.value) {
                    ForEach(filteredRestaurants, id: \.restaurantId) { restaurant in
                        RestaurantDetailItemView(
                            restaurant: restaurant,
                            onLikeToggle: onLikeToggle
                        )
                        .frame(height: 235)
                    }
                }
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
