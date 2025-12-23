//
//  PicchelinView.swift
//  Presentation
//
//  Created by 김영훈 on 12/24/25.
//

import SwiftUI

struct PicchelinView: View {
    var body: some View {
        ZStack {
            PicchelinShape()
                .fill(.custom(.brand(.blackSprout)))
                .overlay {
                    PicchelinShape()
                        .stroke(.custom(.brand(.brightSprout)), lineWidth: 1)
                }
                .frame(width: 52, height: 20)

            HStack(spacing: AppPadding.tiny.value) {
                AppIcon.pickFill
                    .resizable()
                    .frame(width: 10.5, height: 10.5)
                    .foregroundStyle(.custom(.gray(.gray0)))

                Text("픽슐랭")
                    .font(.custom(.pretendard(.caption2)))
                    .foregroundStyle(.custom(.gray(.gray0)))
                
                Spacer()
                    .frame(width: 14)
            }
        }
        
    }
}

private struct PicchelinShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let radius = rect.height / 2
        let indentDepth = radius * 0.5

        // 왼쪽 반원의 중심 (x=0에 위치하여 오른쪽 반원만 보이게)
        let leftCircleCenter = CGPoint(x: 0, y: radius)

        // 시작점: 상단 왼쪽
        path.move(to: CGPoint(x: 0, y: 0))

        // 왼쪽 반원 그리기 (상단 -> 하단, 바깥으로 볼록하게)
        path.addArc(
            center: leftCircleCenter,
            radius: radius,
            startAngle: .degrees(-90),
            endAngle: .degrees(90),
            clockwise: true
        )

        // 하단 직선 (왼쪽 -> 오른쪽)
        path.addLine(to: CGPoint(x: rect.maxX - indentDepth, y: rect.maxY))

        // 오른쪽 "<" 모양 하단 -> 중앙 (안쪽으로 들어감)
        path.addLine(to: CGPoint(x: rect.maxX - indentDepth * 2, y: radius))

        // 오른쪽 "<" 모양 중앙 -> 상단
        path.addLine(to: CGPoint(x: rect.maxX - indentDepth, y: 0))

        // 상단 직선 (오른쪽 -> 왼쪽)
        path.addLine(to: CGPoint(x: 0, y: 0))

        path.closeSubpath()

        return path
    }
}

#Preview {
    PicchelinView()
}
