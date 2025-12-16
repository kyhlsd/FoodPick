//
//  ResponseDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

protocol ResponseDTO: Decodable, Sendable {
    associatedtype Entity
    var toDomain: Entity { get }
}
