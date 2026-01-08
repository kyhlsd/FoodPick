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
    case mp4

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
        case .mp4:
            return .mp4
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
        case .mp4:
            return .mp4
        case .webp, .mov, .avi, .mkv, .wmv:
            return nil
        }
    }
}
