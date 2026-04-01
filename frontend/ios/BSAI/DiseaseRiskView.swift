import SwiftUI

struct DiseaseRiskView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    
    var prediction: PredictResponse? {
        AuthManager.shared.currentPrediction
    }
    
    var breedInfo: BreedInfo? {
        if let breedName = prediction?.breed_name {
            return BreedRepository.getBreed(named: breedName)
        }
        return nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    riskSummaryCard
                    commonHealthConcernsSection
                    preventionStrategyCard
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
            Text("Disease Risk Profile")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 10)
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var riskSummaryCard: some View {
        VStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "shield.checkered")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
            }
            
            Text(breedInfo?.productivity == "Excellent" ? "Low Overall Risk" : "Moderate Risk")
                .font(.title2.bold())
            
            Text("Tailored for \(prediction?.breed_name ?? "this breed") ecosystem")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(30)
        .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
    }
    
    private var commonHealthConcernsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Common Health Concerns")
                .font(.headline)
            
            VStack(spacing: 12) {
                HealthConcernRow(title: "Mastitis", desc: "Prevention: Regular udder hygiene", risk: "Medium", color: .orange)
                HealthConcernRow(title: "Foot and Mouth Disease", desc: "Prevention: Vaccination program", risk: "Low", color: .green)
                HealthConcernRow(title: "Milk Fever", desc: "Prevention: Calcium management", risk: "Medium", color: .orange)
                HealthConcernRow(title: "Respiratory Issues", desc: "Prevention: Good ventilation", risk: "Low", color: .green)
            }
        }
    }
    
    private var preventionStrategyCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(.green)
                Text("Prevention Strategy")
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                PreventionItem(text: "Regular health checkups")
                PreventionItem(text: "Maintain vaccination schedule")
                PreventionItem(text: "Ensure clean housing conditions")
            }
        }
        .padding(25)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .cornerRadius(25)
        .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
    }
}

struct HealthConcernRow: View {
    let title: String
    let desc: String
    let risk: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .frame(width: 45, height: 45)
                Image(systemName: "waveform.path.ecg")
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.headline)
                    Spacer()
                    Text(risk)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(color.opacity(0.1))
                        .foregroundColor(color)
                        .cornerRadius(8)
                }
                Text(desc)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(18)
        .shadow(color: Color.shadowColor, radius: 5, x: 0, y: 2)
    }
}

struct PreventionItem: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.green)
                .frame(width: 6, height: 6)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    DiseaseRiskView(path: .constant([]))
}
