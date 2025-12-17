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

    // Comment
    case createComment(postId: String, parentId: String?, content: String)
    case editComment(postId: String, commentId: String, content: String)
    case deleteComment(postId: String, commentId: String)
}

extension PostRouter: Router {
    var method: HTTPMethod {
        switch self {
        case .files, .create, .like, .createComment:
            return .post
        case .posts, .search, .detail, .userPosts, .myLikes:
            return .get
        case .edit, .editComment:
            return .put
        case .delete, .deleteComment:
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
        case .createComment(let postId, _, _):
            return base + "/\(postId)/comments"
        case .editComment(let postId, let commentId, _), .deleteComment(let postId, let commentId):
            return base + "/\(postId)/comments/\(commentId)"
        }
    }
    
    var body: RequestBody {
        switch self {
        case .files, .posts, .search, .detail, .delete, .userPosts, .myLikes, .deleteComment:
            return .none
        case .create(let dto):
            return .encodable(dto)
        case .edit(_, let dto):
            return .encodable(dto)
        case .like(_, let like):
            return .plain(["like_status": like])
        case .createComment(_, let parentId, let content):
            if let parentId {
                return .plain([
                    "parent_comment_id": parentId,
                    "content": content
                ])
            } else {
                return .plain(["content": content])
            }
        case .editComment(_, _, let content):
            return .plain(["content": content])
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .files, .create, .detail, .edit, .delete, .like, .createComment, .editComment, .deleteComment:
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
