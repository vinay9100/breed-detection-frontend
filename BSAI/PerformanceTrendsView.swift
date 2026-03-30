import SwiftUI

struct PerformanceTrendsView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    
    @State private var analytics: AnalyticsSummaryResponse? = nil
    @State private var isLoading = false
    
    private var monthlyData: [PerformanceTrendItem] {
        guard let items = analytics?.bar_chart, !items.isEmpty else { return [] }
        
        return items.reversed().map { item in
            let yieldVal = item.avg_yield ?? 0.0
            return PerformanceTrendItem(
                month: item.date,
                yield: String(format: "%.1f L/day", yieldVal),
                trend: "Real data",
                isPositive: true
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    overallPerformanceCard
                    monthlyTrendsSection
                    keyInsightsSection
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .onAppear {
            fetchAnalytics()
            withAnimation {
                appeared = true
            }
        }
    }
    
    private func fetchAnalytics() {
        isLoading = true
        AuthManager.shared.fetchAnalytics(timeFilter: "30 Days") { result in
            isLoading = false
            if case .success(let data) = result {
                self.analytics = data
            }
        }
    }
    
    private var navigationBar: some View {
        HStack {
            Button(action: { 
                if !path.isEmpty {
                    _ = path.removeLast()
                }
            }) {
                Image(systemName: "arrow.left")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                    .padding(12)
                    .background(Color.cardBackground)
                    .clipShape(Circle())
                    .shadow(color: Color.shadowColor, radius: 5, x: 0, y: 2)
            }
            
            Text("Performance Trends")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 10)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var overallPerformanceCard: some View {
        let scannedBreed = AuthManager.shared.currentPrediction?.breed_name
        let scannedYield = AuthManager.shared.currentPrediction?.milk_yield_range ?? "--"
        
        return VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.purple.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: "waveform.path")
                        .foregroundColor(.purple)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Performance Benchmark")
                        .font(.headline)
                    Text(scannedBreed != nil ? "Detected: \(scannedBreed!)" : "Overall Herd Analysis")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text(String(format: "%.1f L", analytics?.average_yield ?? 0.0))
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(.primary)
                    Text("Herd Avg")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                if let breed = scannedBreed {
                    Rectangle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 1, height: 40)
                        .padding(.horizontal, 10)
                    
                    VStack(spacing: 8) {
                        Text(scannedYield.replacingOccurrences(of: " Litres/day", with: ""))
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(.green)
                        Text("\(breed) Potential")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 24)
            .background(Color.purple.opacity(0.04))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.purple.opacity(0.1), lineWidth: 1)
            )
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(30)
        .shadow(color: Color.shadowColor, radius: 15, x: 0, y: 10)
        .padding(.top, 20)
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.95)
        .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.1), value: appeared)
    }
    
    private var monthlyTrendsSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Monthly Trends")
                .font(.system(size: 18, weight: .bold))
            
            VStack(spacing: 12) {
                ForEach(Array(monthlyData.enumerated()), id: \.offset) { index, item in
                    PerformanceTrendRow(item: item)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.1 + 0.3), value: appeared)
                }
            }
        }
    }
    
    private var keyInsightsSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Key Insights")
                .font(.system(size: 18, weight: .bold))
            
            HStack(alignment: .top, spacing: 15) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.green)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Positive Trend")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.green)
                    Text("Production increasing steadily over 3 months")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.green.opacity(0.05))
            .cornerRadius(20)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.7), value: appeared)
    }
}

struct PerformanceTrendItem {
    let month: String
    let yield: String
    let trend: String
    let isPositive: Bool
}

struct PerformanceTrendRow: View {
    let item: PerformanceTrendItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.month)
                    .font(.system(size: 16, weight: .bold))
                Text(item.yield)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Text("avg")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 6) {
                Image(systemName: item.isPositive ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis")
                Text(item.trend)
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(item.isPositive ? .green : .orange)
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.shadowColor, radius: 5, x: 0, y: 2)
    }
}

#Preview {
    PerformanceTrendsView(path: .constant([]))
}
