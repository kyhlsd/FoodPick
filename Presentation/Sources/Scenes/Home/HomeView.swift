//
//  HomeView.swift
//  Presentation
//
//  Created by 김영훈 on 12/22/25.
//

import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    let store: StoreOf<HomeFeature>
    
    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store
            
            ZStack {
                Color.custom(.brand(.brightSprout))
                    .ignoresSafeArea()
                
                GeometryReader { geometry in
                    WithPerceptionTracking {
                        ScrollView {
                            VStack(spacing: AppPadding.large.value) {
                                LocationView()
                                    .padding(.horizontal, .xLarge)
                                
                                MySearchBar(
                                    text: $store.searchText.sending(\.searchTextChanged)
                                ) {
                                    store.send(.searchSubmitted)
                                }
                                .padding(.horizontal, .xLarge)
                                
                                TrendingSearchView(
                                    store: store,
                                    trendingSearches: store.trendingSearches,
                                    currentIndex: store.currentTrendingIndex
                                )
                                .padding(.horizontal, .xLarge)
                                
                                VStack(spacing: 0) {
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(
                                    UnevenRoundedRectangle(
                                        topLeadingRadius: 20,
                                        topTrailingRadius: 20
                                    )
                                    .fill(Color.custom(.gray(.gray0)))
                                    .ignoresSafeArea(edges: .bottom)
                                )
                            }
                            .frame(minHeight: geometry.size.height)
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                .onAppear {
                    store.send(.onAppear)
                }
            }
            .hideKeyboardOnTap()
        }
    }
}

private struct LocationView: View {
    var body: some View {
        HStack(spacing: AppPadding.small.value) {
            AppIcon.location
            
            Text("문래역, 영등포구")
                .font(.custom(.pretendard(.body1)))
            
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
    let store: StoreOf<HomeFeature>
    let trendingSearches: [String]
    let currentIndex: Int
    
    var body: some View {
        HStack(spacing: 2) {
            AppIcon.glint
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundStyle(.custom(.brand(.deepSprout)))
            
            Text("인기 검색어")
                .font(.custom(.pretendard(.caption1)))
                .foregroundStyle(.custom(.brand(.deepSprout)))
            
            if !trendingSearches.isEmpty {
                Button {
                    store.send(.trendingSearchTapped(trendingSearches[currentIndex % trendingSearches.count]))
                } label: {
                    Text(
                        "\((currentIndex % trendingSearches.count) + 1) \(trendingSearches[currentIndex % trendingSearches.count])"
                    )
                    .font(.custom(.pretendard(.caption1)))
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

#Preview {
    HomeView(
        store: Store(initialState: HomeFeature.State()) {
            HomeFeature()
        }
    )
}
