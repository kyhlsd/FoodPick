//
//  RestaurantDetailView.swift
//  Presentation
//
//  Created by 김영훈 on 12/26/25.
//

import SwiftUI
import Domain
import ComposableArchitecture

struct RestaurantDetailView: View {
    let store: StoreOf<RestaurantDetailFeature>

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store

            let isLoading = store.isLoading
            let restaurantInfo = store.restaurantInfo
            let currentImageIndex = store.currentImageIndex
            let filteredMenuList = store.filteredMenuList

            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .custom(.brand(.blackSprout))))
                } else if let restaurant = restaurantInfo {
                    ScrollView {
                        VStack(spacing: 0) {
                            // 이미지 영역
                            ZStack(alignment: .bottom) {
                                TabView(selection: $store.currentImageIndex.sending(\.imageIndexChanged)) {
                                    ForEach(Array(restaurant.restaurantImageURLs.enumerated()),
                                            id: \.offset) { index, imagePath in
                                        AuthenticatedImage(imagePath: imagePath)
                                            .frame(height: 240)
                                            .tag(index)
                                    }
                                }
                                .tabViewStyle(.page(indexDisplayMode: .never))
                                .frame(height: 240)

                                // Page Control
                                if restaurant.restaurantImageURLs.count > 1 {
                                    HStack(spacing: AppPadding.small.value) {
                                        ForEach(0..<restaurant.restaurantImageURLs.count, id: \.self) { index in
                                            if currentImageIndex == index {
                                                Circle()
                                                    .fill(.custom(.gray(.gray0)))
                                                    .frame(width: 8, height: 8)
                                            } else {
                                                Circle()
                                                    .fill(.custom(.gray(.gray45)))
                                                    .frame(width: 4, height: 4)
                                            }
                                            
                                        }
                                    }
                                    .padding(.bottom, AppPadding.medium.value + 20)
                                }
                            }

                            // 컨텐츠 영역
                            VStack(spacing: 0) {
                                // 가게 영역
                                VStack(spacing: AppPadding.xLarge.value) {
                                    RestaurantInfoSection(restaurant: restaurant)
                                        .padding([.top, .horizontal], .xLarge)

                                    VStack(spacing: AppPadding.medium.value) {
                                        RestaurantDetailsCard(restaurant: restaurant)

                                        EstimatedPickupTimeView(minutes: restaurant.estimatedPickupTime)

                                        PrimaryButton(title: "길찾기",
                                                      height: 44
                                        ) {

                                        }
                                    }
                                    .padding(.horizontal, .xLarge)
                                    
                                    MyDivider()
                                }
                                .frame(maxWidth: .infinity)
                                .background(.custom(.gray(.gray15)))

                                // 메뉴 영역
                                VStack(alignment: .leading, spacing: AppPadding.medium.value) {
                                    MenuCategorySelector(
                                        categories: store.menuCategories,
                                        selectedCategory: store.selectedMenuCategory,
                                        isSearching: store.isSearching,
                                        onCategorySelected: { category in
                                            store.send(.menuCategorySelected(category))
                                        },
                                        onSearchToggle: {
                                            store.send(.toggleMenuSearch)
                                        }
                                    )
                                    .padding(.top, .xLarge)

                                    if store.isSearching {
                                        MySearchBar(
                                            text: $store.menuSearchText.sending(\.menuSearchTextChanged),
                                            placeholder: "메뉴 검색"
                                        ) {
                                            store.send(.menuSearchSubmitted)
                                        }
                                        .padding(2)
                                        .padding(.horizontal, .xLarge)
                                    }

                                    if let menuCategoryTitle = store.menuCategoryTitle {
                                        MenuCategoryTitleView(
                                            title: menuCategoryTitle,
                                            searchText: store.menuSearchText,
                                            isSearching: store.isSearching
                                        )
                                        .padding(.horizontal, .xLarge)
                                    }

                                    // 메뉴 리스트
                                    VStack(spacing: 0) {
                                        ForEach(filteredMenuList, id: \.menuId) { menu in
                                            MenuItemView(menu: menu)
                                                .padding(.horizontal, .xLarge)
                                                .padding(.vertical, .medium)

                                            if menu.menuId != store.filteredMenuList.last?.menuId {
                                                MyDivider()
                                                    .padding(.horizontal, .xLarge)
                                            }
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.custom(.gray(.gray0)))
                                .animation(.easeInOut(duration: 0.3), value: store.isSearching)
                            }
                            .clipShape(
                                UnevenRoundedRectangle(
                                    topLeadingRadius: 20,
                                    topTrailingRadius: 20
                                )
                            )
                            .offset(y: -20)
                        }
                    }
                    .ignoresSafeArea(edges: .top)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            HeartButton(isLike: restaurant.isPick,
                                        nonLikeColor: .custom(.gray(.gray100))
                            ) {
                                store.send(.toggleRestaurantLike)
                            }
                        }
                    }
                }
            }
            .hideKeyboardOnTap()
            .alert($store.scope(state: \.alert, action: \.alert))
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

// MARK: - Restaurant Info Section
private struct RestaurantInfoSection: View {
    let restaurant: RestaurantDetail

    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
            // 첫 번째 줄: 가게명 + 픽슐랭
            HStack(spacing: AppPadding.large.value) {
                Text(restaurant.name)
                    .font(.pretendard(size: .title1, weight: .bold))
                    .foregroundStyle(.custom(.gray(.gray90)))

                if restaurant.isPicchelin {
                    PicchelinView()
                }

                Spacer()
            }

            // 두 번째 줄: 좋아요, 평점, 누적 주문
            HStack(spacing: AppPadding.large.value) {
                // 좋아요
                HStack(spacing: 2) {
                    AppIcon.likeFill
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color(hex: "#FDC020"))

                    Text("\(restaurant.pickCount)개")
                        .font(.pretendard(size: .body1, weight: .bold))
                        .foregroundStyle(.custom(.gray(.gray90)))
                }

                // 평점
                HStack(spacing: 2) {
                    AppIcon.starFill
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color(hex: "#FDC020"))

                    Text(String(format: "%.1f", restaurant.totalRating))
                        .font(.pretendard(size: .body1, weight: .bold))
                        .foregroundStyle(.custom(.gray(.gray90)))

                    Text("(\(restaurant.totalReviewCount))")
                        .font(.pretendard(size: .body1, weight: .regular))
                        .foregroundStyle(.custom(.gray(.gray60)))

                    Button {

                    } label: {
                        AppIcon.chevron
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.custom(.gray(.gray60)))
                            .rotationEffect(.degrees(180))
                    }
                }

                Spacer()

                // 누적 주문
                Text("총 누적 주문 \(restaurant.totalOrderCount)회")
                    .font(.pretendard(size: .body3, weight: .medium))
                    .foregroundStyle(.custom(.gray(.gray45)))
            }
        }
    }
}

// MARK: - Restaurant Details Card
private struct RestaurantDetailsCard: View {
    let restaurant: RestaurantDetail

    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
            // 가게 주소
            DetailRow(
                icon: AppIcon.distance,
                title: "가게 주소",
                content: restaurant.address
            )

            // 영업 시간
            DetailRow(
                icon: AppIcon.time,
                title: "영업 시간",
                content: "매일 \(TimeFormatter.toFullAMPMFormat(from: restaurant.open)) ~ " +
                         "\(TimeFormatter.toFullAMPMFormat(from: restaurant.close))"
            )

            // 주차 여부
            DetailRow(
                icon: AppIcon.parking,
                title: "주차 여부",
                content: restaurant.parkingGuide
            )
        }
        .padding(.vertical, .medium)
        .padding(.horizontal, .large)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.custom(.gray(.gray0)))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.custom(.gray(.gray30)), lineWidth: 1)
        )
    }
}

// MARK: - Detail Row
private struct DetailRow: View {
    let icon: Image
    let title: String
    let content: String

    var body: some View {
        HStack(alignment: .top, spacing: AppPadding.medium.value) {
            Text(title)
                .font(.pretendard(size: .body2, weight: .medium))
                .foregroundStyle(.custom(.gray(.gray60)))

            HStack(alignment: .top, spacing: AppPadding.tiny.value) {
                icon
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.custom(.brand(.blackSprout)))

                Text(content)
                    .font(.pretendard(size: .body2, weight: .medium))
                    .foregroundStyle(.custom(.gray(.gray60)))
            }

            Spacer()
        }
    }
}

// MARK: - Estimated Pickup Time View
private struct EstimatedPickupTimeView: View {
    let minutes: Int

    var body: some View {
        HStack {
            HStack(spacing: 2) {
                AppIcon.run
                    .resizable()
                    .frame(width: 16, height: 16)

                Text("예상 소요시간 \(minutes)분")
                    .font(.pretendard(size: .body3, weight: .medium))
            }
            .foregroundStyle(.custom(.brand(.deepSprout)))
            .padding(.horizontal, AppPadding.small.value)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(.custom(.gray(.gray0)))
            )
            .overlay(
                Capsule()
                    .stroke(.custom(.gray(.gray30)), lineWidth: 1)
            )

            Spacer()
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
