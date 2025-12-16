//
//  CreatePostRequestDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Domain

struct CreatePostRequestDTO: Encodable {
    private let category: String
    private let title: String
    private let content: String
    private let storeId: String
    private let latitude: Float
    private let longitude: Float
    private let files: [String]
    
    enum CodingKeys: String, CodingKey {
        case category
        case title
        case content
        case storeId = "store_id"
        case latitude
        case longitude
        case files
    }
}

extension CreatePostRequestDTO {
    init(from domain: CreatePostRequest) {
        self.init(category: domain.category.rawValue,
                  title: domain.title,
                  content: domain.content,
                  storeId: domain.storeId,
                  latitude: domain.latitude,
                  longitude: domain.longitude,
                  files: domain.files
        )
    }
}
