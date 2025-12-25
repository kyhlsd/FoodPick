//
//  HomeView+Nearby.swift
//  Presentation
//
//  Created by 김영훈 on 12/25/25.
//

import SwiftUI
import Domain

// MARK: - Nearby Restaurant
extension HomeView {
    struct NearbyRestaurantView: View {
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
                } else if restaurants.isEmpty {
                    Text("주위 가게가 없습니다")
                        .font(.pretendard(size: .body2, weight: .medium))
                        .foregroundStyle(.custom(.gray(.gray60)))
                        .frame(maxWidth: .infinity)
                        .frame(height: 235)
                } else {
                    LazyVStack(spacing: AppPadding.large.value) {
                        ForEach(restaurants, id: \.restaurantId) { restaurant in
                            RestaurantDetailItemView(
                                restaurant: restaurant,
                                onLikeToggle: onLikeToggle
                            )
                            .frame(height: 235)
                            .onAppear {
                                if restaurant.restaurantId == restaurants.last?.restaurantId {
                                    onLoadMore()
                                }
                            }
                        }

                        if isLoadingMore {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .custom(.brand(.blackSprout))))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppPadding.medium.value)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
