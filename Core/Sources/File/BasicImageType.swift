//
//  BasicImageType.swift
//  Core
//
//  Created by 김영훈 on 12/16/25.
//

public enum BasicImageType: Sendable {
    case jpg
    case jpeg
    case png

    public var toMediaType: MediaType {
        switch self {
        case .jpg:
            return .jpg
        case .jpeg:
            return .jpeg
        case .png:
            return .png
        }
    }
}
