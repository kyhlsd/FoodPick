//
//  OrderRequestDTO.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Domain

struct OrderRequestDTO: Encodable {
    private let storeId: String
    private let orderMenuList: [MenuRequestDTO]
    private let totalPrice: Int
    
    enum CodingKeys: String, CodingKey {
        case storeId = "store_id"
        case orderMenuList = "order_menu_list"
        case totalPrice = "total_price"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.storeId, forKey: .storeId)
        try container.encode(self.orderMenuList, forKey: .orderMenuList)
        try container.encode(self.totalPrice, forKey: .totalPrice)
    }
}

extension OrderRequestDTO {
    init(from domain: OrderRequest) {
        self.init(
            storeId: domain.storeId,
            orderMenuList: domain.orderMenuList.map {
                .init(from: .init(menuId: $0.menuId, quantity: $0.quantity))
            },
            totalPrice: domain.totalPrice
        )
    }
}

struct MenuRequestDTO: Encodable {
    private let menuId: String
    private let quantity: Int
    
    enum CodingKeys: String, CodingKey {
        case menuId = "menu_id"
        case quantity
    }
}

extension MenuRequestDTO {
    init(from domain: MenuRequest) {
        self.init(menuId: domain.menuId, quantity: domain.quantity)
    }
}
