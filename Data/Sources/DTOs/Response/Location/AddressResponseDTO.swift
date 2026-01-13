//
//  AddressResponseDTO.swift
//  Data
//
//  Created by 김영훈 on 1/13/26.
//

import Domain

struct AddressResponseDTO: ResponseDTO {
    private let meta: MetaDTO
    private let documents: [DocumentDTO]
}

private struct MetaDTO: Decodable, Sendable {
    private let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
    }
}

private struct DocumentDTO: Decodable, Sendable {
    private let regionType: String
    private let code: String
    let addressName: String
    private let region1DepthName: String
    private let region2DepthName: String
    private let region3DepthName: String
    private let region4DepthName: String
    private let longitude: Double
    private let latitude: Double
    
    enum CodingKeys: String, CodingKey {
        case regionType = "region_type"
        case code
        case addressName = "address_name"
        case region1DepthName = "region_1depth_name"
        case region2DepthName = "region_2depth_name"
        case region3DepthName = "region_3depth_name"
        case region4DepthName = "region_4depth_name"
        case longitude = "x"
        case latitude = "y"
    }
}

extension AddressResponseDTO {
    var toDomain: String {
        let addressName = documents.first?.addressName
        guard let addressName else {
            return "알 수 없음"
        }
        
        let components = addressName.components(separatedBy: " ")
        
        let count = components.count
        if count >= 2 {
            let gu = components[count - 2]
            let dong = components[count - 1]
            return "\(dong), \(gu)"
        }
        
        return addressName
    }
}
