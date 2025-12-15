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
    case updateDeviceToken
    case getMyProfile
    case updateMyProfile(dto: ProfileRequestDTO)
    case uploadProfileImage(image: Data)
    case search(nickname: String)
}

extension UserRouter: Router {
    var method: HTTPMethod {
        switch self {
        case .validate, .join, .emailLogin, .kakaoLogin, .appleLogin, .logout, .uploadProfileImage:
            return .post
        case .updateDeviceToken, .updateMyProfile:
            return .put
        case .getMyProfile, .search:
            return .get
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
        case .updateDeviceToken:
            return base + "/deviceToken"
        case .getMyProfile:
            return base + "/me/profile"
        case .updateMyProfile:
            return base + "/me/profile"
        case .uploadProfileImage:
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
        case .updateDeviceToken:
            return .plain(["deviceToken": deviceToken])
        case .getMyProfile:
            return .none
        case .updateMyProfile(let dto):
            return .encodable(dto)
        case .uploadProfileImage:
            return .none
        case .search(let nickname):
            return .plain(["nick": nickname])
        }
    }
    
    var queryItems: [URLQueryItem] {
        return []
    }
    
    var headers: Alamofire.HTTPHeaders {
        switch self {
        case .validate, .join, .emailLogin, .kakaoLogin, .appleLogin:
            return HTTPHeader.asHTTPHeaders([.apiKey])
        case .logout, .updateDeviceToken, .getMyProfile, .updateMyProfile, .uploadProfileImage, .search:
            return HTTPHeader.asHTTPHeaders(HTTPHeader.basic)
        }
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        switch self {
        case .uploadProfileImage(let image):
            return { form in
                form.append(image, withName: "profile", mimeType: "image/jpeg")
            }
        default:
            return nil
        }
    }

    var responseType: (Decodable & Sendable).Type? {
        switch self {
        case .validate, .logout, .updateDeviceToken:
            return nil
        case .join, .emailLogin, .kakaoLogin, .appleLogin:
            return LoginResponseDTO.self
        case .getMyProfile, .updateMyProfile:
            return MyProfileDTO.self
        case .uploadProfileImage:
            return UploadProfileImageResponseDTO.self
        case .search:
            return SearchUserResponseDTO.self
        }
    }
}
