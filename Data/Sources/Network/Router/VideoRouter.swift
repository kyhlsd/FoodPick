//
//  VideoRouter.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Alamofire

enum VideoRouter {
    case videoList(dto: VideoPageRequestDTO)
    case stream(id: String)
    case like(id: String, like: Bool)
}

extension VideoRouter: Router {
    var method: HTTPMethod {
        switch self {
        case .videoList, .stream:
            return .get
        case .like:
            return .post
        }
    }
    
    var path: String {
        let base = "/videos"
        switch self {
        case .videoList:
            return base
        case .stream(let id):
            return base + "/\(id)/stream"
        case .like(let id, _):
            return base + "/\(id)/like"
        }
    }
    
    var body: RequestBody {
        switch self {
        case .videoList, .stream:
            return .none
        case .like(_, let like):
            return .plain(["like_status": like])
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .videoList(let dto):
            return dto.toQueryItems
        default:
            return []
        }
    }
    
    var multipartFormData: ((Alamofire.MultipartFormData) -> Void)? {
        return nil
    }
    
}
