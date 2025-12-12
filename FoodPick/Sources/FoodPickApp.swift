import SwiftUI
import Presentation

@main
struct FoodPickApp: App {
    
    init() {
        FontRegistration.registerFonts()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
