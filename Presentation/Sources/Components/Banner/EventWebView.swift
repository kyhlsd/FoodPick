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

struct AuthenticatedEventWebView: View {
    let urlPath: String

    @Dependency(\.webViewService) var webViewService
    @State private var authInfo: (urlRequest: URLRequest, accessToken: String)?

    var body: some View {
        Group {
            if let authInfo = authInfo {
                EventWebView(
                    urlRequest: authInfo.urlRequest,
                    accessToken: authInfo.accessToken
                )
            } else {
                ProgressView()
            }
        }
        .task {
            do {
                authInfo = try await webViewService.getAuthenticationInfo(urlPath: urlPath)
            } catch {

            }
        }
    }
}

private struct EventWebView: UIViewRepresentable {
    let urlRequest: URLRequest
    let accessToken: String

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
        var parent: EventWebView
        
        init(_ parent: EventWebView) {
            self.parent = parent
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            switch message.name {
            case "click_attendance_button":
                message.webView?.evaluateJavaScript("requestAttendance('\(parent.accessToken)')")
                
            case "complete_attendance":
                if let attendanceCount = message.body as? Int {
                    
                }
            default:
                break
            }
        }
    }
}
