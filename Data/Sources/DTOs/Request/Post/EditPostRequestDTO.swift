//
//  EditPostRequestDTO.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

import Domain

struct EditPostRequestDTO: Encodable {
    private let category: String?
    private let title: String?
    private let content: String?
    private let restaurantId: String?
    private let latitude: Double?
    private let longitude: Double?
    private let files: [String]?
    
    enum CodingKeys: String, CodingKey {
        case category
        case title
        case content
        case restaurantId = "store_id"
        case latitude
        case longitude
        case files
    }
}

extension EditPostRequestDTO {
    init(from domain: EditPostRequest) {
        self.init(category: domain.category?.rawValue,
                  title: domain.title,
                  content: domain.content,
                  restaurantId: domain.restaurantId,
                  latitude: domain.latitude,
                  longitude: domain.longitude,
                  files: domain.files
        )
    }
}
