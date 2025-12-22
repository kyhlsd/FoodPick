//
//  AuthInterceptor.swift
//  Data
//
//  Created by 김영훈 on 12/19/25.
//

import Foundation
import Alamofire
import Domain

// MARK: - RefreshCoordinator Actor
private actor RefreshCoordinator {
    private var isRefreshing = false
    private var requestsToRetry: [(RetryResult) -> Void] = []

    func startRefresh(completion: @escaping (RetryResult) -> Void) -> Bool {
        requestsToRetry.append(completion)
        if isRefreshing {
            return false
        }
        isRefreshing = true
        return true
    }

    func completeRefresh(with result: RetryResult) {
        let retries = requestsToRetry
        requestsToRetry.removeAll()
        isRefreshing = false
        retries.forEach { $0(result) }
    }
}

final class AuthInterceptor: RequestInterceptor {
    private let tokenRepository: TokenRepository
    private let refreshCoordinator = RefreshCoordinator()

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

    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping @Sendable (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetryWithError(error))
            return
        }

        switch response.statusCode {
        case 419:
            // Access Token 만료 - 토큰 갱신 후 재시도
            Task {
                let shouldRefresh = await refreshCoordinator.startRefresh(completion: completion)

                if shouldRefresh {
                    do {
                        try await tokenRepository.refreshTokens()
                        // 토큰 갱신 성공 - 대기 중인 모든 요청 재시도
                        await refreshCoordinator.completeRefresh(with: .retry)
                    } catch {
                        // 토큰 갱신 실패 - 대기 중인 모든 요청 실패 처리
                        await refreshCoordinator.completeRefresh(with: .doNotRetryWithError(error))

                        // 갱신 실패 시 로그인 화면으로 이동
                        await MainActor.run {
                            NotificationCenter.default.post(name: .shouldNavigateToLogin, object: nil)
                        }
                    }
                }
            }

        case 418, 401:
            // 418: Refresh Token 만료
            // 401: 인증할 수 없는 토큰
            // 로그인 화면으로 이동
            Task { @MainActor in
                NotificationCenter.default.post(name: .shouldNavigateToLogin, object: nil)
            }
            completion(.doNotRetryWithError(error))

        default:
            completion(.doNotRetryWithError(error))
        }
    }
}
