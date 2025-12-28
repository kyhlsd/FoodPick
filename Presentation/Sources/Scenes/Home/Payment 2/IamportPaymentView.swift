//
//  IamportPaymentView.swift
//  Presentation
//
//  Created by 김영훈 on 12/28/25.
//

import SwiftUI
import UIKit
import iamport_ios
import Domain

// MARK: - Iamport Payment View (UIViewControllerRepresentable)
struct IamportPaymentView: UIViewControllerRepresentable {
    let paymentRequest: PaymentRequest
    let onComplete: (PaymentResponse) -> Void

    init(
        paymentRequest: PaymentRequest,
        onComplete: @escaping (PaymentResponse) -> Void
    ) {
        self.paymentRequest = paymentRequest
        self.onComplete = onComplete
    }

    func makeUIViewController(context: Context) -> IamportPaymentViewController {
        let viewController = IamportPaymentViewController(
            paymentRequest: paymentRequest,
            onComplete: onComplete
        )
        return viewController
    }

    func updateUIViewController(_ uiViewController: IamportPaymentViewController, context: Context) {
        // No update needed
    }
}

// MARK: - Iamport Payment ViewController
class IamportPaymentViewController: UIViewController {
    private let paymentRequest: PaymentRequest
    private let onComplete: (PaymentResponse) -> Void
    private var hasStartedPayment = false

    init(
        paymentRequest: PaymentRequest,
        onComplete: @escaping (PaymentResponse) -> Void
    ) {
        self.paymentRequest = paymentRequest
        self.onComplete = onComplete
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        DispatchQueue.main.async { [weak self] in
            guard let self, !self.hasStartedPayment else { return }
            self.hasStartedPayment = true
            self.startPayment()
        }
    }

    private func startPayment() {
        // IamportPayment 객체 생성
        let payment = IamportPayment(
            pg: paymentRequest.pg,
            merchant_uid: paymentRequest.merchantUID,
            amount: String(paymentRequest.amount)
        )
        payment.pay_method = paymentRequest.payMethod
        payment.name = paymentRequest.name
        payment.buyer_name = paymentRequest.buyerName
        payment.app_scheme = "foodpick"

        // navigationController 확보
        guard let navController = self.navigationController else {
            handlePaymentResponse(nil)
            return
        }

        // 결제 시작
        Iamport.shared.payment(
            navController: navController,
            userCode: "imp14511373",
            payment: payment
        ) { [weak self] response in
            self?.handlePaymentResponse(response)
        }
    }

    private func handlePaymentResponse(_ response: IamportResponse?) {
        guard let response else {
            onComplete(PaymentResponse(
                isSuccess: false,
                errorMessage: "결제 응답을 받지 못했습니다"
            ))
            return
        }

        if response.success == true {
            // 결제 성공
            onComplete(PaymentResponse(
                isSuccess: true,
                impUID: response.imp_uid,
                merchantUID: response.merchant_uid,
                errorMessage: nil
            ))
        } else {
            // 결제 실패
            onComplete(PaymentResponse(
                isSuccess: false,
                impUID: response.imp_uid,
                merchantUID: response.merchant_uid,
                errorMessage: response.error_msg ?? "결제에 실패했습니다"
            ))
        }
    }
}
