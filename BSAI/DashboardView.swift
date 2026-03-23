import SwiftUI

struct DashboardView: View {
    @Binding var path: [AppRoute]
    @ObservedObject private var localization = LocalizationManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(path: $path)
                .tabItem { Label(LocalizationManager.shared.t("home_tab"), systemImage: "house.fill") }
                .tag(0)

            AnalyticsHubView(path: $path)
                .tabItem { Label(LocalizationManager.shared.t("analytics_tab"), systemImage: "chart.bar.fill") }
                .tag(1)

            ReportsView(path: $path)
                .tabItem { Label(LocalizationManager.shared.t("reports_tab"), systemImage: "doc.text.fill") }
                .tag(2)

            ProfileView(path: $path)
                .tabItem { Label(LocalizationManager.shared.t("profile_title"), systemImage: "person.fill") }
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
