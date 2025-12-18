//
//  StoreRouter.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Foundation
import Alamofire

enum StoreRouter {
    case stores(dto: ByLocationRequestDTO)
    case detail(id: String)
    case like(id: String, like: Bool)
    case search(name: String)
    case popularStores(category: String? = nil)
    case popularSearches
    case myLikes(dto: BasicRequestDTO)
    case reviews(id: String, dto: BasicRequestDTO)
}

extension StoreRouter: Router {
    var method: HTTPMethod {
        switch self {
        case .stores, .detail, .search, .popularStores, .popularSearches, .myLikes, .reviews:
            return .get
        case .like:
            return .post
        }
    }
    
    var path: String {
        let base = "/stores"
        switch self {
        case .stores:
            return base
        case .detail(let id):
            return base + "/\(id)"
        case .like(let id, _):
            return base + "/\(id)/like"
        case .search:
            return base + "/search"
        case .popularStores:
            return base + "/popular-stores"
        case .popularSearches:
            return base + "/searches-popular"
        case .myLikes:
            return base + "/likes/me"
        case .reviews(let id, _):
            return base + "/reviews/users/\(id)"
        }
    }
    
    var body: RequestBody {
        switch self {
        case .like(_, let like):
            return .plain(["like_status": like])
        default:
            return .none
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .stores(let dto):
            return dto.toQueryItems
        case .detail, .like, .popularSearches:
            return []
        case .search(let name):
            return [.init(name: "name", value: name)]
        case .popularStores(let category):
            var items = [URLQueryItem]()
            if let category {
                items.append(.init(name: "category", value: category))
            }
            return items
        case .myLikes(let dto), .reviews(_, let dto):
            return dto.toQueryItems
        }
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        return nil
    }
}
