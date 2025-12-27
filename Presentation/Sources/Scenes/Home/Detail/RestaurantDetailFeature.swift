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

        var menuSection = MenuSectionFeature.State()
        var cartSection = CartSectionFeature.State()

        @Presents var alert: AlertState<RestaurantDetailFeature.Alert>?
        @Presents var destination: Destination.State?
    }

    // MARK: - Action
    enum Action: Sendable {
        case onAppear
        case fetchRestaurantInfo
        case restaurantInfoLoaded(RestaurantDetail)
        case restaurantInfoLoadFailed(Error)
        case imageIndexChanged(Int)
        case toggleRestaurantLike
        case restaurantLikeToggled(LikeStatus)
        case restaurantLikeToggleFailed(Error)
        case menuSection(MenuSectionFeature.Action)
        case cartSection(CartSectionFeature.Action)
        case alert(PresentationAction<RestaurantDetailFeature.Alert>)
        case destination(PresentationAction<Destination.Action>)
    }

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Scope(state: \.menuSection, action: \.menuSection) {
            MenuSectionFeature()
        }

        Scope(state: \.cartSection, action: \.cartSection) {
            CartSectionFeature()
        }

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
                state.menuSection.restaurantInfo = restaurantInfo

                // 첫 번째 카테고리 자동 선택
                if let firstCategory = state.menuSection.menuCategories.first {
                    state.menuSection.selectedMenuCategory = firstCategory
                }

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

            case let .menuSection(.menuTapped(menu)):
                // 장바구니에 이미 있는 메뉴인지 확인하고 수량 가져오기
                let existingItem = state.cartSection.cartItems.first { $0.menu.menuId == menu.menuId }
                let isInCart = existingItem != nil
                let existingQuantity = existingItem?.quantity ?? 1

                var menuDetailState = MenuDetailFeature.State(menu: menu)
                menuDetailState.quantity = existingQuantity
                menuDetailState.isInCart = isInCart

                state.destination = .menuDetail(menuDetailState)
                return .none

            case .menuSection:
                return .none

            case .cartSection(.checkoutTapped):
                // TODO: 결제 화면으로 이동
                return .none

            case .cartSection:
                return .none

            case .alert:
                return .none

            case .destination(.presented(.menuDetail(.addToCartTapped))):
                // 메뉴 상세에서 장바구니 담기/수정하기 버튼 클릭 시
                guard let menuDetailState = state.destination?.menuDetail else { return .none }
                let menu = menuDetailState.menu
                let quantity = menuDetailState.quantity

                // 수량이 0인 경우 장바구니에서 삭제
                if quantity == 0 {
                    return .send(.cartSection(.removeFromCart(menuId: menu.menuId)))
                }

                // 이미 장바구니에 있는 메뉴인지 확인
                if state.cartSection.cartItems.contains(where: { $0.menu.menuId == menu.menuId }) {
                    // 있으면 수량 업데이트
                    return .send(.cartSection(.updateQuantity(menuId: menu.menuId, quantity: quantity)))
                } else {
                    // 없으면 새로 추가
                    return .send(.cartSection(.addToCart(menu: menu, quantity: quantity)))
                }

            case .destination:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        .ifLet(\.$destination, action: \.destination)
    }

    // MARK: - Dependencies
    @Dependency(\.fetchRestaurantInfo) var fetchRestaurantInfoUseCase
    @Dependency(\.toggleRestaurantLike) var toggleRestaurantLikeUseCase

    enum Alert: Sendable {}
}

// MARK: - Destinations
extension RestaurantDetailFeature {
    @Reducer
    enum Destination {
        case menuDetail(MenuDetailFeature)
    }
}

extension RestaurantDetailFeature.Destination.State: Sendable {}
