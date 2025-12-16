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
    case storeInfo(id: String)
    case toggleStoreLike(id: String)
    case search(name: String)
    case popularStores(category: String? = nil)
    case popularSearches
    case myLikes(dto: BasicRequestDTO)
    case reviews(id: String, dto: BasicRequestDTO)
}

extension StoreRouter: Router {
    var method: HTTPMethod {
        switch self {
        case .stores, .storeInfo, .search, .popularStores, .popularSearches, .myLikes, .reviews:
            return .get
        case .toggleStoreLike:
            return .post
        }
    }
    
    var path: String {
        let base = "/stores"
        switch self {
        case .stores:
            return base
        case .storeInfo(let id):
            return base + "/\(id)"
        case .toggleStoreLike(let id):
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
        return .none
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .stores(let dto):
            return dto.toQueryItems
        case .storeInfo, .toggleStoreLike, .popularSearches:
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
    
    var headers: HTTPHeaders {
        return HTTPHeader.asHTTPHeaders(HTTPHeader.basic)
    }
    
    var multipartFormData: ((Alamofire.MultipartFormData) -> Void)? {
        return nil
    }
}
