//
//  DirectionView.swift
//  Presentation
//
//  Created by 김영훈 on 1/13/26.
//

import SwiftUI
import ComposableArchitecture
import KakaoMapsSDK
import Domain

struct DirectionView: View {
    let store: StoreOf<DirectionFeature>
    
    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store
            ZStack {
                Color.custom(.brand(.brightSprout))
                    .ignoresSafeArea()
                
                if store.directions != nil {
                    KakaoMapView(
                        directions: store.directions,
                        restaurantLocation: store.restaurantLocation,
                        startLocation: store.startGeolocation,
                        currentGeolocation: store.currentGeolocation,
                        isTracking: store.isTracking
                    ) {
                        store.send(.mapInitialized)
                    }
                    .ignoresSafeArea()
                    .overlay(alignment: .bottom) {
                        GuideView(store: store)
                            .padding([.bottom, .horizontal], .large)
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
    let directions: DirectionResponse?
    let restaurantLocation: Geolocation
    let startLocation: Geolocation?
    let currentGeolocation: Geolocation?
    let isTracking: Bool
    let onMapInitialized: () -> Void
    
    func makeUIView(context: Context) -> KMViewContainer {
        let container = KMViewContainer()
        context.coordinator.setUpController(container)
        return container
    }
    
    func updateUIView(_ uiView: KMViewContainer, context: Context) {
        context.coordinator.directions = directions
        context.coordinator.restaurantLocation = restaurantLocation
        context.coordinator.startLocation = startLocation
        
        Task { @MainActor in
            if uiView.bounds.width > 0 && uiView.bounds.height > 0 {
                context.coordinator.prepareMap()
            }
            
            context.coordinator.updateRouteAndFixedMarkers()
            
            if let currentGeolocation {
                context.coordinator.updateUserMarker(
                    location: currentGeolocation,
                    isTracking: isTracking
                )
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onMapInitialized: onMapInitialized)
    }
    
    @MainActor
    final class Coordinator: NSObject, @MainActor MapControllerDelegate {
        var controller: KMController?
        var isEnginePrepared = false
        var isEngineActivated = false
        var isRouteDrawn = false
        let onMapInitialized: () -> Void
        
        var directions: DirectionResponse?
        var restaurantLocation: Geolocation?
        var startLocation: Geolocation?
        private var lastDrawnDirectionID: String?
                
        init(onMapInitialized: @escaping () -> Void) {
            self.onMapInitialized = onMapInitialized
        }
        
        func setUpController(_ viewContainer: KMViewContainer) {
            if controller == nil {
                controller = KMController(viewContainer: viewContainer)
                controller?.delegate = self
            }
        }
        
        func prepareMap() {
            guard let controller, !isEnginePrepared else { return }
            controller.prepareEngine()
            isEnginePrepared = true
        }
        
        func authenticationSucceeded() {
            guard let controller, !isEngineActivated else { return }
            controller.activateEngine()
            isEngineActivated = true
        }
        
        func addViews() {
            let mapviewInfo = MapviewInfo(
                viewName: "mapview",
                viewInfoName: "map",
                defaultPosition: MapPoint(
                    longitude: 0,
                    latitude: 0
                )
            )
            controller?.addView(mapviewInfo)
        }
        
        func addViewSucceeded(_ viewName: String, viewInfoName: String) {
            onMapInitialized()
            
            guard let view = controller?.getView(viewName) as? KakaoMap else { return }
            setupLayersAndStyles(view)
            updateRouteAndFixedMarkers()
        }
        
        func updateUserMarker(location: Geolocation, isTracking: Bool) {
            guard let view = controller?.getView("mapview") as? KakaoMap,
            let layer = view.getLabelManager().getLabelLayer(layerID: "directionLayer") else {
                return
            }
            
            let currentPoint = MapPoint(
                longitude: location.longitude,
                latitude: location.latitude
            )
            
            if isTracking {
                // 트래킹 중이면 핀을 표시하거나 이동
                if let poi = layer.getPoi(poiID: "currentLocationPOI") {
                    poi.moveAt(currentPoint, duration: 200)
                    poi.show()
                } else {
                    let options = PoiOptions(styleID: "currentLocationStyle", poiID: "currentLocationPOI")
                    layer.addPoi(option: options, at: currentPoint)?.show()
                }
                
                // 카메라 이동
                let cameraUpdate = CameraUpdate.make(target: currentPoint, zoomLevel: 17, mapView: view)
                view.animateCamera(
                    cameraUpdate: cameraUpdate,
                    options: CameraAnimationOptions(autoElevation: false, consecutive: true, durationInMillis: 200)
                )
            } else {
                // 트래킹 중이 아니면 현재 위치 핀을 숨김
                if let poi = layer.getPoi(poiID: "currentLocationPOI") {
                    poi.hide()
                }
            }
        }
        
        func updateRouteAndFixedMarkers() {
            guard let view = controller?.getView("mapview") as? KakaoMap else { return }
            guard let restaurant = restaurantLocation else { return }
            
            let currentID = "\(directions?.features.first?.properties.totalDistance ?? 0)"
            
            if directions != nil && lastDrawnDirectionID != currentID {
                displayRoute(view, directions: directions)
                displayMarkers(view, restaurant: restaurant, start: startLocation)
                lastDrawnDirectionID = currentID
            }
        }
        
        // MARK: - Helper Methods
        private func setupLayersAndStyles(_ view: KakaoMap) {
            let labelManager = view.getLabelManager()
            let routeManager = view.getRouteManager()
            
            // POI 레이어 생성
            let layerOptions = LabelLayerOptions(
                layerID: "directionLayer",
                competitionType: .none,
                competitionUnit: .poi,
                orderType: .rank,
                zOrder: 1000
            )
            _ = labelManager.addLabelLayer(option: layerOptions)
            
            // 경로 레이어 생성
            _ = routeManager.addRouteLayer(
                layerID: "routeLayer",
                zOrder: 500
            )
            
            let perLevelStyle = PerLevelRouteStyle(
                width: 15,
                color: .systemBlue,
                strokeWidth: 2,
                strokeColor: .white,
                level: 0
            )
            let routeStyle = RouteStyle(styles: [perLevelStyle])
            let routeStyleSet = RouteStyleSet(styleID: "routeStyle", styles: [routeStyle])
            routeManager.addRouteStyleSet(routeStyleSet)
            
            // 스타일 리사이징 및 등록
            let pinSize = CGSize(width: 40, height: 40)
            let currentPinSize = CGSize(width: 24, height: 24)
            
            addPoiStyle(
                labelManager,
                styleID: "restaurantStyle",
                image: AppIcon.endPin?.resized(to: pinSize)
            )
            
            addPoiStyle(
                labelManager,
                styleID: "startLocationStyle",
                image: AppIcon.startPin?.resized(to: pinSize)
            )
            
            addPoiStyle(
                labelManager,
                styleID: "currentLocationStyle",
                image: AppIcon.currentPin?
                    .resized(to: currentPinSize)
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

        private func displayMarkers(_ view: KakaoMap, restaurant: Geolocation, start: Geolocation?) {
            guard let layer = view.getLabelManager().getLabelLayer(layerID: "directionLayer") else { return }
            
            // 식당 핀
            let restaurantPoint = MapPoint(
                longitude: restaurant.longitude,
                latitude: restaurant.latitude
            )
            if let poi = layer.getPoi(poiID: "restaurantPOI") {
                poi.moveAt(restaurantPoint, duration: 0)
            } else {
                layer.addPoi(option: PoiOptions(styleID: "restaurantStyle", poiID: "restaurantPOI"), at: restaurantPoint)?.show()
            }
            
            // 시작 핀
            if let start {
                let startPoint = MapPoint(
                    longitude: start.longitude,
                    latitude: start.latitude
                )
                if let poi = layer.getPoi(poiID: "startPOI") {
                    poi.moveAt(startPoint, duration: 0)
                } else {
                    layer.addPoi(option: PoiOptions(styleID: "startLocationStyle", poiID: "startPOI"), at: startPoint)?.show()
                }
            }
        }
        
        private func displayRoute(_ view: KakaoMap, directions: DirectionResponse?) {
            guard let routeLayer = view.getRouteManager().getRouteLayer(layerID: "routeLayer"),
                  let directions else { return }
            
            routeLayer.clearAllRoutes()
            
            let routePaths = directions.features.compactMap { feature in
                if case let .lineString(lineGeometry) = feature.geometry {
                    return lineGeometry.coordinates.map {
                        MapPoint(longitude: $0[0], latitude: $0[1])
                    }
                }
                return nil
            }
            
            let segments = routePaths.map { RouteSegment(points: $0, styleIndex: 0)
            }
            let options = RouteOptions(
                routeID: "walkingPath",
                styleID: "routeStyle",
                zOrder: 0
            )
            options.segments = segments
            
            if let route = routeLayer.addRoute(option: options) {
                route.show()
                let allPoints = routePaths.flatMap { $0 }
                if !allPoints.isEmpty {
                    view.moveCamera(CameraUpdate.make(area: AreaRect(points: allPoints)))
                }
            }
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

// MARK: - Guide View {
private struct GuideView: View {
    @Perception.Bindable var store: StoreOf<DirectionFeature>
    
    var body: some View {
        WithPerceptionTracking {
            if !store.isLoading {
                VStack(alignment: .trailing, spacing: AppPadding.small.value) {
                    TrackingButton(store: store)
                        .padding([.trailing, .bottom], .large)
                    
                    HStack(spacing: AppPadding.medium.value) {
                        AuthenticatedImage(imagePath: store.restaurantInfo.restaurantImageURLs.first)
                            .frame(width: 60, height: 60)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 10)
                            )
                        
                        Text(store.restaurantInfo.name)
                            .font(.pretendard(size: .body1, weight: .semiBold))
                            .foregroundStyle(.custom(.gray(.gray90)))
                        
                        Spacer()
                        
                        VStack(spacing: AppPadding.tiny.value) {
                            Text(DistanceFormatter.format(Float(store.totalDistance)))
                                .font(.pretendard(size: .body1, weight: .semiBold))
                                .foregroundStyle(.custom(.brand(.blackSprout)))
                            
                            Text(formatTime(seconds: store.totalTime))
                                .font(.pretendard(size: .body3, weight: .medium))
                                .foregroundStyle(.custom(.gray(.gray75)))
                        }
                    }
                    .padding(.all, .medium)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.custom(.gray(.gray0)))
                    )
                    .frame(maxWidth: .infinity)
                }
            } else {
                EmptyView()
            }
        }
    }
    
    func formatTime(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)시간 \(minutes)분"
        } else {
            return "\(minutes)분"
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
