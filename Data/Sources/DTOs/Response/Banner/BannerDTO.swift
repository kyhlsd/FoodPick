//
//  BannerDTO.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Domain

struct BannerDTO: ResponseDTO {
    private let name: String
    private let imageURL: String
    private let payload: PayloadDTO
    
    enum CodingKeys: String, CodingKey {
        case name
        case imageURL = "imageUrl"
        case payload
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.imageURL = try container.decode(String.self, forKey: .imageURL)
        self.payload = try container.decode(PayloadDTO.self, forKey: .payload)
    }
}

extension BannerDTO {
    var toDomain: Banner {
        return .init(name: name,
                     imageURL: imageURL,
                     payload: payload.toDomain
        )
    }
}

struct PayloadDTO: ResponseDTO {
    private let type: PayloadTypeDTO
    private let value: String
}

extension PayloadDTO {
    var toDomain: Payload {
        return .init(type: type.toDomain, value: value)
    }
}

enum PayloadTypeDTO: String, ResponseDTO {
    case webView = "WEBVIEW"
}

extension PayloadTypeDTO {
    var toDomain: PayloadType {
        switch self {
        case .webView:
            return .webView
        }
    }
}
