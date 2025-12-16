//
//  UserRouter.swift
//  Data
//
//  Created by 김영훈 on 12/15/25.
//

import Foundation
import Alamofire

enum UserRouter {
    case validate(email: String)
    case join(dto: JoinRequestDTO)
    case emailLogin(email: String, password: String)
    case kakaoLogin(oauthToken: String)
    case appleLogin(idToken: String)
    case logout
    case deviceToken
    case myProfile(dto: ProfileRequestDTO? = nil)
    case profileImage(image: Data)
    case search(nickname: String)
}

extension UserRouter: Router {
    var method: HTTPMethod {
        switch self {
        case .validate, .join, .emailLogin, .kakaoLogin, .appleLogin, .logout, .profileImage:
            return .post
        case .deviceToken:
            return .put
        case .search:
            return .get
        case .myProfile(let dto):
            return dto == nil ? .get : .put
        }
    }
    
    var path: String {
        let base = "/users"
        switch self {
        case .validate:
            return base + "/validation/email"
        case .join:
            return base + "/join"
        case .emailLogin:
            return base + "/login"
        case .kakaoLogin:
            return base + "/login/kakao"
        case .appleLogin:
            return base + "/login/apple"
        case .logout:
            return base + "/logout"
        case .deviceToken:
            return base + "/deviceToken"
        case .myProfile:
            return base + "/me/profile"
        case .profileImage:
            return base + "/profile/image"
        case .search:
            return base + "/search"
        }
    }
    
    var body: RequestBody {
        let deviceToken = UserDefaultsManager.shared.deviceToken
        switch self {
        case .validate(let email):
            return .plain(["email": email])
        case .join(let dto):
            return .encodable(dto)
        case .emailLogin(let email, let password):
            return .plain([
                "email": email,
                "password": password,
                "deviceToken": deviceToken
            ])
        case .kakaoLogin(let oauthToken):
            return .plain([
                "oauthToken": oauthToken,
                "deviceToken": deviceToken
            ])
        case .appleLogin(let idToken):
            return .plain([
                "idToken": idToken,
                "deviceToken": deviceToken
            ])
        case .logout:
            return .none
        case .deviceToken:
            return .plain(["deviceToken": deviceToken])
        case .myProfile(let dto):
            return dto == nil ? .none : .encodable(dto)
        case .profileImage:
            return .none
        case .search:
            return .none
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .search(let nickname):
            return [URLQueryItem(name: "nick", value: nickname)]
        default:
            return []
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .validate, .join, .emailLogin, .kakaoLogin, .appleLogin:
            return HTTPHeader.asHTTPHeaders([.apiKey])
        case .logout, .deviceToken, .myProfile, .profileImage, .search:
            return HTTPHeader.asHTTPHeaders(HTTPHeader.basic)
        }
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        switch self {
        case .profileImage(let image):
            return { form in
                form.append(image, withName: "profile", fileName: UUID().uuidString, mimeType: "image/jpeg")
            }
        default:
            return nil
        }
    }

}
