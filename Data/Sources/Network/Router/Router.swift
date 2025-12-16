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
        url = url.appendingPathExtension("/\(version)\(path)")
        url = url.appending(queryItems: queryItems)
        return url
    }
}

enum HTTPHeader {
    case apiKey
    case authorization
    case custom(key: String, value: String)
    
    var tuple: (key: String, value: String) {
        switch self {
        case .apiKey:
            return ("SeSACKey", APIInfos.key)
        case .authorization:
            // TODO: Login 구현 후 토큰 관리
            let token = APIInfos.accessToken
            return ("Authorization", token)
        case .custom(let key, let value):
            return (key, value)
        }
    }
    
    static var basic: [Self] {
        return [.apiKey, .authorization]
    }
    
    static func asHTTPHeaders(_ list: [HTTPHeader]) -> HTTPHeaders {
        var headers: HTTPHeaders = [:]
        list.forEach {
            let tuple = $0.tuple
            headers.add(name: tuple.key, value: tuple.value)
        }
        return headers
    }
}
