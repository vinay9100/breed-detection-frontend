import SwiftUI

struct ReportsView: View {
    @Binding var path: [AppRoute]
    
    @State private var showFilters = false
    @State private var selectedFilter: ReportFilter = .all
    @State private var scans: [DetectionRecord] = []
    @State private var isLoading = false
    @ObservedObject private var localization = LocalizationManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    latestAnalysisCard
                    pastReportsSection
                    
                    Spacer(minLength: 100)
                }
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .sheet(isPresented: $showFilters) {
            ReportsFilterSheet(selectedFilter: $selectedFilter)
        }
        .onAppear {
            loadReports()
        }
    }
    
    private func loadReports() {
        isLoading = true
        AuthManager.shared.fetchMyDetections { result in
            isLoading = false
            if case .success(let data) = result {
                self.scans = data
            }
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            Text(localization.t("reports_title"))
                .font(.largeTitle.bold())
            
            Spacer()
            
            Button(action: {
                showFilters = true
            }) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.title2)
                    .foregroundColor(.green)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
    
    // MARK: - Latest Card
    
    private var latestAnalysisCard: some View {
        Button(action: {
            if let firstScan = scans.first {
                let prediction = PredictResponse(
                    breed_name: firstScan.breed_name,
                    confidence_score: firstScan.confidence_score,
                    yield_estimate: firstScan.yield_estimate,
                    milk_yield_range: firstScan.milk_yield_range,
                    animal_type: firstScan.animal_type,
                    fat_content: firstScan.fat_content,
                    image_url: firstScan.image_path,
                    message: nil
                )
                AuthManager.shared.currentPrediction = prediction
                path.append(.detectionResult)
            }
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(localization.t("reports_latest_analysis"))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(scans.first?.breed_name ?? localization.t("reports_no_scans"))")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            .padding(24)
            .background(
                LinearGradient(
                    colors: [.green, Color(hex: "1B5E20")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(25)
            .shadow(color: Color.green.opacity(0.3), radius: 15, x: 0, y: 8)
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
    
    // MARK: - Past Reports
    
    private var pastReportsSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(localization.t("reports_past_reports"))
                .font(.headline)
                .padding(.horizontal, 24)
            
            VStack(spacing: 14) {
                ForEach(scans) { scan in
                    Button(action: {
                        // Load this scan's data into the shared prediction state
                        let prediction = PredictResponse(
                            breed_name: scan.breed_name,
                            confidence_score: scan.confidence_score,
                            yield_estimate: scan.yield_estimate,
                            milk_yield_range: scan.milk_yield_range,
                            animal_type: scan.animal_type,
                            fat_content: scan.fat_content,
                            image_url: scan.image_path,
                            message: nil
                        )
                        AuthManager.shared.currentPrediction = prediction
                        path.append(.detectionResult)
                    }) {
                        ReportHistoryRow(
                            title: scan.breed_name,
                            date: formatDate(scan.detected_at),
                            type: "Detection"
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Filtering Logic
    
    private var filteredReports: [DetectionRecord] {
        return scans
    }
    
    private var allReports: [ReportItem] {
        [
            ReportItem(title: "January 2026", date: "Feb 01, 2026", type: "Monthly"),
            ReportItem(title: "Year End 2025", date: "Jan 05, 2026", type: "Annual"),
            ReportItem(title: "December 2025", date: "Jan 01, 2026", type: "Monthly"),
            ReportItem(title: "November 2025", date: "Dec 01, 2025", type: "Monthly")
        ]
    }
}

// MARK: - Report Model

struct ReportItem {
    let title: String
    let date: String
    let type: String
}

enum ReportFilter: String {
    case all = "All"
    case monthly = "Monthly"
    case annual = "Annual"
}

// MARK: - Filter Sheet

struct ReportsFilterSheet: View {
    @Binding var selectedFilter: ReportFilter
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var localization = LocalizationManager.shared
    
    var body: some View {
        VStack(spacing: 25) {
            Text(localization.t("reports_filter_title"))
                .font(.title2.bold())
            
            ForEach([ReportFilter.all, .monthly, .annual], id: \.self) { filter in
                Button(action: {
                    selectedFilter = filter
                    dismiss()
                }) {
                    HStack {
                        Text(filter.rawValue)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if selectedFilter == filter {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color.appBackground)
                    .cornerRadius(12)
                }
            }
            
            Spacer()
        }
        .padding()
        .presentationDetents([.medium])
    }
}

// MARK: - Report Row

struct ReportHistoryRow: View {
    let title: String
    let date: String
    let type: String
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: "doc.text")
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(type)
                .font(.system(size: 10, weight: .bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.1))
                .foregroundColor(.secondary)
                .cornerRadius(6)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray.opacity(0.3))
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(18)
        .shadow(color: Color.shadowColor, radius: 5, x: 0, y: 2)
    }
}

private func formatDate(_ dateStr: String) -> String {
    // Try with fractional seconds first
    let formatter1 = ISO8601DateFormatter()
    formatter1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let date = formatter1.date(from: dateStr) {
        let display = DateFormatter()
        display.dateStyle = .medium
        display.timeStyle = .short
        return display.string(from: date)
    }
    // Try without fractional seconds
    let formatter2 = ISO8601DateFormatter()
    formatter2.formatOptions = [.withInternetDateTime]
    if let date = formatter2.date(from: dateStr) {
        let display = DateFormatter()
        display.dateStyle = .medium
        display.timeStyle = .short
        return display.string(from: date)
    }
    return dateStr
}

#Preview {
    ReportsView(path: .constant([]))
}
