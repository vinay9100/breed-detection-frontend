import SwiftUI

struct DashboardView: View {
    @Binding var path: [AppRoute]
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(path: $path)
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            AnalyticsHubView(path: $path)
                .tabItem { Label("Analytics", systemImage: "chart.bar.fill") }
                .tag(1)

            ReportsView(path: $path)
                .tabItem { Label("Reports", systemImage: "doc.text.fill") }
                .tag(2)

            ProfileView(path: $path)
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(3)
        }
        .tint(.green)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    DashboardView(path: .constant([]))
}
