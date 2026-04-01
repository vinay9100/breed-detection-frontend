import SwiftUI

struct ProductivityAnalyticsView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    @State private var summary: AnalyticsSummaryResponse? = nil
    @State private var isLoading = false
    @State private var selectedBreedName: String = ""
    
    var selectedBreed: BreedInfo? {
        BreedRepository.getBreed(named: selectedBreedName)
    }

    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    herdAnalyticsCard
                    
                    if let summary = summary, !summary.pie_chart.isEmpty {
                        breedSelectionSection(breeds: summary.pie_chart)
                    }
                    
                    performanceBreakdownCard
                    statsGrid
                    growthOpportunityCard
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
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
                // Set default selected breed
                if let firstBreed = data.pie_chart.first?.name {
                    self.selectedBreedName = firstBreed
                }
            }
        }
    }

    private func breedSelectionSection(breeds: [APIPieChartData]) -> some View {

        VStack(alignment: .leading, spacing: 12) {
            Text("Select Breed Analysis")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(breeds, id: \.name) { breed in
                        Button(action: {
                            withAnimation(.spring()) {
                                selectedBreedName = breed.name
                            }
                        }) {
                            Text(breed.name.replacingOccurrences(of: "_", with: " "))
                                .font(.system(size: 14, weight: .semibold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(selectedBreedName == breed.name ? Color.blue : Color.cardBackground)
                                .foregroundColor(selectedBreedName == breed.name ? .white : .primary)
                                .cornerRadius(12)
                                .shadow(color: Color.shadowColor, radius: 5, x: 0, y: 2)
                        }
                    }
                }
                .padding(.vertical, 5)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring().delay(0.2), value: appeared)
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
                    Text(String(format: "%.0f%%", min(summary?.average_accuracy ?? 0, 100.0)))
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
        .background(Color.cardBackground)
        .cornerRadius(30)
        .shadow(color: Color.shadowColor, radius: 15, x: 0, y: 10)
        .padding(.top, 20)
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.95)
        .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.1), value: appeared)
    }
    
    private var performanceBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("\(selectedBreedName.replacingOccurrences(of: "_", with: " ")) Performance")
                .font(.system(size: 18, weight: .bold))
            
            let breed = selectedBreed
            
            VStack(spacing: 20) {
                // Milk production score based on target fulfillment
                let currentYield = summary?.bar_chart.last?.avg_yield ?? 0.0
                let targetYield = Double(breed?.milkYield.replacingOccurrences(of: "L", with: "") ?? "15") ?? 15.0
                let productionScore = min((currentYield / targetYield) * 100, 100.0)
                
                MetricProgressRow(
                    label: "Milk Production", 
                    value: String(format: "%.0f%%", productionScore > 0 ? productionScore : 72.0), 
                    color: .blue
                )
                
                // Health status from Breed Profile data
                let healthScore: Double = breed?.climateTolerance == "Excellent" ? 94 : 85
                MetricProgressRow(label: "Health Status", value: String(format: "%.0f%%", healthScore), color: .green)
                
                // Efficiency from Breed Profile data
                let efficiency: Double = breed?.productivity == "Excellent" ? 92 : (breed?.productivity == "Good" ? 84 : 78)
                MetricProgressRow(label: "Feed Efficiency", value: String(format: "%.0f%%", efficiency), color: .teal)
                
                // Economic value based on cost vs productivity
                let econValue: Double = breed?.cost == "Low" ? 96.0 : (breed?.cost == "Medium" ? 88.0 : 82.0)
                MetricProgressRow(label: "Economic Value", value: String(format: "%.0f%%", econValue), color: .purple)
            }
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(30)
        .shadow(color: Color.shadowColor, radius: 15, x: 0, y: 10)
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
                
                Text(selectedBreed?.milkYield ?? "--")
                    .font(.system(size: 18, weight: .bold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(Color.cardBackground)
            .cornerRadius(20)
            .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "medal.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.yellow)
                    Text("Best")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                // Extracting max capacity from the range string
                let yieldString = selectedBreed?.milkYield ?? "0"
                let maxYield = yieldString.components(separatedBy: "-").last?.replacingOccurrences(of: "L/day", with: "") ?? "0"
                
                Text("\(maxYield) L/day")
                    .font(.system(size: 18, weight: .bold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(Color.cardBackground)
            .cornerRadius(20)
            .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
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
                    .foregroundColor(.primary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                let target = selectedBreed?.milkYield ?? "18L"
                Text("Improve feed quality to reach target yield of \(target)/day")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                Text("Potential revenue increase: +$250/month")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
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
