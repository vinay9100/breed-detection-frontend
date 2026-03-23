import SwiftUI

struct ClimateSuitabilityView: View {
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
                    climateAdaptabilitySection
                    climateManagementCard
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
            Text("Climate Suitability")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 10)
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var climateAdaptabilitySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Climate Adaptability")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 15) {
                HStack(spacing: 15) {
                    Image(systemName: "thermometer.medium")
                        .font(.title2)
                        .foregroundColor(.orange)
                        .padding(12)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(breedInfo?.climateTolerance ?? "Optimal") Tolerance")
                            .font(.headline)
                            .foregroundColor(.orange)
                        Text("Optimized for \(prediction?.breed_name ?? "this breed") in \(breedInfo?.climate ?? "temperate") conditions")
                            .font(.caption)
                            .foregroundColor(.orange.opacity(0.8))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.05))
                .cornerRadius(18)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.orange.opacity(0.2), lineWidth: 1))
            }
            
            VStack(spacing: 12) {
                ClimateDetailRow(icon: "thermometer.low", title: "Optimal Temperature", value: "10-20°C", color: .green)
                ClimateDetailRow(icon: "cloud.rain.fill", title: "Humidity Tolerance", value: "60-70%", color: .blue)
                ClimateDetailRow(icon: "sun.max.fill", title: "Heat Stress Risk", value: "High >25°C", color: .red)
            }
        }
        .padding(25)
        .background(Color.cardBackground)
        .cornerRadius(25)
        .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
    }
    
    private var climateManagementCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "thermometer.sun.fill")
                    .foregroundColor(.indigo)
                Text("Climate Management")
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                ManagementItem(text: "Provide adequate shade in summer")
                ManagementItem(text: "Install cooling systems for hot climates")
                ManagementItem(text: "Ensure good ventilation in housing")
                ManagementItem(text: "Monitor heat stress indicators")
            }
        }
        .padding(25)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .cornerRadius(25)
        .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
    }
}

struct ClimateDetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .frame(width: 45, height: 45)
                Image(systemName: icon)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.headline)
            }
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.03))
        .cornerRadius(18)
    }
}

struct ManagementItem: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.indigo)
                .frame(width: 6, height: 6)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ClimateSuitabilityView(path: .constant([]))
}
