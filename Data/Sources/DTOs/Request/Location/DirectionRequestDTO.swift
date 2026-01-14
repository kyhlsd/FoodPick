//
//  DirectionRequestDTO.swift
//  Data
//
//  Created by 김영훈 on 1/14/26.
//

import Foundation
import Domain

struct DirectionRequestDTO: Encodable {
    private let startX: Double
    private let startY: Double
    private let endX: Double
    private let endY: Double
    private let startName: String
    private let endName: String
}

extension DirectionRequestDTO {
    init(from domain: DirectionRequest) {
        startX = domain.startX
        startY = domain.startY
        endX = domain.endX
        endY = domain.endY
        startName = domain.startName.toURLEncoded() ?? "error"
        endName = domain.endName.toURLEncoded() ?? "error"
    }
}

private extension String {
    func toURLEncoded() -> String? {
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: ":#[]@!$&'()*+,;=")
        
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
    }
}
