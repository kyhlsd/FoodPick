//
//  OrderStatusDTO.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Domain

enum OrderStatusDTO: String {
    case pending = "PENDING_APPROVAL"
    case approved = "APPROVED"
    case inProgress = "IN_PROGRESS"
    case ready = "READY_FOR_PICKUP"
    case pickedUp = "PICKED_UP"
}

extension OrderStatusDTO: ResponseDTO {
    var toDomain: OrderStatus {
        switch self {
        case .pending:
            return .pending
        case .approved:
            return .approved
        case .inProgress:
            return .inProgress
        case .ready:
            return .ready
        case .pickedUp:
            return .pickedUp
        }
    }
}

extension OrderStatusDTO {
    init(from domain: OrderStatus) {
        switch domain {
        case .pending:
            self = .pending
        case .approved:
            self = .approved
        case .inProgress:
            self = .inProgress
        case .ready:
            self = .ready
        case .pickedUp:
            self = .pickedUp
        }
    }
}
