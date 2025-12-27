//
//  MenuSectionView.swift
//  Presentation
//
//  Created by 김영훈 on 12/27/25.
//

import SwiftUI
import Domain
import ComposableArchitecture

// MARK: - Menu Section View
struct MenuSectionView: View {
    let store: StoreOf<MenuSectionFeature>

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store

            let menuCategories = store.menuCategories
            let selectedCategory = store.selectedMenuCategory
            let isSearching = store.isSearching
            let menuCategoryTitle = store.menuCategoryTitle
            let menuSearchText = store.menuSearchText
            let filteredMenuList = store.filteredMenuList
            let lastMenuId = filteredMenuList.last?.menuId

            VStack(alignment: .leading, spacing: AppPadding.medium.value) {
                MenuCategorySelector(
                    categories: menuCategories,
                    selectedCategory: selectedCategory,
                    isSearching: isSearching,
                    onCategorySelected: { category in
                        store.send(.menuCategorySelected(category))
                    },
                    onSearchToggle: {
                        store.send(.toggleMenuSearch)
                    }
                )
                .padding(.top, .xLarge)

                if isSearching {
                    MySearchBar(
                        text: $store.menuSearchText.sending(\.menuSearchTextChanged),
                        placeholder: "메뉴 검색"
                    ) {
                        store.send(.menuSearchSubmitted)
                    }
                    .padding(2)
                    .padding(.horizontal, .xLarge)
                }

                if let menuCategoryTitle {
                    MenuCategoryTitleView(
                        title: menuCategoryTitle,
                        searchText: menuSearchText,
                        isSearching: isSearching
                    )
                    .padding(.horizontal, .xLarge)
                }

                // 메뉴 리스트
                VStack(spacing: 0) {
                    ForEach(filteredMenuList, id: \.menuId) { menu in
                        Button {
                            store.send(.menuTapped(menu))
                        } label: {
                            MenuItemView(menu: menu)
                                .padding(.horizontal, .xLarge)
                                .padding(.vertical, .medium)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if menu.menuId != lastMenuId {
                            MyDivider()
                                .padding(.horizontal, .xLarge)
                        }
                    }
                }
                .padding(.bottom, 100)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.custom(.gray(.gray0)))
            .animation(.easeInOut(duration: 0.3), value: isSearching)
        }
    }
}

// MARK: - Menu Category Selector
private struct MenuCategorySelector: View {
    let categories: [String]
    let selectedCategory: String?
    let isSearching: Bool
    let onCategorySelected: (String) -> Void
    let onSearchToggle: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppPadding.small.value) {
                // 검색 버튼 (검색한 메뉴 카테고리 역할)
                Button {
                    onSearchToggle()
                } label: {
                    HStack(spacing: 4) {
                        AppIcon.search
                            .resizable()
                            .frame(width: 16, height: 16)

                        Text("검색한 메뉴")
                            .font(.pretendard(size: .body2, weight: isSearching ? .bold : .medium))
                    }
                    .foregroundStyle(isSearching ? .custom(.brand(.blackSprout)) : .custom(.gray(.gray60)))
                    .padding(.horizontal, AppPadding.medium.value)
                    .padding(.vertical, AppPadding.small.value)
                    .background(
                        Capsule()
                            .fill(.custom(.gray(.gray0)))
                    )
                    .overlay(
                        Capsule()
                            .stroke(isSearching ? .custom(.brand(.blackSprout)) : .custom(.gray(.gray60)),
                                    lineWidth: isSearching ? 1.5 : 1)
                    )
                }
                .buttonStyle(.plain)

                ForEach(categories, id: \.self) { category in
                    CategoryChip(
                        title: category,
                        isSelected: selectedCategory == category
                    ) {
                        onCategorySelected(category)
                    }
                }
            }
            .padding(.horizontal, .xLarge)
            .padding(2)
        }
    }
}

// MARK: - Category Chip
private struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            if isSelected {
                Text(title)
                    .font(.pretendard(size: .body2, weight: .bold))
                    .foregroundStyle(.custom(.brand(.blackSprout)))
                    .padding(.horizontal, AppPadding.medium.value)
                    .padding(.vertical, AppPadding.small.value)
                    .background(
                        Capsule()
                            .fill(.custom(.gray(.gray0)))
                    )
                    .overlay(
                        Capsule()
                            .stroke(.custom(.brand(.blackSprout)), lineWidth: 1.5)
                    )
            } else {
                Text(title)
                    .font(.pretendard(size: .body2, weight: .medium))
                    .foregroundStyle(.custom(.gray(.gray60)))
                    .padding(.horizontal, AppPadding.medium.value)
                    .padding(.vertical, AppPadding.small.value)
                    .background(
                        Capsule()
                            .fill(.custom(.gray(.gray0)))
                    )
                    .overlay(
                        Capsule()
                            .stroke(.custom(.gray(.gray60)), lineWidth: 1)
                    )
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Menu Category Title View
private struct MenuCategoryTitleView: View {
    let title: String
    let searchText: String
    let isSearching: Bool

    var body: some View {
        if isSearching, !searchText.isEmpty {
            // 검색한 메뉴: 검색어 부분만 deepSprout
            Text(attributedTitle)
                .font(.pretendard(size: .body1, weight: .bold))
        } else {
            // 일반 카테고리
            Text(title)
                .font(.pretendard(size: .body1, weight: .bold))
                .foregroundStyle(.custom(.gray(.gray90)))
        }
    }

    private var attributedTitle: AttributedString {
        var attributedString = AttributedString(title)
        attributedString.foregroundColor = .custom(.gray(.gray90))

        // 검색어 부분 찾기
        if let range = attributedString.range(of: searchText) {
            attributedString[range].foregroundColor = .custom(.brand(.deepSprout))
        }

        return attributedString
    }
}
