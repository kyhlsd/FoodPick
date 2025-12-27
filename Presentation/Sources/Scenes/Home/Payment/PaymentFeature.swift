//
//  PaymentFeature.swift
//  Presentation
//
//  Created by 김영훈 on 12/28/25.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct PaymentFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        let paymentRequest: PaymentRequest
        var isProcessing = false
        var paymentResponse: PaymentResponse?

        @Presents var alert: AlertState<PaymentFeature.Alert>?
    }

    // MARK: - Action
    enum Action: Sendable {
        case paymentCompleted(PaymentResponse)
        case validatePayment(impUID: String)
        case paymentValidated(ValidatePaymentResponse)
        case paymentValidationFailed(Error)
        case paymentSuccessConfirmed
        case alert(PresentationAction<PaymentFeature.Alert>)
    }

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .paymentCompleted(response):
                state.paymentResponse = response

                if response.isSuccess, let impUID = response.impUID {
                    // 결제 성공 - 서버에 검증 요청
                    return .send(.validatePayment(impUID: impUID))
                } else {
                    // 결제 실패
                    state.alert = AlertState {
                        TextState("결제 실패")
                    } actions: {
                        ButtonState(role: .cancel) {
                            TextState("확인")
                        }
                    } message: {
                        TextState(response.errorMessage ?? "결제에 실패했습니다")
                    }
                    return .none
                }

            case let .validatePayment(impUID):
                state.isProcessing = true
                return .run { send in
                    do {
                        let validationResponse = try await validatePaymentUseCase.execute(impUid: impUID)
                        await send(.paymentValidated(validationResponse))
                    } catch {
                        await send(.paymentValidationFailed(error))
                    }
                }

            case .paymentValidated:
                state.isProcessing = false
                // 결제 검증 성공
                state.alert = AlertState {
                    TextState("결제 완료")
                } actions: {
                    ButtonState(action: .paymentSuccessConfirmed) {
                        TextState("확인")
                    }
                } message: {
                    TextState("결제가 성공적으로 완료되었습니다")
                }
                return .none

            case let .paymentValidationFailed(error):
                state.isProcessing = false
                state.alert = AlertState {
                    TextState("결제 검증 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case .paymentSuccessConfirmed:
                return .run { _ in
                    await dismiss()
                }

            case .alert(.presented(.paymentSuccessConfirmed)):
                return .send(.paymentSuccessConfirmed)

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    // MARK: - Dependencies
    @Dependency(\.validatePayment) var validatePaymentUseCase
    @Dependency(\.dismiss) var dismiss

    enum Alert: Sendable {
        case paymentSuccessConfirmed
    }
}
