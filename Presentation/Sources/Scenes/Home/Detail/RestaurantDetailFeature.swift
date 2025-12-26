//
//  RestaurantDetailFeature.swift
//  Presentation
//
//  Created by 김영훈 on 12/26/25.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct RestaurantDetailFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        let restaurantId: String
        var restaurantInfo: RestaurantDetail?
        var isLoading = false
        var currentImageIndex = 0

        @Presents var alert: AlertState<RestaurantDetailFeature.Alert>?
    }

    // MARK: - Action
    enum Action {
        case onAppear
        case fetchRestaurantInfo
        case restaurantInfoLoaded(RestaurantDetail)
        case restaurantInfoLoadFailed(Error)
        case imageIndexChanged(Int)
        case toggleRestaurantLike
        case restaurantLikeToggled(LikeStatus)
        case restaurantLikeToggleFailed(Error)
        case alert(PresentationAction<RestaurantDetailFeature.Alert>)
    }

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchRestaurantInfo)

            case .fetchRestaurantInfo:
                state.isLoading = true
                return .run { [restaurantId = state.restaurantId] send in
                    do {
                        let restaurantInfo = try await fetchRestaurantInfoUseCase.execute(id: restaurantId)
                        await send(.restaurantInfoLoaded(restaurantInfo))
                    } catch {
                        await send(.restaurantInfoLoadFailed(error))
                    }
                }

            case let .restaurantInfoLoaded(restaurantInfo):
                state.isLoading = false
                state.restaurantInfo = restaurantInfo
                return .none

            case let .restaurantInfoLoadFailed(error):
                state.isLoading = false
                state.alert = AlertState {
                    TextState("가게 정보 로드 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case let .imageIndexChanged(index):
                state.currentImageIndex = index
                return .none

            case .toggleRestaurantLike:
                guard let currentLikeStatus = state.restaurantInfo?.isPick else { return .none }
                let newLikeStatus = !currentLikeStatus
                return .run { [restaurantId = state.restaurantId] send in
                    do {
                        let likeStatus = try await toggleRestaurantLikeUseCase.execute(id: restaurantId,
                                                                                       like: newLikeStatus)
                        await send(.restaurantLikeToggled(likeStatus))
                    } catch {
                        await send(.restaurantLikeToggleFailed(error))
                    }
                }

            case let .restaurantLikeToggled(likeStatus):
                if var restaurantInfo = state.restaurantInfo {
                    restaurantInfo.isPick = likeStatus.likeStatus
                    restaurantInfo.pickCount += likeStatus.likeStatus ? 1 : -1
                    state.restaurantInfo = restaurantInfo
                }
                return .none

            case let .restaurantLikeToggleFailed(error):
                state.alert = AlertState {
                    TextState("좋아요 변경 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    // MARK: - Dependencies
    @Dependency(\.fetchRestaurantInfo) var fetchRestaurantInfoUseCase
    @Dependency(\.toggleRestaurantLike) var toggleRestaurantLikeUseCase

    enum Alert: Sendable {}
}
