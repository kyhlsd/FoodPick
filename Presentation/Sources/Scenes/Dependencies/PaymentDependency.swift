//
//  PaymentDependency.swift
//  Presentation
//
//  Created by 김영훈 on 12/19/25.
//

import Domain
import Data
import ComposableArchitecture

extension DependencyValues {

    // MARK: - Repository
    var paymentRepository: PaymentRepository {
        get { self[PaymentRepositoryKey.self] }
        set { self[PaymentRepositoryKey.self] = newValue }
    }

    // MARK: - UseCases
    var validatePayment: ValidatePaymentUseCase {
        get { self[ValidatePaymentKey.self] }
        set { self[ValidatePaymentKey.self] = newValue }
    }

    var fetchReceipt: FetchReceiptUseCase {
        get { self[FetchReceiptKey.self] }
        set { self[FetchReceiptKey.self] = newValue }
    }
}

// MARK: - Keys
private enum PaymentRepositoryKey: DependencyKey {
    static let liveValue: PaymentRepository = DefaultPaymentRepositoryImpl()
}

private enum ValidatePaymentKey: DependencyKey {
    static let liveValue: ValidatePaymentUseCase = {
        @Dependency(\.paymentRepository) var paymentRepository
        return ValidatePaymentUseCaseImpl(paymentRepository: paymentRepository)
    }()
}

private enum FetchReceiptKey: DependencyKey {
    static let liveValue: FetchReceiptUseCase = {
        @Dependency(\.paymentRepository) var paymentRepository
        return FetchReceiptUseCaseImpl(paymentRepository: paymentRepository)
    }()
}
