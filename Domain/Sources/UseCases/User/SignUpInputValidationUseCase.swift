//
//  SignUpInputValidationUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/18/25.
//

import Foundation

public protocol SignUpInputValidationUseCase: Sendable {
    func validateEmail(email: String) -> Result<Void, SignUpInputValidationError>
    func validatePassword(password: String) -> Result<Void, SignUpInputValidationError>
    func confirmPassword(password: String, confirm: String) -> Result<Void, SignUpInputValidationError>
    func validateNickname(nickname: String) -> Result<Void, SignUpInputValidationError>
}

public final class SignUpInputValidationUseCaseImpl: SignUpInputValidationUseCase {

    public init() {}

    public func validateEmail(email: String) -> Result<Void, SignUpInputValidationError> {
        let regex = /^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
        if email.wholeMatch(of: regex) != nil {
            return .success(())
        } else {
            return .failure(.invalidEmail)
        }
    }
    
    public func validatePassword(password: String) -> Result<Void, SignUpInputValidationError> {
        let regex = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/
        if password.wholeMatch(of: regex) != nil {
            return .success(())
        } else {
            return .failure(.invalidPassword)
        }
    }
    
    public func confirmPassword(password: String, confirm: String) -> Result<Void, SignUpInputValidationError> {
        if password == confirm {
            return .success(())
        } else {
            return .failure(.inconsistent)
        }
    }

    public func validateNickname(nickname: String) -> Result<Void, SignUpInputValidationError> {
        if nickname.count > 12 {
            return .failure(.nicknameTooLong)
        }

        let invalidCharacters = CharacterSet(charactersIn: "-.,?*@+^${}()|[]\\")
        if nickname.rangeOfCharacter(from: invalidCharacters) != nil {
            return .failure(.invalidNickname)
        }

        return .success(())
    }
}

public enum SignUpInputValidationError: LocalizedError {
    case invalidEmail
    case invalidPassword
    case inconsistent
    case invalidNickname
    case nicknameTooLong

    public var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "올바른 이메일 형식이 아닙니다."
        case .invalidPassword:
            return "비밀번호는 8자 이상으로 영문자, 특수문자, 숫자를 포함해야 합니다."
        case .inconsistent:
            return "비밀번호가 일치하지 않습니다."
        case .invalidNickname:
            return "닉네임에는 특수문자를 사용할 수 없습니다."
        case .nicknameTooLong:
            return "닉네임은 12자 이하만 가능합니다."
        }
    }
}
