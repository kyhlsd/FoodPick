//
//  EventWebView.swift
//  Presentation
//
//  Created by 김영훈 on 12/23/25.
//

import SwiftUI
import WebKit
import ComposableArchitecture
import Domain

struct EventWebView: View {
    let store: StoreOf<EventWebFeature>

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store

            ZStack(alignment: .topTrailing) {
                Group {
                    if store.isLoading {
                        ProgressView()
                    } else if let urlRequest = store.urlRequest, let accessToken = store.accessToken {
                        EventWebViewRepresentable(
                            urlRequest: urlRequest,
                            accessToken: accessToken
                        ) {
                            store.send(.attendanceCompleted($0))
                        }
                    }
                }

                // 닫기 버튼
                Button {
                    store.send(.dismiss)
                } label: {
                    AppIcon.xmarkCircle
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.custom(.gray(.gray0)))
                }
                .padding([.trailing, .top], .large)
            }
            .onAppear {
                store.send(.onAppear)
            }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

private struct EventWebViewRepresentable: UIViewRepresentable {
    let urlRequest: URLRequest
    let accessToken: String
    let onAttendanceCompleted: (Int) -> Void

    func makeUIView(context: Context) -> WKWebView {
        let contentController = WKUserContentController()

        // 브릿지 핸들러 등록
        contentController.add(context.coordinator, name: "click_attendance_button")
        contentController.add(context.coordinator, name: "complete_attendance")

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: config)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url != nil { return }
        uiView.load(urlRequest)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKScriptMessageHandler {
        var parent: EventWebViewRepresentable

        init(_ parent: EventWebViewRepresentable) {
            self.parent = parent
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            switch message.name {
            case "click_attendance_button":
                message.webView?.evaluateJavaScript("requestAttendance('\(parent.accessToken)')")

            case "complete_attendance":
                if let attendanceCount = message.body as? Int {
                    parent.onAttendanceCompleted(attendanceCount)
                }
            default:
                break
            }
        }
    }
}
