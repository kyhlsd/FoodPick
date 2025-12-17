//
//  BannerRouter.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Alamofire

enum BannerRouter {
    case banner
}

extension BannerRouter: Router {
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/banners/main"
    }
    
    var body: RequestBody {
        return .none
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
