//
//  OrderRouter.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Alamofire

enum OrderRouter {
    case order(dto: OrderRequestDTO)
    case fetch
    case edit(code: String, status: OrderStatusDTO)
}

extension OrderRouter: Router {
    var method: HTTPMethod {
        switch self {
        case .order:
            return .post
        case .fetch:
            return .get
        case .edit:
            return .put
        }
    }
    
    var path: String {
        let base = "/orders"
        switch self {
        case .order, .fetch:
            return base
        case .edit(let code, _):
            return base + "/\(code)"
        }
    }
    
    var body: RequestBody {
        switch self {
        case .order(let dto):
            return .encodable(dto)
        case .fetch:
            return .none
        case .edit(_, let status):
            return .plain(["nextStatus": status.rawValue])
        }
    }
    
    var queryItems: [URLQueryItem] {
        return []
    }
    
    var headers: HTTPHeaders {
        return HTTPHeader.asHTTPHeaders(HTTPHeader.basic)
    }
    
    var multipartFormData: ((Alamofire.MultipartFormData) -> Void)? {
        return nil
    }
    
}
