//
//  OrderStatusTimelineItemDTO.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Domain
import Core

struct OrderStatusTimelineItemDTO: ResponseDTO {
    private let status: OrderStatusDTO
    private let completed: Bool
    private let changedAt: String
}

extension OrderStatusTimelineItemDTO {
    var toDomain: OrderStatusTimelineItem {
        let formatter = Core.DateFormatterProvider.iso8601
        return .init(status: status.toDomain,
                     completed: completed,
                     changedAt: formatter.date(from: changedAt) ?? Date()
        )
    }
}
