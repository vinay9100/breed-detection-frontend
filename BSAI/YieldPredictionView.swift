import SwiftUI

struct YieldPredictionView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    
    // Form States
    @State private var dailyYield: String = "15.5"
    @State private var lactationStage: String = "Early (0–100 days)"
    @State private var feedQuality: String = "Standard (Normal feed)"
    @State private var temperature: String = "34"
    @State private var timeframe: String = "Next 30 days"
    
    let lactationOptions = [
        "Early (0–100 days)",
        "Mid (100–200 days)",
        "Late (200+ days)"
    ]
    
    let feedOptions = [
        "Premium (High nutrition)",
        "Standard (Normal feed)",
        "Basic (Limited resources)"
    ]
    
    let timeframeOptions = [
        "Next 7 days",
        "Next 14 days",
        "Next 30 days",
        "Next 90 days"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    instructionCard
                    formContainer
                    actionButton
                    
                    Spacer(minLength: 60)
                }
                .padding(.horizontal, 24)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
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
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            Text("Yield Prediction")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 10)
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var instructionCard: some View {
        HStack(spacing: 15) {
            Image(systemName: "info.circle.fill")
                .font(.title2)
                .foregroundColor(.green)
            Text("Fill in the latest data to get a high-accuracy milk yield prediction.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(Color.green.opacity(0.05))
        .cornerRadius(20)
        .padding(.top, 10)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)
    }
    
    private var formContainer: some View {
        VStack(spacing: 20) {
            // 1. Current Daily Yield
            NativeFormItem(label: "Current Daily Yield (Liters)", icon: "drop.fill", iconColor: .blue) {
                TextField("e.g., 15.5", text: $dailyYield)
                    .keyboardType(.decimalPad)
                    .font(.body.bold())
            }

            // 2. Lactation Stage
            NativeFormItem(label: "Lactation Stage", icon: "waveform.path", iconColor: .purple) {
                Menu {
                    ForEach(lactationOptions, id: \.self) { option in
                        Button(option) { lactationStage = option }
                    }
                } label: {
                    HStack {
                        Text(lactationStage)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                    }
                }
            }

            // 3. Feed Quality
            NativeFormItem(label: "Feed Quality", icon: "leaf.fill", iconColor: .green) {
                Menu {
                    ForEach(feedOptions, id: \.self) { option in
                        Button(option) { feedQuality = option }
                    }
                } label: {
                    HStack {
                        Text(feedQuality)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                    }
                }
            }

            // 4. Average Temperature
            NativeFormItem(label: "Average Temperature (°C)", icon: "thermometer.medium", iconColor: .orange) {
                TextField("e.g., 34", text: $temperature)
                    .keyboardType(.numberPad)
                    .font(.body.bold())
            }

            // 5. Prediction Timeframe
            NativeFormItem(label: "Prediction Timeframe", icon: "clock.fill", iconColor: .indigo) {
                Menu {
                    ForEach(timeframeOptions, id: \.self) { option in
                        Button(option) { timeframe = option }
                    }
                } label: {
                    HStack {
                        Text(timeframe)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appeared)
    }
    
    private var actionButton: some View {
        Button(action: {
            path.append(.yieldForecast)
        }) {
            HStack {
                Text("Generate AI Prediction")
                    .font(.headline)
                Image(systemName: "sparkles")
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color.green)
            .cornerRadius(18)
            .shadow(color: Color.green.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.top, 10)
        .buttonStyle(ScaleButtonStyle())
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: appeared)
    }
}

// MARK: - Native Styled Components

struct NativeFormItem<Content: View>: View {
    let label: String
    let icon: String
    let iconColor: Color
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(iconColor)
                Text(label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            
            content()
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.04))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.gray.opacity(0.08), lineWidth: 1)
                )
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    YieldPredictionView(path: .constant([]))
}
