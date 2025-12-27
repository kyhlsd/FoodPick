//
//  PopularRestaurantView.swift
//  Presentation
//
//  Created by 김영훈 on 12/25/25.
//

import SwiftUI
import Domain

struct PopularRestaurantView: View {
    let restaurants: [Restaurant]
    let selectedCategory: RestaurantCategory?
    let isLoading: Bool
    let onLikeToggle: (String, Bool) -> Void
    let onRestaurantTap: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
            Text("실시간 인기 가게")
                .font(.pretendard(size: .body2, weight: .bold))
                .foregroundStyle(.custom(.gray(.gray90)))
                .padding(.horizontal, .xLarge)
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .custom(.brand(.blackSprout))))
                    .padding(.horizontal, .xLarge)
                    .frame(maxWidth: .infinity)
                    .frame(height: 176)
            } else if restaurants.isEmpty {
                Text("인기 가게가 없습니다")
                    .font(.pretendard(size: .body2, weight: .medium))
                    .foregroundStyle(.custom(.gray(.gray60)))
                    .padding(.horizontal, .xLarge)
                    .frame(maxWidth: .infinity)
                    .frame(height: 176)
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: AppPadding.large.value) {
                            Spacer()
                                .frame(width: AppPadding.xLarge.value - AppPadding.large.value)
                            
                            ForEach(restaurants, id: \.restaurantId) { restaurant in
                                PopularRestaurantItemView(
                                    restaurant: restaurant,
                                    onLikeToggle: onLikeToggle,
                                    onRestaurantTap: onRestaurantTap
                                )
                                .id(restaurant.restaurantId)
                            }
                            
                            Spacer()
                                .frame(width: AppPadding.xLarge.value - AppPadding.large.value)
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
