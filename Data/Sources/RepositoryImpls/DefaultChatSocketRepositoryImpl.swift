//
//  DefaultChatSocketRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 1/8/26.
//

import Foundation
import Domain
import SocketIO

public final class DefaultChatSocketRepositoryImpl: ChatSocketRepository, @unchecked Sendable {
    private var manager: SocketManager?
    private var socket: SocketIOClient?

    private let messageContinuation: AsyncStream<Chat>.Continuation
    private let messageStream: AsyncStream<Chat>

    private let statusContinuation: AsyncStream<ConnectionStatus>.Continuation
    private let statusStream: AsyncStream<ConnectionStatus>

    private let errorContinuation: AsyncStream<ChatSocketError>.Continuation
    private let errorStream: AsyncStream<ChatSocketError>

    public init() {
        // 메시지 스트림 생성
        (self.messageStream, self.messageContinuation) = AsyncStream<Chat>.makeStream()

        // 연결 상태 스트림 생성
        (self.statusStream, self.statusContinuation) = AsyncStream<ConnectionStatus>.makeStream()

        // 에러 스트림 생성
        (self.errorStream, self.errorContinuation) = AsyncStream<ChatSocketError>.makeStream()
    }

    private func setupSocketHandlers() {
        guard let socket = socket else { return }

        // 연결 이벤트
        socket.on(clientEvent: .connect) { [weak self] _, _ in
            self?.statusContinuation.yield(.connected)
        }

        // 연결 해제 이벤트
        socket.on(clientEvent: .disconnect) { [weak self] data, _ in
            self?.statusContinuation.yield(.disconnected)
            if let message = data.first as? String, !message.isEmpty {
                self?.errorContinuation.yield(.socketError(message: message))
            }
        }

        // 재연결 시도 이벤트
        socket.on(clientEvent: .reconnectAttempt) { [weak self] _, _ in
            self?.statusContinuation.yield(.reconnecting)
        }

        // 소켓 오류 이벤트
        socket.on(clientEvent: .error) { [weak self] data, _ in
            let message: String
            if let str = data.first as? String {
                message = str
            } else if let dict = data.first as? [String: Any],
                      let messageFromDict = dict["message"] as? String {
                message = messageFromDict
            } else {
                message = ""
            }
            self?.errorContinuation.yield(.socketError(message: message))
        }

        // 새 메시지 수신 이벤트
        socket.on("new_message") { [weak self] data, _ in
            guard let self = self,
                  let jsonData = data.first as? [String: Any] else {
                return
            }

            do {
                let json = try JSONSerialization.data(withJSONObject: jsonData)
                let chatDTO = try JSONDecoder().decode(ChatDTO.self, from: json)
                self.messageContinuation.yield(chatDTO.toDomain)
            } catch {
                self.errorContinuation.yield(.decodingFailed(underlying: error.localizedDescription))
            }
        }
    }

    public func connect(roomId: String) async throws {
        // 기존 연결이 있다면 먼저 해제
        await disconnect()

        statusContinuation.yield(.connecting)

        let socketURL = URL(string: "\(APIInfos.baseURL)/chats-\(roomId)")
        guard let socketURL else {
            throw ChatSocketError.badURL
        }

        // Socket.IO 매니저 설정
        self.manager = SocketManager(
            socketURL: socketURL,
            config: [
                .log(false),
                .compress,
                .forceWebsockets(true)
            ]
        )
        self.socket = manager?.defaultSocket

        setupSocketHandlers()
        socket?.connect()

        // 연결 대기 (최대 10초)
        do {
            try await withTimeout(seconds: 10) { [weak self] in
                guard let self else { return }
                for await status in self.statusStream where status == .connected {
                    return
                }
            }
        } catch {
            // 타임아웃 또는 기타 오류를 에러 스트림으로 전달
            errorContinuation.yield(.timeout)
            throw error
        }
    }

    public func disconnect() async {
        socket?.disconnect()
        socket = nil
        manager = nil
    }

    public func receiveMessages() -> AsyncStream<Chat> {
        return messageStream
    }

    public func connectionStatus() -> AsyncStream<ConnectionStatus> {
        return statusStream
    }

    public func errors() -> AsyncStream<ChatSocketError> {
        return errorStream
    }

    deinit {
        messageContinuation.finish()
        statusContinuation.finish()
        errorContinuation.finish()
        socket?.disconnect()
    }
}

// MARK: - Timeout Helper
private func withTimeout<R: Sendable>(
    seconds: TimeInterval,
    operation: @Sendable @escaping () async throws -> R
) async throws -> R {
    try await withThrowingTaskGroup(of: R.self) { group in
        group.addTask {
            try await operation()
        }

        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw TimeoutError()
        }

        guard let result = try await group.next() else {
            group.cancelAll()
            throw CancellationError()
        }
        group.cancelAll()
        return result
    }
}

private struct TimeoutError: Error, Sendable {}
