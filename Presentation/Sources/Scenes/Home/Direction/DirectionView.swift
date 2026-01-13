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
                KakaoMapView(store: store)
                    .ignoresSafeArea()
                
                if store.isLoading {
                    ProgressView("지도를 불러오는 중...")
                        .padding()
                        .background(.custom(.brand(.blackSprout)))
                        .clipShape(
                            RoundedRectangle(cornerRadius: 10)
                        )
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
            let coordinate = store.centerCoordinate
            let mapviewInfo = MapviewInfo(
                viewName: "mapview",
                viewInfoName: "map",
                defaultPosition: MapPoint(
                    longitude: coordinate.longitude,
                    latitude: coordinate.latitude
                )
            )
            
            controller?.addView(mapviewInfo)
        }
        
        func addViewSucceeded(_ viewName: String, viewInfoName: String) {
            store.send(.mapInitialized)
            
            guard let view = controller?.getView(viewName) as? KakaoMap else { return }
            let labelManager = view.getLabelManager()
            
            let layerOptions = LabelLayerOptions(
                layerID: "restaurantLayer",
                competitionType: .none,
                competitionUnit: .poi,
                orderType: .rank,
                zOrder: 1000
            )
            _ = labelManager.addLabelLayer(option: layerOptions)
            
            let iconStyle = PoiIconStyle(
                symbol: UIImage(systemName: "mappin.and.ellipse"),
                anchorPoint: CGPoint(x: 0.5, y: 1.0)
            )
            let poiStyle = PoiStyle(
                styleID: "restaurantStyle",
                styles: [PerLevelPoiStyle(iconStyle: iconStyle, level: 0)]
            )
            labelManager.addPoiStyle(poiStyle)
            
            if let layer = labelManager.getLabelLayer(layerID: "restaurantLayer") {
                let poiOptions = PoiOptions(styleID: "restaurantStyle")
                poiOptions.rank = 0
                
                let mapPoint = MapPoint(
                    longitude: Double(store.restaurantLocation.longitude),
                    latitude: Double(store.restaurantLocation.latitude)
                )
                
                if let poi = layer.addPoi(option: poiOptions, at: mapPoint) {
                    poi.show()
                }
            }
        }
    }
}
