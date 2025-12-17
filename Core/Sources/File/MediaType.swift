//
//  MediaType.swift
//  Core
//
//  Created by 김영훈 on 12/16/25.
//

public enum MediaType: Sendable {
    case jpg
    case png
    case jpeg
    case gif
    case webp

    case mp4
    case mov
    case avi
    case mkv
    case wmv

    case pdf

    public var mimeType: String {
        switch self {
        case .jpg, .jpeg:
            return "image/jpeg"
        case .png:
            return "image/png"
        case .gif:
            return "image/gif"
        case .webp:
            return "image/webp"
        case .mp4:
            return "video/mp4"
        case .mov:
            return "video/quicktime"
        case .avi:
            return "video/x-msvideo"
        case .mkv:
            return "video/x-matroska"
        case .wmv:
            return "video/x-ms-wmv"
        case .pdf:
            return "application/pdf"
        }
    }

    public var fileExtension: String {
        switch self {
        case .jpg:
            return "jpg"
        case .jpeg:
            return "jpeg"
        case .png:
            return "png"
        case .gif:
            return "gif"
        case .webp:
            return "webp"
        case .mp4:
            return "mp4"
        case .mov:
            return "mov"
        case .avi:
            return "avi"
        case .mkv:
            return "mkv"
        case .wmv:
            return "wmv"
        case .pdf:
            return "pdf"
        }
    }

    public var isImage: Bool {
        switch self {
        case .jpg, .jpeg, .png, .gif, .webp:
            return true
        case .mp4, .mov, .avi, .mkv, .wmv, .pdf:
            return false
        }
    }

    public var isVideo: Bool {
        switch self {
        case .mp4, .mov, .avi, .mkv, .wmv:
            return true
        case .jpg, .jpeg, .png, .gif, .webp, .pdf:
            return false
        }
    }

    public var isPDF: Bool {
        if case .pdf = self {
            return true
        }
        return false
    }
}
