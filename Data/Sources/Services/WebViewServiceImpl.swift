//
//  WebViewServiceImpl.swift
//  Data
//
//  Created by 김영훈 on 12/23/25.
//

import Foundation
import Domain

public final class WebViewServiceImpl: WebViewService {
    private let tokenRepository: TokenRepository

    public init(tokenRepository: TokenRepository) {
        self.tokenRepository = tokenRepository
    }

    public func getAuthenticationInfo(urlPath: String) async throws -> (urlRequest: URLRequest, accessToken: String) {
        let router = PathRouter.webView(path: urlPath)
        let request = try router.asURLRequest()

        guard let host = request.url?.host,
              let allowedHost = URL(string: APIInfos.baseURL)?.host,
              host == allowedHost else {
            throw WebViewServiceError.untrustedDomain
        }

        let accessToken = try await tokenRepository.getAccessToken()

        return (urlRequest: request, accessToken: accessToken)
    }
}
