//
//  DirectionFeature.swift
//  Presentation
//
//  Created by 김영훈 on 1/13/26.
//

import Domain
import ComposableArchitecture

@Reducer
struct DirectionFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        var isLoading = true
        let restaurantInfo: RestaurantDetail
        var myGeolocation: Geolocation?
        var isTracking = false
        var directions: DirectionResponse?
        
        var restaurantLocation: Geolocation {
            return restaurantInfo.geolocation
        }
        
        var totalTime: Int {
            directions?.features.compactMap { $0.properties.totalTime }.reduce(0, +) ?? 0
        }
        
        var totalDistance: Int {
            directions?.features.compactMap { $0.properties.totalDistance }.reduce(0, +) ?? 0
        }
        
        @Presents var alert: AlertState<DirectionFeature.Alert>?
    }
    
    // MARK: - Action
    enum Action {
        case onAppear
        case mapInitialized
        case trackingTapped
        case fetchDirections
        case directionsLoaded(DirectionResponse)
        case directionsFailed(Error)
        case dismiss
        case alert(PresentationAction<DirectionFeature.Alert>)
    }
    
    // MARK: - Dependencies
    @Dependency(\.getUserLocation) var getUserLocation
    @Dependency(\.fetchDirections) var fetchDirections
    @Dependency(\.dismiss) var dismiss
    
    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchDirections)
                
            case .mapInitialized:
                state.isLoading = false
                return .none
                
            case .trackingTapped:
                state.isTracking.toggle()
                return .none
                
            case .fetchDirections:
                let myLocation = getUserLocation.execute()
                state.myGeolocation = myLocation.geolocation
                let request = DirectionRequest(
                    startX: myLocation.geolocation.longitude,
                    startY: myLocation.geolocation.latitude,
                    endX: state.restaurantLocation.longitude,
                    endY: state.restaurantLocation.latitude,
                    startName: myLocation.address,
                    endName: state.restaurantInfo.address
                )
                return .run { send in
                    do {
                        let response = try await fetchDirections.execute(request)
                        await send(.directionsLoaded(response))
                    } catch {
                        await send(.directionsFailed(error))
                    }
                }
                
            case let .directionsLoaded(directions):
                state.directions = directions
                return .none
                
            case let .directionsFailed(error):
                state.isLoading = false
                state.alert = AlertState {
                    TextState("길찾기 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none
                
            case .dismiss:
                return .run { _ in
                    await self.dismiss()
                }
                
            case .alert:
                return .none
            }
        }
        .ifLet(\.alert, action: \.alert)
    }
    
    enum Alert: Sendable {}
}

// 테스트 더미
/*
DirectionRequest(startX: 126.89571, startY: 37.53789, endX: 126.886557, endY: 37.51775, startName: "양평동4가, 영등포구", endName: "서울특별시 휴님의 진실의 파스방 어딘가의 지하500층")
RestaurantDetail(restaurantId: "6938dedf41d372ae02f7891a", category: Domain.RestaurantCategory.etc, name: "새싹 커피", description: "직접 로스팅한 스페셜티 원두로 내리는 정성 가득한 커피 전문점입니다.\n바리스타가 한 잔 한 잔 정성껏 추출합니다.", hashTags: ["#스페셜티커피", "#직접로스팅", "#문래카페"], open: "07:00", close: "22:00", address: "서울특별시 휴님의 진실의 파스방 어딘가의 지하500층", estimatedPickupTime: 22, parkingGuide: "면접디펜스 잘하면 무료", restaurantImageURLs: ["/data/stores/pickup_70_1765334731570.jpg", "/data/stores/pickup_8_1765334731579.jpg"], isPicchelin: true, isPick: true, pickCount: 2, totalReviewCount: 0, totalOrderCount: 0, totalRating: 0.0, creator: Domain.Profile(userId: "6938da7341d372ae02f7890c", nickname: "Hue", profileImage: Optional("/data/profiles/1746246312955.jpg")), geolocation: Domain.Geolocation(longitude: 126.886557, latitude: 37.51775), menuList: [Domain.Menu(menuId: "6938dfc041d372ae02f78949", restaurantId: "6938dedf41d372ae02f7891a", category: "스페셜", name: "티라미수", description: "에스프레소를 적신 촉촉한 시트와 마스카포네 크림의 조화", originInfo: "마스카포네: 이탈리아산", price: 800, isSoldOut: true, tags: ["베스트 페어링"], menuImageURL: "/data/menus/1765334861116.jpg", createdAt: 2025-12-10 02:49:36 +0000, updatedAt: 2025-12-10 02:49:36 +0000), Domain.Menu(menuId: "6938dfa641d372ae02f78943", restaurantId: "6938dedf41d372ae02f7891a", category: "티", name: "얼그레이 밀크티", description: "향긋한 얼그레이 찻잎을 우려낸 진한 밀크티", originInfo: "찻잎: 스리랑카산, 우유: 국내산", price: 550, isSoldOut: false, tags: [], menuImageURL: "/data/menus/1765334845441.jpg", createdAt: 2025-12-10 02:49:10 +0000, updatedAt: 2025-12-10 02:49:10 +0000), Domain.Menu(menuId: "6938df9541d372ae02f7893d", restaurantId: "6938dedf41d372ae02f7891a", category: "스무디/에이드", name: "딸기 스무디", description: "신선한 딸기를 듬뿍 넣어 갈아만든 상큼한 스무디", originInfo: "딸기: 국내산", price: 700, isSoldOut: false, tags: ["시즌 인기"], menuImageURL: "/data/menus/1765334829136.jpg", createdAt: 2025-12-10 02:48:53 +0000, updatedAt: 2025-12-10 02:48:53 +0000), Domain.Menu(menuId: "6938df8141d372ae02f78937", restaurantId: "6938dedf41d372ae02f7891a", category: "커피", name: "바닐라 라떼", description: "부드러운 우유 거품과 바닐라 시럽이 조화로운 달콤한 라떼", originInfo: "원두: 콜롬비아산, 우유: 국내산", price: 600, isSoldOut: false, tags: ["달콤함"], menuImageURL: "/data/menus/1765334817131.jpg", createdAt: 2025-12-10 02:48:33 +0000, updatedAt: 2025-12-10 02:48:33 +0000), Domain.Menu(menuId: "6938df6141d372ae02f78931", restaurantId: "6938dedf41d372ae02f7891a", category: "커피", name: "시그니처 아메리카노", description: "에티오피아 예가체프 원두로 추출한 깔끔한 아메리카노", originInfo: "원두: 에티오피아산", price: 500, isSoldOut: false, tags: ["인기 1위", "시그니처"], menuImageURL: "/data/menus/1765334795962.jpg", createdAt: 2025-12-10 02:48:01 +0000, updatedAt: 2025-12-10 02:48:01 +0000)], createdAt: 2025-12-10 02:45:51 +0000, updatedAt: 2025-12-10 02:45:51 +0000)
*/
