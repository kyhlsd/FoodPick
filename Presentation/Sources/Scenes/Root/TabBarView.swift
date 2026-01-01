//
//  TabBarView.swift
//  Presentation
//
//  Created by Claude on 12/20/25.
//

import SwiftUI
import ComposableArchitecture

struct TabBarView: View {
    let store: StoreOf<TabBarFeature>
    
    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store

            let isTabBarVisible = store.isTabBarVisible

            ZStack(alignment: .bottom) {
                // TabView
                TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
                    ForEach(TabBarFeature.Tab.allCases, id: \.self) { tab in
                        NavigationStack {
                            tab.view(store: store)
                        }
                        .tag(tab)
                        .toolbar(.hidden, for: .tabBar)
                    }
                }

                // TabBar UI
                if isTabBarVisible {
                    GeometryReader { geometry in
                        WithPerceptionTracking {
                            let selectedTab = store.selectedTab
                            let width = geometry.size.width - 2 * AppPadding.xLarge.value
                            let tabWidth = width / 5
                            let barHeight: CGFloat = 70

                            ZStack(alignment: .bottom) {
                                // TabBar Background
                                TabBarBackgroundView(height: barHeight)

                                // TabBar Icon
                                HStack(spacing: 0) {
                                    ForEach(TabBarFeature.Tab.allCases, id: \.self) { tab in
                                        if tab == .pick {
                                            Spacer().frame(width: tabWidth)
                                        } else {
                                            TabBarButton(
                                                tab: tab,
                                                isSelected: selectedTab == tab,
                                                width: tabWidth,
                                                height: barHeight
                                            ) {
                                                store.send(.tabSelected(tab))
                                            }
                                        }
                                    }
                                }
                                .frame(height: barHeight)

                                CenterButton {
                                    store.send(.centerButtonTapped)
                                }
                                .offset(y: -barHeight + 28)
                            }
                            .padding(.horizontal, .xLarge)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                        }
                    }
                    .frame(height: 110)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .ignoresSafeArea(.keyboard)
            .fullScreenCover(
                item: $store.scope(state: \.destination?.pick, action: \.destination.pick)
            ) { pickStore in
                PickView(store: pickStore)
            }
        }
    }
}

// MARK: - TabBar Background
private struct TabBarBackgroundView: View {
    let height: CGFloat
    
    var body: some View {
        SineTabBarShape()
            .fill(.white)
            .frame(height: height)
            .clipShape(
                RoundedRectangle(cornerRadius: height / 2, style: .continuous)
            )
            .shadow(color: .custom(.gray(.gray75)).opacity(0.1), radius: 12)
    }
}

// MARK: - Sine Wave 형태 배경
private struct SineTabBarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let center = width / 2
        
        let curveWidth: CGFloat = 124
        let curveHeight: CGFloat = 36
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: center - (curveWidth / 2), y: 0))
        
        path.addCurve(
            to: CGPoint(x: center, y: curveHeight),
            control1: CGPoint(x: center - (curveWidth / 4), y: 0),
            control2: CGPoint(x: center - (curveWidth / 4), y: curveHeight)
        )
        
        path.addCurve(
            to: CGPoint(x: center + (curveWidth / 2), y: 0),
            control1: CGPoint(x: center + (curveWidth / 4), y: curveHeight),
            control2: CGPoint(x: center + (curveWidth / 4), y: 0)
        )
        
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - TabBar Button
private struct TabBarButton: View {
    let tab: TabBarFeature.Tab
    let isSelected: Bool
    let width: CGFloat
    let height: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                action()
            }
        } label: {
            if isSelected {
                tab.selectedIcon
                    .font(.system(size: 28))
                    .frame(width: width, height: height)
            } else {
                tab.nonSelectedIcon
                    .font(.system(size: 28))
                    .frame(width: width, height: height)
            }
        }
    }
}

// MARK: - Center Button
private struct CenterButton: View {
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.custom(.brand(.blackSprout)))
                    .shadow(color: .custom(.gray(.gray75)).opacity(0.3), radius: 12, x: 0, y: 0)
                
                TabBarFeature.Tab.pick.selectedIcon
                    .font(.system(size: 24))
            }
            .frame(width: 60, height: 60)
        }
    }
}

// MARK: - Tab Icon Extension
extension TabBarFeature.Tab {
    var selectedIcon: some View {
        switch self {
        case .home:
            return AppIcon.homeFill
                .foregroundStyle(.custom(.brand(.blackSprout)))
        case .order:
            return AppIcon.orderFill
                .foregroundStyle(.custom(.brand(.blackSprout)))
        case .pick:
            return AppIcon.pickFill
                .foregroundStyle(.custom(.gray(.gray0)))
        case .community:
            return AppIcon.communityFill
                .foregroundStyle(.custom(.brand(.blackSprout)))
        case .profile:
            return AppIcon.profileFill
                .foregroundStyle(.custom(.brand(.blackSprout)))
        }
    }
    
    var nonSelectedIcon: some View {
        let icon: Image
        switch self {
        case .home:
            icon = AppIcon.homeEmpty
        case .order:
            icon = AppIcon.orderEmpty
        case .pick:
            icon = AppIcon.pickEmpty
        case .community:
            icon = AppIcon.communityEmpty
        case .profile:
            icon = AppIcon.profileEmpty
        }
        return icon.foregroundStyle(.custom(.gray(.gray30)))
    }
    
    @ViewBuilder
    @MainActor
    func view(store: StoreOf<TabBarFeature>) -> some View {
        switch self {
        case .home:
            HomeView(store: store.scope(state: \.home, action: \.home))
        case .order:
            OrderView(store: store.scope(state: \.order, action: \.order))
        case .pick:
            Color.clear
        case .community:
            Text("Community")
        case .profile:
            Text("Profile")
        }
    }
}

#Preview {
    TabBarView(
        store: Store(initialState: TabBarFeature.State()) {
            TabBarFeature()
        }
    )
}
