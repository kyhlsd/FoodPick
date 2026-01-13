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
}

extension LocationRouter: Router {
    var baseURL: String {
        return APIInfos.locationURL
    }
    
    var version: String {
        return "v2"
    }
    
    var headers: HTTPHeaders {
        return ["Authorization": APIInfos.locationKey]
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/local/geo/coord2regioncode"
    }
    
    var body: RequestBody {
        return .none
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .address(let geolocation):
            return [
                .init(name: "x", value: "\(geolocation.longitude)"),
                .init(name: "y", value: "\(geolocation.latitude)")
            ]
        }
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        return nil
    }
}
