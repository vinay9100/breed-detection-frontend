import SwiftUI

struct ProductivityScoreView: View {
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
                    scoreGaugeCard
                    performanceBreakdown
                    improvementPotential
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
            Text("Productivity Score")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 10)
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var scoreGaugeCard: some View {
        let score = (breedInfo?.productivity == "Excellent") ? 94 : ((breedInfo?.productivity == "Good") ? 82 : 75)
        
        return VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.1), lineWidth: 15)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: appeared ? CGFloat(Double(score) / 100.0) : 0)
                    .stroke(
                        LinearGradient(colors: [.green, .green.opacity(0.5)], startPoint: .top, endPoint: .bottom),
                        style: StrokeStyle(lineWidth: 15, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.5).delay(0.2), value: appeared)
                
                VStack(spacing: 0) {
                    Text("\(score)")
                        .font(.system(size: 45, weight: .bold))
                    Text("/ 100")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 10)
            
            VStack(spacing: 5) {
                Text(breedInfo?.productivity ?? "High")
                    .font(.title3.bold())
                Text("Efficiency rating for \(prediction?.breed_name ?? "this breed")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(30)
        .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
    }
    
    private var performanceBreakdown: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Performance Factors")
                .font(.headline)
            
            VStack(spacing: 25) {
                ScoreProgressBar(label: "Genetic Quality", score: 92, color: .blue)
                ScoreProgressBar(label: "Productivity Level", score: breedInfo?.productivity == "Excellent" ? 95 : 85, color: .green)
                ScoreProgressBar(label: "Adaptability", score: breedInfo?.climateTolerance == "Excellent" ? 98 : 88, color: .purple)
                ScoreProgressBar(label: "Feed Conversion", score: breedInfo?.feedCost == "Low" ? 94 : 82, color: .teal)
            }
        }
        .padding(25)
        .background(Color.cardBackground)
        .cornerRadius(25)
        .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
    }
    
    private var improvementPotential: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.green)
                Text("Improvement Potential")
                    .font(.headline)
            }
            
            Text("Focus on reproductive management to further increase the overall score.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding(25)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.green.opacity(0.05))
        .cornerRadius(25)
    }
}

struct ScoreProgressBar: View {
    let label: String
    let score: Int
    let color: Color
    
    @State private var barWidth: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(score)/100")
                    .font(.subheadline.bold())
                    .foregroundColor(color)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * (CGFloat(score) / 100) * barWidth, height: 8)
                }
            }
            .frame(height: 8)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.5)) {
                barWidth = 1.0
            }
        }
    }
}

#Preview {
    ProductivityScoreView(path: .constant([]))
}
