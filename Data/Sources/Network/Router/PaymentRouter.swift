//
//  PaymentRouter.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Alamofire

enum PaymentRouter {
    case validate(id: String)
    case receipt(code: String)
}

extension PaymentRouter: Router {
    var method: HTTPMethod {
        switch self {
        case .validate:
            return .post
        case .receipt:
            return .get
        }
    }
    
    var path: String {
        let base = "/payments"
        switch self {
        case .validate:
            return base + "/validation"
        case .receipt(let code):
            return base + "/\(code)"
        }
    }
    
    var body: RequestBody {
        switch self {
        case .validate(let id):
            return .plain(["imp_uid": id])
        case .receipt:
            return .none
        }
    }
    
    var queryItems: [URLQueryItem] {
        return []
    }
    
    var headers: HTTPHeaders {
        return HTTPHeader.asHTTPHeaders(HTTPHeader.basic)
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        return nil
    }
    
}
