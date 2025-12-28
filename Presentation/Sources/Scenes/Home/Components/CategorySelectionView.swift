//
//  CategorySelectionView.swift
//  Presentation
//
//  Created by 김영훈 on 12/25/25.
//

import SwiftUI
import Domain

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
