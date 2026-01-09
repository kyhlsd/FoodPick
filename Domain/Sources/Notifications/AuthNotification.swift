//
//  AuthNotification.swift
//  Core
//
//  Created by 김영훈 on 12/19/25.
//

import Foundation

public extension Notification.Name {
    static let shouldNavigateToLogin = Notification.Name("shouldNavigateToLogin")
    static let loginCompleted = Notification.Name("loginCompleted")
    static let deviceTokenError = Notification.Name("DeviceTokenError")
}
