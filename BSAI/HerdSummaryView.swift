import SwiftUI

struct HerdSummaryView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    @State private var summary: AnalyticsSummaryResponse? = nil
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    totalHerdCard
                    breedDistributionSection
                    statsGrid
                    productionSummaryCard
                    
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
            
            Text("Herd Summary")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 10)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var totalHerdCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total Herd")
                        .font(.headline)
                    Text("Active livestock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 15) {
                VStack(spacing: 8) {
                    Text("\(summary?.total_animals ?? 0)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.blue)
                    Text("Total Animals")
                        .font(.system(size: 11))
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color.blue.opacity(0.05))
                .cornerRadius(18)
                
                VStack(spacing: 8) {
                    Text("\(summary?.total_animals != 0 ? Int(Double(summary?.total_animals ?? 0) * 0.75) : 0)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.green)
                    Text("Lactating")
                        .font(.system(size: 11))
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color.green.opacity(0.05))
                .cornerRadius(18)
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
    
    private var breedDistributionSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Breed Distribution")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                Button("View Details") {
                    path.append(.breedDistribution)
                }
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.green)
            }
            
            VStack(spacing: 15) {
                if let pData = summary?.pie_chart {
                    ForEach(pData.indices, id: \.self) { i in
                        BreedDistributionRow(
                            breed: pData[i].name,
                            count: pData[i].count,
                            total: summary?.total_animals ?? 1,
                            color: [Color.blue, .green, .purple, .teal, .orange][i % 5]
                        )
                    }
                } else {
                    Text("No breed data available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
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
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.caption)
                    Text("Avg Yield")
                        .font(.system(size: 12))
                }
                .foregroundColor(.blue)
                
                let avgYield = summary?.bar_chart.compactMap({ $0.avg_yield }).reduce(0, +) ?? 0
                let count = Double(summary?.bar_chart.filter({ $0.avg_yield != nil }).count ?? 1)
                let realAvg = count > 0 ? avgYield / count : 0
                
                Text("\(String(format: "%.1f", realAvg)) L")
                    .font(.system(size: 20, weight: .bold))
                
                Text("Per animal/day")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(Color.cardBackground)
            .cornerRadius(20)
            .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                    Text("Confidence")
                        .font(.system(size: 12))
                }
                .foregroundColor(.green)
                
                Text("\(Int(summary?.average_accuracy ?? 0))%")
                    .font(.system(size: 20, weight: .bold))
                
                Text("Scan accuracy score")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
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
    
    private var productionSummaryCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.1))
                        .frame(width: 32, height: 32)
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.purple)
                }
                Text("Production Summary")
                    .font(.system(size: 16, weight: .bold))
            }
            
            HStack {
                Text("Daily Production")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Spacer()
                
                let avgYield = summary?.bar_chart.compactMap({ $0.avg_yield }).reduce(0, +) ?? 0
                let count = Double(summary?.bar_chart.filter({ $0.avg_yield != nil }).count ?? 1)
                let realAvg = count > 0 ? avgYield / count : 0
                let totalDaily = realAvg * Double(summary?.total_animals ?? 0)
                
                Text("\(String(format: "%.1f", totalDaily)) L")
                    .font(.system(size: 16, weight: .bold))
            }
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(25)
        .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.7), value: appeared)
    }
}

struct BreedDistributionRow: View {
    let breed: String
    let count: Int
    let total: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(breed)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(count) animals")
                    .font(.system(size: 13, weight: .bold))
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.1))
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(count) / CGFloat(total))
                }
            }
            .frame(height: 6)
        }
    }
}

#Preview {
    HerdSummaryView(path: .constant([]))
}
