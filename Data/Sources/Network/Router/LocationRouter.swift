//
//  LocationRouter.swift
//  Data
//
//  Created by 김영훈 on 1/13/26.
//

import Foundation
import Alamofire

enum LocationRouter {
    case address(geolocation: GeolocationDTO)
    case direction(dto: DirectionRequestDTO)
}

extension LocationRouter: Router {
    var baseURL: String {
        switch self {
        case .address:
            return APIInfos.locationURL
        case .direction:
            return APIInfos.skURL
        }
    }
    
    var version: String {
        switch self {
        case .address:
            return "v2"
        case .direction:
            return ""
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .address:
            return ["Authorization": APIInfos.locationKey]
        case .direction:
            return ["appKey": APIInfos.skKey]
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .address:
            return .get
        case .direction:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .address:
            return "/local/geo/coord2regioncode"
        case .direction:
            return "/tmap/routes/pedestrian"
        }
    }
    
    var body: RequestBody {
        switch self {
        case .address:
            return .none
        case .direction(let dto):
            return .encodable(dto)
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .address(let geolocation):
            return [
                .init(name: "x", value: "\(geolocation.longitude)"),
                .init(name: "y", value: "\(geolocation.latitude)")
            ]
        case .direction:
            return []
        }
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        return nil
    }
    
    func asURL() throws -> URL {
        var url = try baseURL.asURL()
        if case .address = self {
            url = url.appending(path: "\(version)\(path)")
        } else {
            url = url.appending(path: path)
        }
        url = url.appending(queryItems: queryItems)
        return url
    }
}
