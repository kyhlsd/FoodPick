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
                } else if banners.isEmpty {
                    Text("배너가 없습니다")
                        .font(.pretendard(size: .body2, weight: .medium))
                        .foregroundStyle(.custom(.gray(.gray60)))
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                } else {
                    ZStack(alignment: .bottomTrailing) {
                        TabView(selection: $store.currentPage.sending(\.currentPageChanged)) {
                            ForEach(Array(banners.enumerated()), id: \.element) { index, banner in
                                BannerItemButton(
                                    banner: banner
                                ) {
                                    store.send(.bannerTapped(banner))
                                }
                                .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 100)

                        // 페이지 인디케이터
                        Text("\(currentPage + 1) / \(banners.count)")
                            .font(.pretendard(size: .caption2, weight: .regular))
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
            .fullScreenCover(
                item: $store.scope(state: \.destination?.webView, action: \.destination.webView)
            ) { webViewStore in
                EventWebView(store: webViewStore)
            }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

private struct BannerItemButton: View {
    let banner: Banner
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            AuthenticatedImage(imagePath: banner.imageURL)
        }
        .buttonStyle(.plain)
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
