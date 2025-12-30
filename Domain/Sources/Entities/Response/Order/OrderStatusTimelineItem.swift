//
//  OrderStatusTimelineItem.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public struct OrderStatusTimelineItem: Sendable {
    public let status: OrderStatus
    public let completed: Bool
    public let changedAt: Date
    
    public init(status: OrderStatus, completed: Bool, changedAt: Date) {
        self.status = status
        self.completed = completed
        self.changedAt = changedAt
    }
}
