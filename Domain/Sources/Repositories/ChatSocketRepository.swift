//
//  ChatSocketRepository.swift
//  Domain
//
//  Created by 김영훈 on 1/8/26.
//

import Foundation

public protocol ChatSocketRepository: Sendable {
    func connect(roomId: String) async throws
    func disconnect() async
    func receiveMessages() -> AsyncStream<Chat>
    func connectionStatus() -> AsyncStream<ConnectionStatus>
    func errors() -> AsyncStream<ChatSocketError>
}

public enum ConnectionStatus: Sendable {
    case connected
    case disconnected
    case connecting
    case reconnecting
}

public enum ChatSocketError: Error, Sendable, Equatable {
    case badURL
    case decodingFailed(underlying: String)
    case socketError(message: String)
    case timeout
    case unknown(message: String?)

    public var message: String {
        switch self {
        case .badURL:
            return "잘못된 주소입니다."
        case .decodingFailed:
            return "잘못된 메세지 형식입니다."
        case .socketError(let message):
            return message.isEmpty ? "소켓 연결 중 오류가 발생했습니다." : message
        case .timeout:
            return "서버 응답이 지연되고 있습니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
