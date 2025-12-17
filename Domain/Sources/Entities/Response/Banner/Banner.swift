//
//  Banner.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public struct Banner {
    public let name: String
    public let imageURL: String
    public let payload: Payload
    
    public init(name: String, imageURL: String, payload: Payload) {
        self.name = name
        self.imageURL = imageURL
        self.payload = payload
    }
}

public struct Payload {
    public let type: PayloadType
    public let value: String
    
    public init(type: PayloadType, value: String) {
        self.type = type
        self.value = value
    }
}

public enum PayloadType {
    case webView
}
