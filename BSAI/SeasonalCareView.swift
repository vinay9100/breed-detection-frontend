import SwiftUI

struct SeasonalCareView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    
    var prediction: PredictResponse? {
        AuthManager.shared.currentPrediction
    }
    
    private var currentSeason: String {
        // March to June: Summer
        // July to October: Monsoon
        // November to February: Winter
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 3...6: return "Summer"
        case 7...10: return "Monsoon"
        default: return "Winter"
        }
    }
    
    private var seasonIcon: String {
        switch currentSeason {
        case "Summer": return "sun.max.fill"
        case "Monsoon": return "cloud.rain.fill"
        default: return "snowflake"
        }
    }
    
    private var seasonColor: Color {
        switch currentSeason {
        case "Summer": return .orange
        case "Monsoon": return .blue
        default: return .cyan
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    seasonBanner
                    
                    Text("Seasonal Guidelines")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 5)
                    
                    seasonalCardsStack
                    
                    Spacer(minLength: 30)
                }
                .padding()
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
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
            Text("Seasonal Care")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 10)
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var seasonBanner: some View {
        HStack(spacing: 15) {
            Image(systemName: seasonIcon)
                .font(.title)
                .foregroundColor(seasonColor)
                .padding(12)
                .background(seasonColor.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Season: \(currentSeason)")
                    .font(.headline)
                Text("Optimized for \(prediction?.breed_name ?? "General cattle")")
                    .font(.subheadline)
                    .foregroundColor(seasonColor)
            }
            Spacer()
        }
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(25)
        .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
        .scaleEffect(appeared ? 1 : 0.95)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.1), value: appeared)
    }
    
    private var seasonalCardsStack: some View {
        VStack(spacing: 20) {
            SeasonalGuideCard(
                season: "Summer",
                icon: "sun.max.fill",
                iconColor: .orange,
                items: ["Provide shade", "Install cooling systems", "Increase water supply", "Monitor heat stress"],
                delay: 0.2,
                appeared: appeared,
                isHighlighted: currentSeason == "Summer"
            )
            
            SeasonalGuideCard(
                season: "Monsoon",
                icon: "cloud.rain.fill",
                iconColor: .blue,
                items: ["Ensure drainage", "Prevent moisture buildup", "Extra bedding", "Watch for hoof issues"],
                delay: 0.3,
                appeared: appeared,
                isHighlighted: currentSeason == "Monsoon"
            )
            
            SeasonalGuideCard(
                season: "Winter",
                icon: "snowflake",
                iconColor: .cyan,
                items: ["Provide warm shelter", "Increase feed energy", "Check for drafts", "Maintain dry bedding"],
                delay: 0.4,
                appeared: appeared,
                isHighlighted: currentSeason == "Winter"
            )
        }
    }
}

struct SeasonalGuideCard: View {
    let season: String
    let icon: String
    let iconColor: Color
    let items: [String]
    let delay: Double
    let appeared: Bool
    var isHighlighted: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .font(.title3)
                }
                
                Text(season)
                    .font(.title3.bold())
                
                Spacer()
                
                if isHighlighted {
                    Text("CURRENT")
                        .font(.system(size: 10, weight: .black))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(items, id: \.self) { item in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(iconColor.opacity(0.5))
                            .frame(width: 6, height: 6)
                        Text(item)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(28)
        .shadow(color: Color.shadowColor, radius: 15, x: 0, y: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(isHighlighted ? iconColor.opacity(0.2) : Color.clear, lineWidth: 2)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: appeared)
    }
}

#Preview {
    SeasonalCareView(path: .constant([]))
}
