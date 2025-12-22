//
//  RestaurantRouter.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Foundation
import Alamofire

enum RestaurantRouter {
    case restaurants(dto: ByLocationRequestDTO)
    case detail(id: String)
    case like(id: String, like: Bool)
    case search(name: String)
    case popularRestaurants(category: String? = nil)
    case popularSearches
    case myLikes(dto: BasicRequestDTO)
    case reviews(id: String, dto: BasicRequestDTO)
}

extension RestaurantRouter: Router {
    var method: HTTPMethod {
        switch self {
        case .restaurants, .detail, .search, .popularRestaurants, .popularSearches, .myLikes, .reviews:
            return .get
        case .like:
            return .post
        }
    }

    var path: String {
        let base = "/stores"
        switch self {
        case .restaurants:
            return base
        case .detail(let id):
            return base + "/\(id)"
        case .like(let id, _):
            return base + "/\(id)/like"
        case .search:
            return base + "/search"
        case .popularRestaurants:
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
        case .restaurants(let dto):
            return dto.toQueryItems
        case .detail, .like, .popularSearches:
            return []
        case .search(let name):
            return [.init(name: "name", value: name)]
        case .popularRestaurants(let category):
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
