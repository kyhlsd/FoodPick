//
//  PostRouter.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Foundation
import Alamofire
import Core

enum PostRouter {
    case files(datas: [(Data, MediaType)])
    case create(dto: CreatePostRequestDTO)
    case posts(dto: ByLocationRequestDTO)
    case search(title: String)
    case detail(id: String)
    case edit(id: String, dto: EditPostRequestDTO)
    case delete(id: String)
    case like(id: String, like: Bool)
    case userPosts(id: String, dto: BasicRequestDTO)
    case myLikes(dto: BasicRequestDTO)
}

extension PostRouter: Router {
    var method: HTTPMethod {
        switch self {
        case .files, .create, .like:
            return .post
        case .posts, .search, .detail, .userPosts, .myLikes:
            return .get
        case .edit:
            return .put
        case .delete:
            return .delete
        }
    }
    
    var path: String {
        let base = "/posts"
        switch self {
        case .files:
            return base + "/files"
        case .create:
            return base
        case .posts:
            return base + "/geolocation"
        case .search:
            return base + "/search"
        case .detail(let id), .edit(let id, _), .delete(let id):
            return base + "/\(id)"
        case .like(let id, _):
            return base + "/\(id)/like"
        case .userPosts(let id, _):
            return base + "/users/\(id)"
        case .myLikes:
            return base + "/likes/me"
        }
    }
    
    var body: RequestBody {
        switch self {
        case .files, .posts, .search, .detail, .delete, .userPosts, .myLikes:
            return .none
        case .create(let dto):
            return .encodable(dto)
        case .edit(_, let dto):
            return .encodable(dto)
        case .like(_, let like):
            return .plain(["like_status": like])
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .files, .create, .detail, .edit, .delete, .like:
            return []
        case .posts(let dto):
            return dto.toQueryItems
        case .search(let title):
            return [.init(name: "title", value: title)]
        case .userPosts(_, let dto), .myLikes(let dto):
            return dto.toQueryItems
        }
    }
    
    var headers: HTTPHeaders {
        return HTTPHeader.asHTTPHeaders(HTTPHeader.basic)
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        switch self {
        case .files(let datas):
            return { form in
                for (data, mediaType) in datas {
                    let fileName = "\(UUID().uuidString).\(mediaType.fileExtension)"
                    form.append(data, withName: "files", fileName: fileName, mimeType: mediaType.mimeType)
                }
            }
        default:
            return nil
        }
    }
    
}
