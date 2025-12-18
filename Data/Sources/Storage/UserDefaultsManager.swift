//
//  UserDefaultsManager.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Foundation

final class UserDefaultsManager: @unchecked Sendable {
    static let shared = UserDefaultsManager()
    private init() {}

    func clearAll() {
        UserDefaults.standard.dictionaryRepresentation().keys.forEach {
            UserDefaults.standard.removeObject(forKey: $0.description)
        }
    }
}

@propertyWrapper
struct UserDefaultsItem<T>: @unchecked Sendable {
    let key: String
    let type: T.Type

    var wrappedValue: T? {
        get {
            return UserDefaults.standard.object(forKey: key) as? T
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
