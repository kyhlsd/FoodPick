//
//  DirectionResponse.swift
//  Domain
//
//  Created by 김영훈 on 1/14/26.
//

import Foundation

public struct DirectionResponse: Sendable {
    public let type: String
    public let features: [Feature]
    
    public init(type: String, features: [Feature]) {
        self.type = type
        self.features = features
    }
}

public struct Feature: Sendable {
    public let type: String
    public let geometry: Geometry
    public let properties: Properties
    
    public init(type: String, geometry: Geometry, properties: Properties) {
        self.type = type
        self.geometry = geometry
        self.properties = properties
    }
}

public enum Geometry: Sendable {
    case point(PointGeometry)
    case lineString(LineStringGeometry)
}

public struct PointGeometry: Sendable {
    public let coordinates: [Double]
    
    public init(coordinates: [Double]) {
        self.coordinates = coordinates
    }
}

public struct LineStringGeometry: Sendable {
    public let coordinates: [[Double]]
    
    public init(coordinates: [[Double]]) {
        self.coordinates = coordinates
    }
}

public struct Properties: Sendable {
    // 공통 및 선택적 필드들
    public let index: Int
    public let name: String?
    public let description: String?
    
    // Point 전용 properties
    public let totalDistance: Int?
    public let totalTime: Int?
    public let pointIndex: Int?
    public let turnType: Int?
    public let pointType: String?
    
    // LineString 전용 properties
    public let lineIndex: Int?
    public let distance: Int?
    public let time: Int?
    public let roadType: Int?
    public let facilityType: String?
    
    public init(index: Int, name: String?, description: String?, totalDistance: Int?, totalTime: Int?, pointIndex: Int?, turnType: Int?, pointType: String?, lineIndex: Int?, distance: Int?, time: Int?, roadType: Int?, facilityType: String?) {
        self.index = index
        self.name = name
        self.description = description
        self.totalDistance = totalDistance
        self.totalTime = totalTime
        self.pointIndex = pointIndex
        self.turnType = turnType
        self.pointType = pointType
        self.lineIndex = lineIndex
        self.distance = distance
        self.time = time
        self.roadType = roadType
        self.facilityType = facilityType
    }
}
