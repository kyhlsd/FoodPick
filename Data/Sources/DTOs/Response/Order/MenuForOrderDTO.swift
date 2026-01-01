//
//  MenuForOrderDTO.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Domain
import Core

struct MenuForOrderDTO: ResponseDTO {
    private let menu: MenuDetailForOrderDTO
    private let quantity: Int

    enum CodingKeys: CodingKey {
        case menu
        case quantity
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.menu = try container.decode(MenuDetailForOrderDTO.self, forKey: .menu)
        self.quantity = try container.decode(Int.self, forKey: .quantity)
    }
}

extension MenuForOrderDTO {
    var toDomain: MenuForOrder {
        return .init(menu: menu.toDomain, quantity: quantity)
    }
}

struct MenuDetailForOrderDTO: ResponseDTO {
    private let id: String
    private let category: String
    private let name: String
    private let description: String
    private let originInformation: String
    private let price: Int
    private let tags: [String]
    private let menuImageURL: String?
    private let createdAt: String
    private let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case category
        case name
        case description
        case originInformation = "origin_information"
        case price
        case tags
        case menuImageURL = "menu_image_url"
        case createdAt
        case updatedAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.category = try container.decode(String.self, forKey: .category)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.originInformation = try container.decode(String.self, forKey: .originInformation)
        self.price = try container.decode(Int.self, forKey: .price)
        self.tags = try container.decode([String].self, forKey: .tags)
        self.menuImageURL = try container.decodeIfPresent(String.self, forKey: .menuImageURL)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
}

extension MenuDetailForOrderDTO {
    var toDomain: MenuDetailForOrder {
        let formatter = Core.DateFormatterProvider.iso8601
        return .init(id: id,
                     category: category,
                     name: name,
                     description: description,
                     originInformation: originInformation,
                     price: price,
                     tags: tags,
                     menuImageURL: menuImageURL,
                     createdAt: formatter.date(from: createdAt) ?? Date(),
                     updatedAt: formatter.date(from: updatedAt) ?? Date()
        )
    }
}
