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
                        .font(.custom(.pretendard(.body2)))
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
            .overlay {
                if case let .webView(urlString) = store.destination {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            store.send(.dismissDestination)
                        }

                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            Button {
                                store.send(.dismissDestination)
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundStyle(.custom(.gray(.gray60)))
                                    .padding()
                            }
                        }

                        AuthenticatedEventWebView(urlPath: urlString)
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.7)
                    .background(.white)
                    .cornerRadius(16)
                }
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
