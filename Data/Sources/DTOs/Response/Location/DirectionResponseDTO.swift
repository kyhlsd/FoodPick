//
//  DirectionResponseDTO.swift
//  Data
//
//  Created by 김영훈 on 1/14/26.
//

import Foundation
import Domain

struct DirectionResponseDTO: ResponseDTO {
    private let type: String
    private let features: [FeatureDTO]
}

private struct FeatureDTO: ResponseDTO {
    private let type: String
    private let geometry: GeometryDTO
    private let properties: PropertiesDTO
}

private enum GeometryDTO: ResponseDTO {
    case point(PointGeometryDTO)
    case lineString(LineStringGeometryDTO)
    
    enum CodingKeys: String, CodingKey {
        case type, coordinates
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        if type == "Point" {
            let coordinates = try container.decode([Double].self, forKey: .coordinates)
            self = .point(PointGeometryDTO(coordinates: coordinates))
        } else if type == "LineString" {
            let coordinates = try container.decode([[Double]].self, forKey: .coordinates)
            self = .lineString(LineStringGeometryDTO(coordinates: coordinates))
        } else {
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown geometry type")
        }
    }
}

private struct PointGeometryDTO: ResponseDTO {
    private let coordinates: [Double]
    
    init(coordinates: [Double]) {
        self.coordinates = coordinates
    }
}

private struct LineStringGeometryDTO: ResponseDTO {
    private let coordinates: [[Double]]
    
    init(coordinates: [[Double]]) {
        self.coordinates = coordinates
    }
}

private struct PropertiesDTO: ResponseDTO {
    // 공통 및 선택적 필드들
    private let index: Int
    private let name: String?
    private let description: String?
    
    // Point 전용 properties
    private let totalDistance: Int?
    private let totalTime: Int?
    private let pointIndex: Int?
    private let turnType: Int?
    private let pointType: String?
    
    // LineString 전용 properties
    private let lineIndex: Int?
    private let distance: Int?
    private let time: Int?
    private let roadType: Int?
    private let facilityType: String?
}

extension DirectionResponseDTO {
    var toDomain: DirectionResponse {
        return .init(
            type: type,
            features: features.map { $0.toDomain }
        )
    }
}

extension FeatureDTO {
    var toDomain: Feature {
        return .init(
            type: type,
            geometry: geometry.toDomain,
            properties: properties.toDomain
        )
    }
}

extension GeometryDTO {
    var toDomain: Geometry {
        switch self {
        case .point(let pointGeometryDTO):
            return .point(pointGeometryDTO.toDomain)
        case .lineString(let lineStringGeometryDTO):
            return .lineString(lineStringGeometryDTO.toDomain)
        }
    }
}

extension PointGeometryDTO {
    var toDomain: PointGeometry {
        return .init(coordinates: coordinates)
    }
}

extension LineStringGeometryDTO {
    var toDomain: LineStringGeometry {
        return .init(coordinates: coordinates)
    }
}

extension PropertiesDTO {
    var toDomain: Properties {
        return .init(
            index: index,
            name: name,
            description: description,
            totalDistance: totalDistance,
            totalTime: totalTime,
            pointIndex: pointIndex,
            turnType: turnType,
            pointType: pointType,
            lineIndex: lineIndex,
            distance: distance,
            time: time,
            roadType: roadType,
            facilityType: facilityType
        )
    }
}
