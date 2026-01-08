//
//  ChatFileType.swift
//  Core
//
//  Created by 김영훈 on 12/17/25.
//

public enum ChatFileType: Sendable {
    case jpg
    case jpeg
    case png
    case gif
    case pdf

    public var toMediaType: MediaType {
        switch self {
        case .jpg:
            return .jpg
        case .jpeg:
            return .jpeg
        case .png:
            return .png
        case .gif:
            return .gif
        case .pdf:
            return .pdf
        }
    }
}

extension MediaType {
    public var toChatFileType: ChatFileType? {
        switch self {
        case .jpg:
            return .jpg
        case .jpeg:
            return .jpeg
        case .png:
            return .png
        case .gif:
            return .gif
        case .pdf:
            return .pdf
        default:
            return nil
        }
    }
}
