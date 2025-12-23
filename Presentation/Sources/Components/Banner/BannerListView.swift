//
//  BannerListView.swift
//  Presentation
//
//  Created by 김영훈 on 12/23/25.
//

import SwiftUI
import ComposableArchitecture
import Domain

struct BannerListView: View {
    let store: StoreOf<BannerFeature>

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store

            let banners = store.banners
            let isLoading = store.isLoading
            let currentPage = store.currentPage

            VStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .custom(.brand(.blackSprout))))
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .background(.custom(.gray(.gray30)))
                } else if banners.isEmpty {
                    Text("배너가 없습니다")
                        .font(.custom(.pretendard(.body2)))
                        .foregroundStyle(.custom(.gray(.gray60)))
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .background(.custom(.gray(.gray30)))
                } else {
                    ZStack(alignment: .bottomTrailing) {
                        TabView(selection: $store.currentPage.sending(\.currentPageChanged)) {
                            ForEach(Array(banners.enumerated()), id: \.element) { index, banner in
                                BannerItemView(imagePath: banner.imageURL)
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 100)
                        .background(.custom(.gray(.gray30)))

                        // 페이지 인디케이터
                        Text("\(currentPage + 1) / \(banners.count)")
                            .font(.custom(.pretendard(.caption2)))
                            .foregroundStyle(.custom(.gray(.gray0)))
                            .frame(width: 44, height: 20)
                            .background(.custom(.gray(.gray75)).opacity(0.5), in: Capsule())
                            .overlay {
                                Capsule()
                                    .stroke(.custom(.gray(.gray60)), lineWidth: 1)
                            }
                            .padding([.trailing, .bottom], .small)
                    }
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

private struct BannerItemView: View {
    let imagePath: String?

    var body: some View {
        AuthenticatedImage(imagePath: imagePath)
    }
}

// MARK: - Preview
#Preview {
    BannerListView(
        store: Store(initialState: BannerFeature.State()) {
            BannerFeature()
        }
    )
}
