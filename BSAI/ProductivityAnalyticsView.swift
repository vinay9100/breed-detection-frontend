import SwiftUI

struct ProductivityAnalyticsView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    @State private var summary: AnalyticsSummaryResponse? = nil
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    herdAnalyticsCard
                    performanceBreakdownCard
                    statsGrid
                    growthOpportunityCard
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .background(Color(hex: "F8FBF9").ignoresSafeArea())
        .onAppear {
            loadData()
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
        }
    }
    
    private func loadData() {
        isLoading = true
        AuthManager.shared.fetchReportSummary { result in
            isLoading = false
            if case .success(let data) = result {
                self.summary = data
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
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            
            Text("Productivity Analytics")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 10)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var herdAnalyticsCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Herd Analytics")
                        .font(.headline)
                    Text("Overall productivity metrics")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 15) {
                VStack(spacing: 8) {
                    Text(String(format: "%.1f", summary?.bar_chart.last?.avg_yield ?? 0))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.blue)
                    Text("Avg Yield (L/day)")
                        .font(.system(size: 11))
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color.blue.opacity(0.05))
                .cornerRadius(18)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.blue.opacity(0.1), lineWidth: 1))
                
                VStack(spacing: 8) {
                    Text(String(format: "%.0f%%", (summary?.average_accuracy ?? 0) * 100))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.green)
                    Text("Efficiency Score")
                        .font(.system(size: 11))
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color.green.opacity(0.05))
                .cornerRadius(18)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.green.opacity(0.1), lineWidth: 1))
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 10)
        .padding(.top, 20)
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.95)
        .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.1), value: appeared)
    }
    
    private var performanceBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Performance Breakdown")
                .font(.system(size: 18, weight: .bold))
            
            VStack(spacing: 20) {
                MetricProgressRow(label: "Milk Production", value: String(format: "%.0f%%", (summary?.average_accuracy ?? 0) * 100), color: .blue)
                MetricProgressRow(label: "Health Status", value: String(format: "%.0f%%", (summary?.average_accuracy ?? 0) * 105 > 100 ? 100 : (summary?.average_accuracy ?? 0) * 105), color: .green)
                MetricProgressRow(label: "Feed Efficiency", value: String(format: "%.0f%%", (summary?.average_accuracy ?? 0) * 95), color: .teal)
                MetricProgressRow(label: "Economic Value", value: String(format: "%.0f%%", (summary?.average_accuracy ?? 0) * 102 > 100 ? 100 : (summary?.average_accuracy ?? 0) * 102), color: .purple)
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 10)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: appeared)
    }
    
    private var statsGrid: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "target")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                    Text("Target")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Text("13 L/day")
                    .font(.system(size: 20, weight: .bold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 5)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "medal.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.yellow)
                    Text("Best")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Text("15.2 L/day")
                    .font(.system(size: 20, weight: .bold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 5)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: appeared)
    }
    
    private var growthOpportunityCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 12) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title3.bold())
                    .foregroundColor(.blue)
                Text("Growth Opportunity")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "1A237E"))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Improve feed quality to reach target yield of 18 L/day")
                    .font(.system(size: 15))
                    .foregroundColor(Color(hex: "283593"))
                Text("Potential revenue increase: +$250/month")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "3F51B5"))
            }
        }
        .padding(25)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(25)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.7), value: appeared)
    }
}

struct MetricProgressRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(label)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                Spacer()
                Text(value)
                    .font(.system(size: 15, weight: .bold))
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.1))
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * (Double(value.replacingOccurrences(of: "%", with: "")) ?? 0) / 100)
                }
            }
            .frame(height: 8)
        }
    }
}

#Preview {
    ProductivityAnalyticsView(path: .constant([]))
}
