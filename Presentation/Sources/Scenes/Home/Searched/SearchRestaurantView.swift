//
//  SearchRestaurantView.swift
//  Presentation
//
//  Created by 김영훈 on 12/25/25.
//

import SwiftUI
import Domain
import ComposableArchitecture

struct SearchRestaurantView: View {
    let store: StoreOf<SearchRestaurantFeature>

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store

            let searchWord = store.searchWord
            let restaurants = store.filteredRestaurants
            let isLoading = store.isLoading
            let isPicchelinFilterEnabled = store.isPicchelinFilterEnabled
            let isMyPickFilterEnabled = store.isMyPickFilterEnabled
            
            ZStack {
                Color.custom(.gray(.gray15))
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: AppPadding.medium.value) {
                        Text(searchWord)
                            .font(.pretendard(size: .body2, weight: .bold))
                            .foregroundStyle(.custom(.gray(.gray90)))
                        
                        VStack(spacing: 0) {
                            FilteredRestaurantList(
                                restaurants: restaurants,
                                isLoading: isLoading,
                                isLoadingMore: false,
                                isPicchelinFilterEnabled: isPicchelinFilterEnabled,
                                isMyPickFilterEnabled: isMyPickFilterEnabled,
                                onPicchelinFilterToggle: {
                                    store.send(.togglePicchelinFilter)
                                },
                                onMyPickFilterToggle: {
                                    store.send(.toggleMyPickFilter)
                                },
                                onLikeToggle: { id, like in
                                    store.send(.toggleRestaurantLike(id, like))
                                },
                                onRestaurantTap: { id in
                                    store.send(.restaurantTapped(id))
                                },
                                onLoadMore: {},
                                emptyMessage: "검색 결과가 없습니다."
                            )
                            
                            // 탭바가 가리지 않도록 추가
                            Rectangle()
                                .fill(.clear)
                                .frame(height: 110)
                        }
                    }
                    .padding(.horizontal, .xLarge)
                }
            }
            .navigationTitle("검색 결과")
            .navigationDestination(
                item: $store.scope(state: \.destination?.detail, action: \.destination.detail)
            ) { detailStore in
                RestaurantDetailView(store: detailStore)
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}
