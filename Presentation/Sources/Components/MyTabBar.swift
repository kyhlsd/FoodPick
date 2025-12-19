import SwiftUI

enum Tab: String, CaseIterable {
    case home = "house.fill"
    case document = "doc.text.fill"
    case center = "sparkles"
    case community = "person.3.fill"
    case profile = "person.fill"
}

struct CustomTabBarView: View {
    @State private var selectedTab: Tab = .home
    let sageGreen = Color(red: 117/255, green: 142/255, blue: 113/255)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 배경 컨텐츠 (앱의 메인 화면이 들어갈 자리)
            Color.gray.opacity(0.05).ignoresSafeArea()
            
            GeometryReader { geometry in
                let width = geometry.size.width
                let tabWidth = width / 5
                let barHeight: CGFloat = 70
                
                ZStack(alignment: .bottom) {
                    // 1. Sine Wave 형태의 배경 쉐이프
                    SineTabBarShape()
                        .fill(Color.white)
                        .frame(height: barHeight)
                        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: -5)
                    
                    // 2. 5등분 아이콘 배치
                    HStack(spacing: 0) {
                        TabBarButton(tab: .home, selectedTab: $selectedTab, width: tabWidth, activeColor: sageGreen)
                        TabBarButton(tab: .document, selectedTab: $selectedTab, width: tabWidth, activeColor: sageGreen)
                        
                        // 중앙 여백 (원형 버튼이 들어갈 공간)
                        Spacer().frame(width: tabWidth)
                        
                        TabBarButton(tab: .community, selectedTab: $selectedTab, width: tabWidth, activeColor: sageGreen)
                        TabBarButton(tab: .profile, selectedTab: $selectedTab, width: tabWidth, activeColor: sageGreen)
                    }
                    .frame(height: barHeight)
                    
                    // 3. 중앙 플로팅 버튼 (위로 더 띄움)
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            selectedTab = .center
                        }
                    }) {
                        ZStack {
                            // 버튼 주변에 아주 연한 광택이나 테두리를 주어 배경과 분리
                            Circle()
                                .fill(sageGreen)
                                .frame(width: 60, height: 60)
                                .shadow(color: sageGreen.opacity(0.4), radius: 10, x: 0, y: 6)
                            
                            Image(systemName: Tab.center.rawValue)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    // --- 수정 포인트: offset 값을 조정하여 버튼을 위로 더 띄움 ---
                    // 기존 -barHeight + 45에서 숫자를 줄여(더 마이너스로) 위로 올림
                    .offset(y: -barHeight + 28)
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .frame(height: 110) // 버튼이 위로 올라갔으므로 컨테이너 높이 확보
        }
    }
}

// MARK: - Sine Wave 형태의 쉐이프 (동일)
struct SineTabBarShape: Shape {
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

struct TabBarButton: View {
    let tab: Tab
    @Binding var selectedTab: Tab
    let width: CGFloat
    let activeColor: Color
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        }) {
            Image(systemName: tab.rawValue)
                .font(.system(size: 28))
                .foregroundColor(selectedTab == tab ? activeColor : Color.gray.opacity(0.3))
                .frame(width: width, height: 70)
                .contentShape(Rectangle())
        }
    }
}

struct CustomTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBarView()
    }
}
