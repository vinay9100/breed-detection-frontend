import SwiftUI

struct ScanHistoryView: View {
    @Binding var path: [AppRoute]
    @ObservedObject private var localization = LocalizationManager.shared
    @State private var appeared = false
    
    @State private var scans: [DetectionRecord] = []
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    headerSection
                    historyList
                    footerNote
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            loadScans()
            withAnimation {
                appeared = true
            }
        }
    }
    
    private func loadScans() {
        isLoading = true
        AuthManager.shared.fetchMyDetections { result in
            isLoading = false
            if case .success(let data) = result {
                self.scans = data
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
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            
            Text(LocalizationManager.shared.t("scan_history_title"))
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 10)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var headerSection: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizationManager.shared.t("scan_history_recent"))
                    .font(.system(size: 20, weight: .bold))
                Text("\(scans.count) \(LocalizationManager.shared.t("scan_history_total"))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(LocalizationManager.shared.t("scan_history_analytics")) {
                path.append(.analyticsHub)
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.green)
        }
        .padding(.top, 20)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5), value: appeared)
    }
    
    private var historyList: some View {
        VStack(spacing: 16) {
            ForEach(Array(scans.enumerated()), id: \.offset) { index, scan in
                Button(action: {
                    // Convert DetectionRecord to PredictResponse to view it
                    AuthManager.shared.currentPrediction = PredictResponse(
                        breed_name: scan.breed_name,
                        confidence_score: scan.confidence_score,
                        yield_estimate: scan.yield_estimate,
                        milk_yield_range: scan.milk_yield_range,
                        animal_type: scan.animal_type,
                        fat_content: scan.fat_content,
                        image_url: scan.image_path,
                        message: nil
                    )
                    withAnimation(.spring()) {
                        path.append(.detectionResult)
                    }
                }) {
                    ScanHistoryCard(scan: scan)
                }
                .buttonStyle(PlainButtonStyle())
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.1 + 0.2), value: appeared)
            }
        }
    }
    
    private var footerNote: some View {
        HStack(spacing: 12) {
            Text("📊")
                .font(.system(size: 18))
            Text("Tap any scan to view detailed results and insights")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.blue)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.blue.opacity(0.1), lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.6), value: appeared)
    }
}

struct ScanItem {
    let breed: String
    let date: String
    let confidence: String
    let yield: String
}

struct ScanHistoryCard: View {
    let scan: DetectionRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(scan.breed_name)
                        .font(.system(size: 18, weight: .bold))
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(formatDate(scan.detected_at))
                            .font(.system(size: 13))
                    }
                    .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "eye")
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 15) {
                if let imagePath = scan.image_path, let url = URL(string: "\(AuthManager.shared.baseURL)\(imagePath)") {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Color.gray.opacity(0.1)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipped()
                        case .failure(_):
                            Color.gray.opacity(0.1)
                        @unknown default:
                            Color.gray.opacity(0.1)
                        }
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                HStack(spacing: 40) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Confidence")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text("\(Int(scan.confidence_score))%")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.green)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text("Yield")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        Text("\(String(format: "%.1f", scan.yield_estimate ?? 0.0)) L/day")
                            .font(.system(size: 16, weight: .bold))
                    }
                }
            }
        }
        .padding(24)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
    }

    private func formatDate(_ dateStr: String) -> String {
        // Assume ISO format from backend
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateStr) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        return dateStr
    }
}

#Preview {
    ScanHistoryView(path: .constant([]))
}
