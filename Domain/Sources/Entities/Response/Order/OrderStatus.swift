//
//  OrderStatus.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public enum OrderStatus: String, Sendable {
    case pending = "승인 대기"
    case approved = "주문 승인"
    case inProgress = "조리 중"
    case ready = "픽업 대기"
    case pickedUp = "픽업 완료"
}
