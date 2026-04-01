import SwiftUI

struct YieldForecastView: View {
    @Binding var path: [AppRoute]
    let params: YieldPredictionParams
    @State private var appeared = false
    @State private var pricePerLitre: String = "65"
    
    var predictedYield: Double {
        var base = params.dailyYield
        
        // 1. Lactation stage adjustment
        if params.lactationStage.contains("Early") { base *= 1.05 }
        else if params.lactationStage.contains("Late") { base *= 0.90 }
        
        // 2. Feed Quality
        if params.feedQuality.contains("Premium") { base *= 1.10 }
        else if params.feedQuality.contains("Basic") { base *= 0.85 }
        
        // 3. Temperature Stress
        if params.temperature > 35 { base *= 0.90 }
        else if params.temperature < 10 { base *= 0.95 }
        
        return base
    }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    mainForecastCard
                    weeklyBreakdown
                    influencingFactors
                    
                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 24)
            }
        }
        .background(Color(hex: "F8FBF9").ignoresSafeArea())
        .onAppear {
            appeared = true
        }
    }
    
    // MARK: - Subviews
    
    private var navigationBar: some View {
        HStack {
            Button(action: {
                _ = path.removeLast()
            }) {
                Image(systemName: "arrow.left")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            Text("Yield Forecast")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 10)
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var mainForecastCard: some View {
        VStack(spacing: 20) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("30-Day Forecast")
                        .font(.headline)
                    Text("AI-Powered Predictions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            VStack(spacing: 25) {
                VStack(spacing: 12) {
                    Text("\(predictedYield, specifier: "%.1f") L/day")
                        .font(.system(size: 34, weight: .black))
                        .foregroundColor(Color(hex: "1F3B73"))
                    
                    HStack(spacing: 8) {
                        Text("Average predicted yield")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        
                        Text("•")
                            .foregroundColor(.gray.opacity(0.3))
                        
                        HStack(spacing: 4) {
                            Text("₹")
                            TextField("65", text: $pricePerLitre)
                                .keyboardType(.numberPad)
                                .fixedSize()
                            Text("/L")
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.05))
                        .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 25)
                .background(Color.blue.opacity(0.03))
                .cornerRadius(20)

                
                // Income Prediction
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Expected Daily Revenue")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("₹\((predictedYield * (Double(pricePerLitre) ?? 0)), specifier: "%.2f")")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "2E7D32"))
                    }
                    Spacer()
                    Image(systemName: "indianrupeesign.circle.fill")
                        .font(.title)
                        .foregroundColor(.green.opacity(0.7))
                }
                .padding(20)
                .background(Color.green.opacity(0.05))
                .cornerRadius(18)
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 10)
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.95)
        .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.1), value: appeared)
    }
    
    private var weeklyBreakdown: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                Text("Detailed Daily Report")
                    .font(.headline)
                Spacer()
                Text("Week 1")
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(1...7, id: \.self) { day in
                        let dailyPredicted = predictedYield + Double.random(in: -1...1)
                        VStack(spacing: 10) {
                            Text("Day \(day)")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            
                            Text("\(dailyPredicted, specifier: "%.1f")L")
                                .font(.system(size: 16, weight: .bold))
                            
                            Text("₹\((dailyPredicted * (Double(pricePerLitre) ?? 0)), specifier: "%.0f")")
                                .font(.system(size: 11))
                                .foregroundColor(.green)
                        }
                        .padding(.vertical, 15)
                        .padding(.horizontal, 20)
                        .background(day == 1 ? Color.green.opacity(0.1) : Color.gray.opacity(0.04))
                        .cornerRadius(16)

                    }
                }
            }
            
            VStack(spacing: 12) {
                ForecastRow(days: "Week 2 (Forecast)", yield: String(format: "%.1f L/day", predictedYield * 1.02), status: "+2.0%", statusColor: .green, showIcon: true, icon: "arrow.up.right")
                ForecastRow(days: "Week 3 (Forecast)", yield: String(format: "%.1f L/day", predictedYield * 1.04), status: "+4.1%", statusColor: .green, showIcon: true, icon: "arrow.up.right")
                ForecastRow(days: "Week 4 (Forecast)", yield: String(format: "%.1f L/day", predictedYield * 0.98), status: "-2.2%", statusColor: .orange, showIcon: true, icon: "arrow.down.right")
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.03), radius: 12, x: 0, y: 8)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appeared)
    }
    
    private var influencingFactors: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Influencing Factors")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 15) {
                // Feed quality factor
                FactorRow(icon: "leaf.fill", color: .green, title: params.feedQuality, desc: params.feedQuality.contains("Premium") ? "High nutrition supports peak production" : (params.feedQuality.contains("Basic") ? "Limited nutrients may reduce yield" : "Standard diet supports steady yield"))
                
                // Temperature factor
                if params.temperature > 35 {
                    FactorRow(icon: "thermometer.sun.fill", color: .orange, title: "Heat Stress", desc: "High temperatures may cause yield reduction")
                } else if params.temperature < 10 {
                    FactorRow(icon: "thermometer.snowflake", color: .blue, title: "Cold Stress", desc: "Low temperatures may slightly impact productivity")
                } else {
                    FactorRow(icon: "thermometer.medium", color: .green, title: "Optimal Temperature", desc: "Current climate is favorable for production")
                }
                
                // Lactation factor
                FactorRow(icon: "waveform.path", color: .purple, title: params.lactationStage, desc: params.lactationStage.contains("Early") ? "Animal is in a high-yield growth phase" : (params.lactationStage.contains("Late") ? "Yield naturally tapering towards end of cycle" : "Stable production during mid-cycle"))
            }
        }
        .padding(25)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 5)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: appeared)
    }
}

struct FactorRow: View {
    let icon: String
    let color: Color
    let title: String
    let desc: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                Text(desc)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ForecastRow: View {
    let days: String
    let yield: String
    let status: String
    let statusColor: Color
    var showIcon: Bool = false
    var icon: String = ""
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(days)
                    .font(.system(size: 16, weight: .bold))
                Text(yield)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                if showIcon {
                    Image(systemName: icon)
                }
                Text(status)
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(statusColor)
        }
        .padding(16)
        .background(Color.gray.opacity(0.03))
        .cornerRadius(18)
    }
}

#Preview {
    YieldForecastView(path: .constant([]), params: YieldPredictionParams(dailyYield: 15.5, lactationStage: "Early (0–100 days)", feedQuality: "Standard (Normal feed)", temperature: 34.0, timeframe: "Next 30 days"))
}
