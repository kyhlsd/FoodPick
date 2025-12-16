//
//  NetworkManager.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Foundation
import Alamofire

final class NetworkManager: @unchecked Sendable {
    static let shared = NetworkManager()
    private init() {}

    // Void Response
    func request(
        _ router: Router,
        onProgress: (@Sendable (Double) -> Void)? = nil,
        onCancel: (@Sendable (() -> Void) -> Void)? = nil
    ) async throws {
        if router.multipartFormData != nil {
            try await performUpload(
                router,
                onProgress: onProgress,
                onCancel: onCancel
            )
        } else {
            try await performRequest(
                router,
                onCancel: onCancel
            )
        }
    }

    // Generic Response
    @discardableResult
    func request<T: Decodable & Sendable>(
        _ router: Router,
        responseType: T.Type,
        onProgress: (@Sendable (Double) -> Void)? = nil,
        onCancel: (@Sendable (() -> Void) -> Void)? = nil
    ) async throws -> T? {
        if router.multipartFormData != nil {
            return try await performUpload(
                router,
                responseType: responseType,
                onProgress: onProgress,
                onCancel: onCancel
            )
        } else {
            return try await performRequest(
                router,
                responseType: responseType,
                onCancel: onCancel
            )
        }
    }

    // MARK: - Private Methods
    private func performRequest<T: Decodable & Sendable>(
        _ router: Router,
        responseType: T.Type,
        onCancel: (@Sendable (() -> Void) -> Void)?
    ) async throws -> T {
        var dataRequest: DataRequest?

        return try await withCheckedThrowingContinuation { continuation in
            dataRequest = AF.request(router)
                .validate()
                .responseDecodable(of: T.self) { [weak self] response in
                    guard let self else {
                        continuation.resume(throwing: APIError.unknown)
                        return
                    }
                    switch response.result {
                    case .success(let data):
                        continuation.resume(returning: data)
                    case .failure(let error):
                        print(error)
                        let error = self.handleError(response: response.response, data: response.data)
                        continuation.resume(throwing: error)
                    }
                }

            if let onCancel {
                onCancel {
                    dataRequest?.cancel()
                }
            }
        }
    }

    private func performUpload<T: Decodable & Sendable>(
        _ router: Router,
        responseType: T.Type,
        onProgress: (@Sendable (Double) -> Void)?,
        onCancel: (@Sendable (() -> Void) -> Void)?
    ) async throws -> T {
        guard let multipartFormData = router.multipartFormData else {
            throw APIError.unknown
        }

        var uploadRequest: UploadRequest?

        return try await withCheckedThrowingContinuation { continuation in
            uploadRequest = AF.upload(
                multipartFormData: multipartFormData,
                with: router
            )

            if let onProgress {
                uploadRequest = uploadRequest?.uploadProgress { progress in
                    onProgress(progress.fractionCompleted)
                }
            }

            uploadRequest?
                .validate()
                .responseDecodable(of: T.self) { [weak self] response in
                    guard let self else {
                        continuation.resume(throwing: APIError.unknown)
                        return
                    }
                    switch response.result {
                    case .success(let data):
                        continuation.resume(returning: data)
                    case .failure:
                        let error = self.handleError(response: response.response, data: response.data)
                        continuation.resume(throwing: error)
                    }
                }

            if let onCancel {
                onCancel {
                    uploadRequest?.cancel()
                }
            }
        }
    }

    private func performRequest(
        _ router: Router,
        onCancel: (@Sendable (() -> Void) -> Void)?
    ) async throws {
        var dataRequest: DataRequest?

        return try await withCheckedThrowingContinuation { continuation in
            dataRequest = AF.request(router)
                .validate()
                .response { [weak self] response in
                    guard let self else {
                        continuation.resume(throwing: APIError.unknown)
                        return
                    }
                    if response.error != nil {
                        let error = self.handleError(response: response.response, data: response.data)
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }

            if let onCancel {
                onCancel {
                    dataRequest?.cancel()
                }
            }
        }
    }

    private func performUpload(
        _ router: Router,
        onProgress: (@Sendable (Double) -> Void)?,
        onCancel: (@Sendable (() -> Void) -> Void)?
    ) async throws {
        guard let multipartFormData = router.multipartFormData else {
            throw APIError.unknown
        }

        var uploadRequest: UploadRequest?

        return try await withCheckedThrowingContinuation { continuation in
            uploadRequest = AF.upload(
                multipartFormData: multipartFormData,
                with: router
            )

            if let onProgress {
                uploadRequest = uploadRequest?.uploadProgress { progress in
                    onProgress(progress.fractionCompleted)
                }
            }

            uploadRequest?
                .validate()
                .response { [weak self] response in
                    guard let self else {
                        continuation.resume(throwing: APIError.unknown)
                        return
                    }
                    if response.error != nil {
                        let error = self.handleError(response: response.response, data: response.data)
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }

            if let onCancel {
                onCancel {
                    uploadRequest?.cancel()
                }
            }
        }
    }

    // MARK: - Error Handling
    private func handleError(response: HTTPURLResponse?, data: Data?) -> Error {
        if let data,
           let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
            return APIError.some(message: errorResponse.message)
        }

        return APIError.network
    }
}
