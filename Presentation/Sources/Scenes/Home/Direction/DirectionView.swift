//
//  DirectionView.swift
//  Presentation
//
//  Created by 김영훈 on 1/13/26.
//

import SwiftUI
import ComposableArchitecture
import KakaoMapsSDK

struct DirectionView: View {
    let store: StoreOf<DirectionFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ZStack {
                Color.custom(.brand(.brightSprout))
                    .ignoresSafeArea()
                
                if store.myLocation != nil {
                    KakaoMapView(store: store)
                        .ignoresSafeArea()
                        .overlay(alignment: .bottomTrailing) {
                            TrackingButton(store: store)
                                .padding([.trailing, .bottom], .large)
                        }
                } else {
                    LoadingView(title: "도보 길찾기 중...")
                }
                
                if store.isLoading {
                    LoadingView(title: "지도를 불러오는 중...")
                }
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    store.send(.dismiss)
                } label: {
                    AppIcon.xmarkCircle
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.custom(.gray(.gray60)))
                }
                .padding([.trailing, .top], .large)
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

private struct KakaoMapView: UIViewRepresentable {
    let store: StoreOf<DirectionFeature>
    
    func makeUIView(context: Context) -> KMViewContainer {
        let container = KMViewContainer()
        context.coordinator.setUpController(container)
        return container
    }
    
    func updateUIView(_ uiView: KMViewContainer, context: Context) {
        Task { @MainActor in
            if uiView.bounds.width > 0 && uiView.bounds.height > 0 {
                context.coordinator.prepareMap()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(store: store)
    }
    
    @MainActor
    final class Coordinator: NSObject, @MainActor MapControllerDelegate {
        var store: StoreOf<DirectionFeature>
        var controller: KMController?
        var isEnginePrepared = false
        var isEngineActivated = false
        
        init(store: StoreOf<DirectionFeature>) {
            self.store = store
        }
        
        func setUpController(_ viewContainer: KMViewContainer) {
            if controller == nil {
                controller = KMController(viewContainer: viewContainer)
                controller?.delegate = self
            }
        }
        
        func prepareMap() {
            guard let controller else { return }
            
            if !isEnginePrepared {
                controller.prepareEngine()
                isEnginePrepared = true
            }
        }
        
        func authenticationSucceeded() {
            guard let controller else { return }
            if !isEngineActivated {
                controller.activateEngine()
                isEngineActivated = true
            }
        }
        
        func addViews() {
            let coordinate = store.restaurantLocation
            let mapviewInfo = MapviewInfo(
                viewName: "mapview",
                viewInfoName: "map",
                defaultPosition: MapPoint(
                    longitude: Double(coordinate.longitude),
                    latitude: Double(coordinate.latitude)
                )
            )
            
            controller?.addView(mapviewInfo)
        }
        
        func addViewSucceeded(_ viewName: String, viewInfoName: String) {
            store.send(.mapInitialized)
            
            guard let view = controller?.getView(viewName) as? KakaoMap else { return }
            
            // 레이어 및 스타일 초기 설정
            setupLayersAndStyles(view)
            
            // POI(핀) 표시
            displayMarkers(view)
        }

        // MARK: - Helper Methods
        private func setupLayersAndStyles(_ view: KakaoMap) {
            let labelManager = view.getLabelManager()
            
            // 레이어 생성
            let layerOptions = LabelLayerOptions(
                layerID: "directionLayer",
                competitionType: .none,
                competitionUnit: .poi,
                orderType: .rank,
                zOrder: 1000
            )
            _ = labelManager.addLabelLayer(option: layerOptions)
            
            // 스타일 리사이징 및 등록
            let pinSize = CGSize(width: 40, height: 40)
            
            addPoiStyle(
                labelManager,
                styleID: "restaurantStyle",
                image: AppIcon.endPin?.resized(to: pinSize)
            )
            
            addPoiStyle(
                labelManager,
                styleID: "myLocationStyle",
                image: AppIcon.startPin?.resized(to: pinSize)
            )
        }

        private func addPoiStyle(_ manager: LabelManager, styleID: String, image: UIImage?) {
            let iconStyle = PoiIconStyle(
                symbol: image,
                anchorPoint: CGPoint(x: 0.5, y: 1.0)
            )
            let poiStyle = PoiStyle(
                styleID: styleID,
                styles: [PerLevelPoiStyle(iconStyle: iconStyle, level: 0)]
            )
            manager.addPoiStyle(poiStyle)
        }

        private func displayMarkers(_ view: KakaoMap) {
            guard let layer = view.getLabelManager().getLabelLayer(layerID: "directionLayer") else { return }
            
            // 식당 핀
            let restaurantPoint = MapPoint(
                longitude: Double(store.restaurantLocation.longitude),
                latitude: Double(store.restaurantLocation.latitude)
            )
            layer.addPoi(option: PoiOptions(styleID: "restaurantStyle"), at: restaurantPoint)?.show()

            // 내 위치 핀
            guard let myLocation = store.myLocation else { return }
            
            let myPoint = MapPoint(
                longitude: Double(myLocation.longitude),
                latitude: Double(myLocation.latitude)
            )
            layer.addPoi(option: PoiOptions(styleID: "myLocationStyle"), at: myPoint)?.show()
            
            // 여백을 상하좌우에 추가
            let latDiff = abs(restaurantPoint.wgsCoord.latitude - myPoint.wgsCoord.latitude)
            let lonDiff = abs(restaurantPoint.wgsCoord.longitude - myPoint.wgsCoord.longitude)
            
            let margin = 0.2
            let minLatitude = min(restaurantPoint.wgsCoord.latitude, myPoint.wgsCoord.latitude) - (latDiff * margin)
            let maxLattitude = max(restaurantPoint.wgsCoord.latitude, myPoint.wgsCoord.latitude) + (latDiff * margin)
            let minLongitude = min(restaurantPoint.wgsCoord.longitude, myPoint.wgsCoord.longitude) - (lonDiff * margin)
            let maxLongitude = max(restaurantPoint.wgsCoord.longitude, myPoint.wgsCoord.longitude) + (lonDiff * margin)
            
            // 가상의 외곽 지점들로 영역 생성
            let p1 = MapPoint(longitude: minLongitude, latitude: minLatitude)
            let p2 = MapPoint(longitude: maxLongitude, latitude: maxLattitude)
            
            let paddedArea = AreaRect(points: [p1, p2])
            view.moveCamera(CameraUpdate.make(area: paddedArea))
        }
    }
}

// MARK: - Loading View {
private struct LoadingView: View {
    let title: String
    
    var body: some View {
        ProgressView(title)
            .font(.pretendard(size: .body1, weight: .semiBold))
            .foregroundStyle(.custom(.gray(.gray0)))
            .padding()
            .background(.custom(.brand(.blackSprout)))
            .clipShape(
                RoundedRectangle(cornerRadius: 10)
            )
    }
}

// MARK: - Tracking Button
private struct TrackingButton: View {
    @Perception.Bindable var store: StoreOf<DirectionFeature>
    
    var body: some View {
        WithPerceptionTracking {
            Button {
                store.send(.trackingTapped)
            } label: {
                AppIcon.distance
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(store.isTracking
                                     ? .custom(.brand(.blackSprout))
                                     : .custom(.gray(.gray0))
                    )
                    .padding(.all, .small)
                    .background(
                        Circle()
                            .fill(.custom(.brand(.brightSprout)))
                    )
                    .overlay {
                        Circle()
                            .stroke(.custom(.gray(.gray45)))
                    }
            }
        }
    }
}

// MARK: - Extension
private extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
