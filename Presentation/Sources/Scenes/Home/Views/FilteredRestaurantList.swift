//
//  FilteredRestaurantList.swift
//  Presentation
//
//  Created by 김영훈 on 12/25/25.
//

import SwiftUI
import Domain

struct FilteredRestaurantList: View {
    let restaurants: [Restaurant]
    let isLoading: Bool
    let isLoadingMore: Bool
    let isPicchelinFilterEnabled: Bool
    let isMyPickFilterEnabled: Bool
    let onPicchelinFilterToggle: () -> Void
    let onMyPickFilterToggle: () -> Void
    let onLikeToggle: (String, Bool) -> Void
    let onLoadMore: () -> Void
    var emptyMessage: String = "주위 가게가 없습니다"
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
            // 필터 버튼들
            HStack {
                FilterToggleButton(
                    label: "픽슐랭",
                    isEnabled: isPicchelinFilterEnabled,
                    onToggle: onPicchelinFilterToggle
                )
                
                FilterToggleButton(
                    label: "My Pick",
                    isEnabled: isMyPickFilterEnabled,
                    onToggle: onMyPickFilterToggle
                )
            }
            
            // 레스토랑 리스트
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .custom(.brand(.blackSprout))))
                    .frame(maxWidth: .infinity)
                    .frame(height: 235)
            } else if restaurants.isEmpty {
                Text(emptyMessage)
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
    }
}

private struct FilterToggleButton: View {
    let label: String
    let isEnabled: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button {
            onToggle()
        } label: {
            HStack(spacing: AppPadding.tiny.value) {
                if isEnabled {
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
                
                Text(label)
                    .font(.pretendard(size: .caption1, weight: .semiBold))
                    .foregroundStyle(isEnabled
                                     ? .custom(.brand(.blackSprout))
                                     : .custom(.gray(.gray60))
                    )
            }
        }
    }
}
