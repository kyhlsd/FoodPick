//
//  OrderView.swift
//  Presentation
//
//  Created by 김영훈 on 1/1/26.
//

import SwiftUI
import Domain
import ComposableArchitecture

struct OrderView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack {
                    MessageText()
                        .padding(.bottom, .xLarge)
                }
                .background(.custom(.gray(.gray0)))
                
                MyDivider()
                
                VStack(spacing: AppPadding.large.value) {
                    HStack {
                        Text("주문 현황")
                            .font(.pretendard(size: .body2, weight: .bold))
                            .foregroundStyle(.custom(.gray(.gray60)))
                        
                        Spacer()
                    }
                    .padding(.top, .xLarge)
                    
                    OrderRestaurantView()
                }
                .padding(.horizontal, .xLarge)
                .background(.custom(.gray(.gray15)))
                
                Spacer()
            }
        }
    }
}

private struct MessageText: View {
    var body: some View {
        Text(Self.attributedString)
            .padding(.horizontal, .xLarge)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.custom(.brand(.brightSprout)))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.custom(.brand(.deepSprout)), lineWidth: 1)
            )
            .shadow(color: .init(hex: "#525156").opacity(0.2),
                    radius: 12,
                    x: 0,
                    y: 4
            )
    }
    
    private static let attributedString: AttributedString = {
        var text = AttributedString("픽업을 하실 때는 주문번호를 꼭 말씀해주세요!")
        
        text.foregroundColor = .custom(.brand(.deepSprout))
        text.font = .jalnan(.caption1) // Font 타입 변환 필요할 수 있음
        
        if let range = text.range(of: "픽업") {
            text[range].foregroundColor = .custom(.brand(.blackSprout))
        }
        
        if let range = text.range(of: "주문번호") {
            text[range].foregroundColor = .custom(.brand(.blackSprout))
        }
        
        return text
    }()
}

private struct OrderRestaurantView: View {
    var body: some View {
        VStack(spacing: AppPadding.small.value) {
            HStack(spacing: AppPadding.large.value) {
                // 주문 가게
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: AppPadding.tiny.value) {
                        Text("주문번호")
                            .font(.jalnan(.caption1))
                            .foregroundStyle(.custom(.gray(.gray45)))

                        Text("A4922")
                            .font(.jalnan(.caption1))
                            .foregroundStyle(.custom(.gray(.gray60)))
                    }

                    Text("새싹 도넛 가게")
                        .font(.jalnan(.body1))
                        .foregroundStyle(.custom(.brand(.blackSprout)))
                        .padding(.top, .small)

                    Text("2025년 4월 22일 오후 6:20")
                        .font(.pretendard(size: .caption2, weight: .semiBold))
                        .foregroundStyle(.custom(.brand(.brightSprout)))
                        .padding(.top, .tiny)

                    AuthenticatedImage(imagePath: nil)
                        .frame(height: 100)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.custom(.gray(.gray45)), lineWidth: 1)
                        )
                        .padding(.top, .medium)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // 주문 상태
                VStack(spacing: 0) {
                    ForEach(Array(OrderStatus.allCases.enumerated()), id: \.element) { index, status in

                        HStack(alignment: .top, spacing: AppPadding.small.value) {
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(.custom(.brand(.blackSprout)))
                                    .frame(width: 16, height: 16)
                                    .overlay(
                                        AppIcon.check
                                            .resizable()
                                            .frame(width: 10, height: 10)
                                            .foregroundStyle(.custom(.gray(.gray0)))
                                    )

                                // 마지막이 아니면 연결선
                                if index != OrderStatus.allCases.count - 1 {
                                    Rectangle()
                                        .fill(.custom(.brand(.blackSprout)))
                                        .frame(width: 4)
                                }
                            }

                            Text(status.rawValue)
                                .font(.pretendard(size: .caption2, weight: .semiBold))
                                .foregroundStyle(.custom(.gray(.gray90)))
                                .frame(width: 40, alignment: .leading)
                                .offset(y: 2)

                            Text("오후 6:20")
                                .font(.pretendard(size: .caption2, weight: .medium))
                                .foregroundStyle(.custom(.gray(.gray60)))
                                .offset(y: 2)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.all, .large)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.custom(.gray(.gray15)))
                )
            }
        }
        .padding(.all, .large)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.custom(.gray(.gray0)))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.custom(.brand(.brightSprout)), lineWidth: 1)
        )
        .shadow(color: .init(hex: "#7B7886").opacity(0.08),
                radius: 12,
                x: 0,
                y: 4
        )
    }
}

#Preview {
    OrderView()
}
