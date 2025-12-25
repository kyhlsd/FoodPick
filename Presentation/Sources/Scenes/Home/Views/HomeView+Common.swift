//
//  HomeView+Common.swift
//  Presentation
//
//  Created by 김영훈 on 12/25/25.
//

import SwiftUI
import Domain

// MARK: - Common Subviews
extension HomeView {
    struct LocationView: View {
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

    struct TrendingSearchView: View {
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

    struct CategorySelectionView: View {
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

    enum CategoryItem: Hashable {
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

    struct CategoryItemView: View {
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
}
