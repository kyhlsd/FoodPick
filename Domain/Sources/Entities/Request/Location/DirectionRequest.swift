//
//  DirectionRequest.swift
//  Domain
//
//  Created by 김영훈 on 1/14/26.
//

import Foundation

public struct DirectionRequest: Sendable {
    public let startX: Double
    public let startY: Double
    public let endX: Double
    public let endY: Double
    public let startName: String
    public let endName: String
    
    public init(startX: Double, startY: Double, endX: Double, endY: Double, startName: String, endName: String) {
        self.startX = startX
        self.startY = startY
        self.endX = endX
        self.endY = endY
        self.startName = startName
        self.endName = endName
    }
}
