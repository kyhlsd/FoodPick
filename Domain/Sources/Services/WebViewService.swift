//
//  WebViewService.swift
//  Domain
//
//  Created by 김영훈 on 12/23/25.
//

import Foundation

public protocol WebViewService: Sendable {
    func getAuthenticationInfo(urlPath: String) async throws -> (urlRequest: URLRequest, accessToken: String)
}

public enum WebViewServiceError: Error {
    case invalidURL
}
