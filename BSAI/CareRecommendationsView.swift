import SwiftUI

struct CareRecommendationsView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    
    var prediction: PredictResponse? {
        AuthManager.shared.currentPrediction
    }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    careHeader
                    
                    Text("Daily Care Guidelines")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 5)
                    
                    careGuideCardsStack
                    
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
            Text("Care Recommendations")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 10)
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var careHeader: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.pink.opacity(0.05))
                    .frame(width: 100, height: 100)
                Image(systemName: "heart.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.pink)
            }
            
            VStack(spacing: 8) {
                Text("Personalized Care Plan")
                    .font(.title3.bold())
                Text("Optimized for \(prediction?.breed_name ?? "General cattle")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 35)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(30)
        .shadow(color: Color.shadowColor, radius: 15, x: 0, y: 10)
        .scaleEffect(appeared ? 1 : 0.95)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)
    }
    
    private var careGuideCardsStack: some View {
        VStack(spacing: 20) {
            CareGuideItem(
                title: "Hydration Management",
                icon: "drop.fill",
                iconColor: .blue,
                items: ["Provide 70-90L fresh water daily", "Clean water troughs twice daily", "Monitor water intake in summer"],
                priority: "High",
                delay: 0.2,
                appeared: appeared
            )
            
            CareGuideItem(
                title: "Nutrition Plan",
                icon: "leaf.fill",
                iconColor: .green,
                items: ["Balanced diet with 14-16% protein", "Regular mineral supplements", "Quality fodder and concentrate"],
                priority: "High",
                delay: 0.3,
                appeared: appeared
            )
            
            CareGuideItem(
                title: "Housing Standards",
                icon: "house.fill",
                iconColor: .indigo,
                items: ["Clean and dry bedding", "Good ventilation system", "Adequate space per animal"],
                priority: "Medium",
                delay: 0.4,
                appeared: appeared
            )
        }
    }
}

struct CareGuideItem: View {
    let title: String
    let icon: String
    let iconColor: Color
    let items: [String]
    let priority: String
    let delay: Double
    let appeared: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 50, height: 50)
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .font(.title2)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text("Priority")
                        .font(.system(size: 10, weight: .black))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(iconColor.opacity(0.1))
                        .foregroundColor(iconColor)
                        .cornerRadius(6)
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Text("•")
                            .foregroundColor(iconColor)
                        Text(item)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .cornerRadius(28)
        .shadow(color: Color.shadowColor, radius: 15, x: 0, y: 10)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: appeared)
    }
}

#Preview {
    CareRecommendationsView(path: .constant([]))
}
