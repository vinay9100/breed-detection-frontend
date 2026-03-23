import SwiftUI

struct MilkYieldAnalysisView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    
    var prediction: PredictResponse? {
        AuthManager.shared.currentPrediction
    }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    primaryYieldCard
                    yieldFactorsCard
                    seasonalVariationCard
                }
                .padding()
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.easeOut(duration: 0.5), value: appeared)
            }
        }
        .background(Color.green.opacity(0.02).ignoresSafeArea())
        .onAppear {
            appeared = true
        }
    }
    
    // MARK: - Subviews
    
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
            Text("Milk Yield Analysis")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 10)
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var primaryYieldCard: some View {
        VStack(spacing: 25) {
            HStack(spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 60, height: 60)
                    Image(systemName: "drop.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(prediction?.milk_yield_range ?? "12-15 L/day")
                        .font(.title.bold())
                    Text("Average daily yield range")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            VStack(spacing: 18) {
                YieldStatRow(label: "Estimated Yield", value: "\(String(format: "%.1f", prediction?.yield_estimate ?? 0)) L/day")
                Divider()
                YieldStatRow(label: "Fat Content", value: prediction?.fat_content ?? "4.5%")
                Divider()
                YieldStatRow(label: "Breed Standard", value: prediction?.breed_name ?? "General Cattle")
            }
        }
        .padding(25)
        .background(Color.cardBackground)
        .cornerRadius(25)
        .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
    }
    
    private var yieldFactorsCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.green)
                Text("Yield Factors")
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 15) {
                FactorBullet(text: "Genetics")
                FactorBullet(text: "Nutrition")
                FactorBullet(text: "Health Management")
                FactorBullet(text: "Environmental Conditions")
            }
        }
        .padding(25)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .cornerRadius(25)
        .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
    }
    
    private var seasonalVariationCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                Text("Seasonal Variation")
                    .font(.headline)
            }
            
            Text("Milk yield may vary by 10-15% based on seasonal factors and feed availability.")
                .font(.subheadline)
                .foregroundColor(.indigo)
                .lineSpacing(4)
        }
        .padding(25)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(25)
    }
}

struct YieldStatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.headline)
        }
    }
}

struct FactorBullet: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    MilkYieldAnalysisView(path: .constant([]))
}
