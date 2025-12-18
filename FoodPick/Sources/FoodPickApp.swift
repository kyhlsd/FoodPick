import SwiftUI
import Presentation
import ComposableArchitecture

@main
struct FoodPickApp: App {

    init() {
        FontRegistration.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                LoginView(
                    store: Store(initialState: LoginFeature.State()) {
                        LoginFeature()
                    }
                )
            }
        }
    }
}
