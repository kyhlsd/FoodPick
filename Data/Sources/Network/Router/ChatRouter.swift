//
//  ChatRouter.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Alamofire
import Core

enum ChatRouter {
    case chatRoom(id: String)
    case chatRoomList
    case chat(id: String, content: String, files: [String]?)
    case chatList(id: String, time: Date?)
    case files(id: String, files: [(Data, MediaType)])
}

extension ChatRouter: Router {
    var method: HTTPMethod {
        switch self {
        case .chatRoom, .chat, .files:
            return .post
        case .chatRoomList, .chatList:
            return .get
        }
    }
    
    var path: String {
        let base = "/chats"
        switch self {
        case .chatRoom, .chatRoomList:
            return base
        case .chat(let id, _, _), .chatList(let id, _):
            return base + "/\(id)"
        case .files(let id, _):
            return base + "/\(id)/files"
        }
    }
    
    var body: RequestBody {
        switch self {
        case .chatRoom(let id):
            return .plain(["opponent_id": id])
        case .chatRoomList, .chatList, .files:
            return .none
        case .chat(_, let content, let files):
            if let files {
                return .plain([
                    "content": content,
                    "files": files
                ])
            } else {
                return .plain([
                    "content": content
                ])
            }
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .chatList(_, let time):
            if let time {
                let formatter = Core.DateFormatterProvider.iso8601
                return [.init(name: "next", value: formatter.string(from: time))]
            } else {
                return []
            }
        default:
            return []
        }
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        switch self {
        case .files(_, let files):
            return { form in
                for (file, mediaType) in files {
                    let fileName = "\(UUID().uuidString).\(mediaType.fileExtension)"
                    form.append(file, withName: "files", fileName: fileName, mimeType: mediaType.mimeType)
                }
            }
        default:
            return nil
        }
    }
    
}
