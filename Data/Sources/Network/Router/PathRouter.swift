//
//  PathRouter.swift
//  Data
//
//  Created by 김영훈 on 12/23/25.
//

import Foundation
import Alamofire

enum PathRouter {
    case file(path: String)
    case webView(path: String)
}

extension PathRouter: Router {
    var method: HTTPMethod {
        return .get
    }
    
    var version: String {
        switch self {
        case .file:
            return "v1"
        case .webView:
            return ""
        }
    }
    
    var path: String {
        switch self {
        case .file(let path), .webView(let path):
            return path
        }
    }
    
    var body: RequestBody {
        return .none
    }
    
    var queryItems: [URLQueryItem] {
        return []
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        return nil
    }
}
