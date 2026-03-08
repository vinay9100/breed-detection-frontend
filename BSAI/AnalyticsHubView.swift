import SwiftUI

struct AnalyticsHubView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    @State private var analytics: AnalyticsSummaryResponse? = nil
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    performanceOverviewCard
                    analyticsCategoriesSection
                    syncNote
                    
                    Spacer(minLength: 50)
                }
                .padding(.top, 10)
            }
        }
        .background(Color(hex: "F8FBF9").ignoresSafeArea())
        .onAppear {
            loadAnalytics()
            withAnimation {
                appeared = true
            }
        }
    }
    
    private func loadAnalytics() {
        isLoading = true
        AuthManager.shared.fetchAnalytics(timeFilter: "All") { result in
            isLoading = false
            if case .success(let data) = result {
                self.analytics = data
            }
        }
    }
    
    // MARK: - Subviews
    
    private var header: some View {
        HStack {
            if path.last == .analyticsHub {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        _ = path.removeLast()
                    }
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title3.bold())
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(Circle().fill(Color.gray.opacity(0.1)))
                }
            }
            
            Text("Analytics Hub")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, path.last == .analyticsHub ? 10 : 0)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 15)
        .background(Color(.systemBackground))
    }
    
    private var performanceOverviewCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "00C853"))
                        .frame(width: 44, height: 44)
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Performance Overview")
                        .font(.headline)
                    Text("Last 30 days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 12) {
                MiniStatCard(label: "Total Animals", value: "\(analytics?.total_animals ?? 0)", trend: "", color: .green)
                MiniStatCard(label: "Avg Accuracy", value: "\(Int(analytics?.average_accuracy ?? 0))%", trend: "", color: Color(hex: "00C853"))
                MiniStatCard(label: "Herd Size", value: "\(analytics?.total_animals ?? 0)", trend: "", color: Color(hex: "00C853"))
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 10)
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.95)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)
    }
    
    private var analyticsCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Analytics Categories")
                .font(.headline)
                .padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                AnalyticsCategoryRow(icon: "chart.line.uptrend.xyaxis", iconColor: Color(hex: "2979FF"), title: "Performance Trends", subtitle: "Track yield and productivity over time") {
                    path.append(.performanceTrends)
                }
                
                AnalyticsCategoryRow(icon: "waveform.path", iconColor: Color(hex: "AA00FF"), title: "Productivity Analytics", subtitle: "Detailed herd productivity metrics") {
                    path.append(.productivityAnalytics)
                }
                
                AnalyticsCategoryRow(icon: "person.2.fill", iconColor: Color(hex: "00C853"), title: "Herd Summary", subtitle: "Complete overview of your livestock") {
                    path.append(.herdSummary)
                }
                
                AnalyticsCategoryRow(icon: "chart.pie.fill", iconColor: Color(hex: "FF6D00"), title: "Breed Distribution", subtitle: "Analyze breed composition") {
                    path.append(.breedDistribution)
                }
                
                AnalyticsCategoryRow(icon: "calendar.badge.clock", iconColor: Color(hex: "536DFE"), title: "Scan History", subtitle: "Review all past scans") {
                    path.append(.scanHistory)
                }
                
                AnalyticsCategoryRow(icon: "chart.bar.xaxis", iconColor: Color(hex: "FF4081"), title: "Yield Forecast", subtitle: "AI-powered production predictions") {
                    path.append(.yieldPrediction)
                }
            }
        }
        .padding(.horizontal, 24)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appeared)
    }
    
    private var syncNote: some View {
        HStack(spacing: 12) {
            Text("💡")
            Text("Analytics data syncs automatically across all your devices")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "2E7D32"))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "E8F5E9"))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color(hex: "C8E6C9"), lineWidth: 1)
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 30)
    }
}

// MARK: - Reusable MiniStatCard
struct MiniStatCard: View {
    let label: String
    let value: String
    let trend: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            Text(trend)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Reusable AnalyticsCategoryRow
struct AnalyticsCategoryRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundColor(.gray.opacity(0.3))
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(22)
            .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    AnalyticsHubView(path: .constant([]))
}
