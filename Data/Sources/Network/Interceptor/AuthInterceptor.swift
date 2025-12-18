//
//  AuthInterceptor.swift
//  Data
//
//  Created by 김영훈 on 12/19/25.
//

import Foundation
import Alamofire
import Domain

final class AuthInterceptor: RequestInterceptor {
    private let tokenRepository: TokenRepository

    init(tokenRepository: TokenRepository) {
        self.tokenRepository = tokenRepository
    }

    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping @Sendable (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest

        Task {
            do {
                if urlRequest.url?.path.contains("/auth/refresh") == true {
                    let refreshToken = try await tokenRepository.getRefreshToken()
                    urlRequest.setValue(refreshToken, forHTTPHeaderField: "RefreshToken")
                } else if urlRequest.url?.path.contains("/validation/email") == false
                            && urlRequest.url?.path.contains("/join") == false
                            && urlRequest.url?.path.contains("/login") == false {
                    let accessToken = try await tokenRepository.getAccessToken()
                    urlRequest.setValue(accessToken, forHTTPHeaderField: "Authorization")
                }
                completion(.success(urlRequest))
            } catch {
                completion(.success(urlRequest))
            }
        }
    }
}
