//
//  BannerFeature.swift
//  Presentation
//
//  Created by 김영훈 on 12/23/25.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct BannerFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        var banners: [Banner] = []
        var isLoading = false
        var currentPage = 0

        @Presents var destination: Destination.State?
        @Presents var alert: AlertState<BannerFeature.Alert>?
    }

    // MARK: - Action
    enum Action {
        case onAppear
        case fetchBanners
        case bannersLoaded([Banner])
        case bannersLoadFailed(Error)
        case currentPageChanged(Int)
        case bannerTapped(Banner)
        case destination(PresentationAction<Destination.Action>)
        case alert(PresentationAction<BannerFeature.Alert>)
    }

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchBanners)

            case .fetchBanners:
                state.isLoading = true
                return .run { send in
                    do {
                        let banners = try await fetchMainBannersUseCase.execute()
                        await send(.bannersLoaded(banners))
                    } catch {
                        await send(.bannersLoadFailed(error))
                    }
                }

            case let .bannersLoaded(banners):
                state.isLoading = false
                state.banners = banners
                return .none

            case let .bannersLoadFailed(error):
                state.isLoading = false
                state.alert = AlertState {
                    TextState("배너 로드 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case let .currentPageChanged(page):
                state.currentPage = page
                return .none

            case let .bannerTapped(banner):
                state.destination = .webView(EventWebFeature.State(urlPath: banner.payload.value))
                return .none

            case .destination(.presented(.webView(.dismiss))):
                state.destination = nil
                return .none

            case .destination:
                return .none

            case .alert:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.alert, action: \.alert)
    }

    // MARK: - Dependencies
    @Dependency(\.fetchMainBanners) var fetchMainBannersUseCase

    enum Alert: Sendable {}
}

// MARK: - Destination
extension BannerFeature {
    @Reducer
    enum Destination {
        case webView(EventWebFeature)
    }
}
