//
//  MenuDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Foundation
import Domain
import Core

struct MenuDTO: ResponseDTO {
    private let menuId: String
    private let storeId: String
    private let category: String
    private let name: String
    private let description: String
    private let originInfo: String
    private let price: Int
    private let isSoldOut: Bool
    private let tags: [String]
    private let menuImageURL: String
    private let createdAt: String
    private let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case menuId = "menu_id"
        case storeId = "store_id"
        case category
        case name
        case description
        case originInfo = "origin_information"
        case price
        case isSoldOut = "is_sold_out"
        case tags
        case menuImageURL = "menu_image_url"
        case createdAt
        case updatedAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.menuId = try container.decode(String.self, forKey: .menuId)
        self.storeId = try container.decode(String.self, forKey: .storeId)
        self.category = try container.decode(String.self, forKey: .category)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.originInfo = try container.decode(String.self, forKey: .originInfo)
        self.price = try container.decode(Int.self, forKey: .price)
        self.isSoldOut = try container.decode(Bool.self, forKey: .isSoldOut)
        self.tags = try container.decode([String].self, forKey: .tags)
        self.menuImageURL = try container.decode(String.self, forKey: .menuImageURL)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
}

extension MenuDTO {
    var toDomain: Menu {
        let formatter = Core.DateFormatterProvider.iso8601
        return .init(menuId: menuId,
                     storeId: storeId,
                     category: category,
                     name: name,
                     description: description,
                     originInfo: originInfo,
                     price: price,
                     isSoldOut: isSoldOut,
                     tags: tags,
                     menuImageURL: menuImageURL,
                     createdAt: formatter.date(from: createdAt) ?? Date(),
                     updatedAt: formatter.date(from: updatedAt) ?? Date()
        )
    }
}
