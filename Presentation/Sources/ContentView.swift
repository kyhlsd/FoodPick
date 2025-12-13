import SwiftUI

public struct ContentView: View {
    public init() {}
    
    public var body: some View {
        VStack {
            Text("글씨 테스트")
                .font(.custom(.jalnan(.title1)))
                .padding(.vertical, .xLarge)
            AppIcon.communityEmpty
                .foregroundStyle(.custom(.brand(.blackSprout)))
        }
    }
}

#Preview {
    ContentView()
}
