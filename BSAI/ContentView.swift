import SwiftUI

// ContentView delegates to AppRootView which owns the NavigationStack.
struct ContentView: View {
    var body: some View {
        AppRootView()
    }
}

#Preview {
    ContentView()
}
