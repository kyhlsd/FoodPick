//
//  Router.swift
//  Data
//
//  Created by 김영훈 on 12/15/25.
//

import Foundation
import Alamofire

enum RequestBody {
    case plain(Parameters)
    case encodable(Encodable)
    case none
}

protocol Router: URLRequestConvertible, URLConvertible {
    var baseURL: String { get }
    var method: HTTPMethod { get }
    var version: String { get }
    var path: String { get }

    var body: RequestBody { get }
    var queryItems: [URLQueryItem] { get }
    var headers: HTTPHeaders { get }

    var multipartFormData: ((MultipartFormData) -> Void)? { get }
}

extension Router {
    var baseURL: String {
        return APIInfos.baseURL
    }
    
    var version: String {
        return "v1"
    }
    
    var headers: HTTPHeaders {
        return ["SeSACKey": APIInfos.key]
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try asURL()
        var urlRequest = try URLRequest(url: url, method: method, headers: headers)

        switch body {
        case .plain(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .encodable(let encodable):
            urlRequest.httpBody = try JSONEncoder().encode(encodable)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        case .none:
            break
        }
        
        return urlRequest
    }
    
    func asURL() throws -> URL {
        var url = try baseURL.asURL()
        url = url.appending(path: "\(version)\(path)")
        url = url.appending(queryItems: queryItems)
        return url
    }
}
