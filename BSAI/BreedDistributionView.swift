import SwiftUI
import UIKit


struct BreedDistributionView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    
    @State private var summary: AnalyticsSummaryResponse? = nil
    @State private var isLoading = false
    
    var breedItems: [BreedDistItem] {
        guard let data = summary?.pie_chart else { return [] }
        let total = summary?.total_animals ?? 1
        let colors: [Color] = [.blue, .green, .purple, .orange, .pink, .teal]
        
        return data.enumerated().map { index, apiData in
            let percentage = total > 0 ? (apiData.count * 100 / total) : 0
            return BreedDistItem(
                name: apiData.name,
                yield: "Live statistics",
                count: apiData.count,
                percentage: percentage,
                color: colors[index % colors.count]
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    herdCompositionCard
                    distributionChartSection
                    breedList
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .onAppear {
            loadData()
            withAnimation {
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
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            
            Text("Breed Distribution")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 10)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var herdCompositionCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.purple.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: "chart.pie.fill")
                        .foregroundColor(.purple)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Herd Composition")
                        .font(.headline)
                    Text("Breed breakdown")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(spacing: 8) {
                Text("\(summary?.total_animals ?? 0) Animals")
                    .font(.system(size: 34, weight: .black))
                    .foregroundColor(.primary)
                
                Text("Across \(summary?.pie_chart.count ?? 0) different breeds")
                    .font(.subheadline)
                    .foregroundColor(.purple)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
            .background(Color.purple.opacity(0.03))
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
    
    private var distributionChartSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Distribution Chart")
                .font(.system(size: 18, weight: .bold))
            
            HStack(spacing: 2) {
                if breedItems.isEmpty {
                    Rectangle().fill(Color.gray.opacity(0.1))
                } else {
                    ForEach(breedItems.indices, id: \.self) { i in
                        let item = breedItems[i]
                        Rectangle()
                            .fill(item.color)
                            .frame(maxWidth: .infinity)
                            .frame(width: CGFloat(item.percentage) * 3) // approximation for visual
                    }
                }
            }
            .frame(height: 25)
            .cornerRadius(8)
            .clipped()
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.3), value: appeared)
    }
    
    private var breedList: some View {
        VStack(spacing: 12) {
            ForEach(Array(breedItems.enumerated()), id: \.offset) { index, item in
                BreedDistRow(item: item)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.1 + 0.5), value: appeared)
            }
        }
    }
}

struct BreedDistItem {
    let name: String
    let yield: String
    let count: Int
    let percentage: Int
    let color: Color
}

struct BreedDistRow: View {
    let item: BreedDistItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(item.color)
                    .frame(width: 14, height: 14)
                    .padding(.top, 4)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.system(size: 16, weight: .bold))
                    Text(item.yield)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(item.count)")
                        .font(.system(size: 16, weight: .bold))
                    Text("\(item.percentage)%")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.1))
                    Capsule()
                        .fill(item.color)
                        .frame(width: geo.size.width * CGFloat(item.percentage) / 100)
                }
            }
            .frame(height: 5)
        }
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(22)
        .shadow(color: Color.shadowColor, radius: 8, x: 0, y: 4)
    }
}

struct RoundedCorners: View {
    var color: Color
    var corners: UIRectCorner
    var radius: CGFloat = 8
    
    var body: some View {
        Rectangle()
            .fill(color)
            .clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

#Preview {
    BreedDistributionView(path: .constant([]))
}
