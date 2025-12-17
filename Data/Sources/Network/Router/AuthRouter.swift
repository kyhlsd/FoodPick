//
//  AuthRouter.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Alamofire

enum AuthRouter {
    case refresh
}

extension AuthRouter: Router {
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        let base = "/auth"
        return base + "/refresh"
    }
    
    var body: RequestBody {
        return .none
    }
    
    var queryItems: [URLQueryItem] {
        return []
    }
    
    var headers: HTTPHeaders {
        return HTTPHeader.asHTTPHeaders([.custom(key: "RefreshToken", value: APIInfos.refreshToken)])
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        return nil
    }
        
}
