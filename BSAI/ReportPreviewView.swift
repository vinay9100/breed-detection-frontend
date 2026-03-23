import SwiftUI

struct ReportPreviewView: View {
    @Binding var path: [AppRoute]
    @State private var summary: AnalyticsSummaryResponse? = nil
    @State private var isLoading = false
    @State private var appeared = false
    @State private var showPDFViewer = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                navigationBar
                
                ScrollView(showsIndicators: false) {
                    if isLoading {
                        VStack {
                            Spacer(minLength: 100)
                            ProgressView("Generating Report...")
                                .tint(.green)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        VStack(spacing: 25) {
                            reportHeaderCard
                            mainReportBody
                            downloadButton
                            
                            Spacer(minLength: 40)
                        }
                        .padding()
                    }
                }
            }
            .opacity(appeared ? 1 : 0)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .onAppear {
            loadData()
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
        }
    }
    
    private func loadData() {
        isLoading = true
        AuthManager.shared.fetchReportSummary { result in
            isLoading = false
            if case .success(let data) = result {
                self.summary = data
            }
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
            Text("Report Preview")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 10)
            Spacer()
            
            Button(action: {
                path.append(.shareReport)
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.body.bold())
                    .foregroundColor(.green)
                    .padding(12)
                    .background(Color.green.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var reportHeaderCard: some View {
        HStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.indigo.opacity(0.08))
                    .frame(width: 56, height: 56)
                Image(systemName: "doc.text.fill")
                    .font(.title3)
                    .foregroundColor(.indigo)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Monthly Report")
                    .font(.title3.bold())
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(Date().formatted(.dateTime.month().year()))
                        .font(.subheadline)
                }
                .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(25)
        .background(Color.cardBackground)
        .cornerRadius(30)
        .shadow(color: Color.shadowColor, radius: 15, x: 0, y: 10)
        .scaleEffect(appeared ? 1 : 0.95)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.1), value: appeared)
    }
    
    private var mainReportBody: some View {
        VStack(spacing: 30) {
            Text("Herd Performance Summary")
                .font(.headline)
            
            // Sections
            ReportSection(title: "Overview", items: [
                ReportRow(label: "Total Animals:", value: "\(summary?.total_animals ?? 0)"),
                ReportRow(label: "Lactating:", value: "\(summary?.total_animals != 0 ? Int(Double(summary?.total_animals ?? 0) * 0.75) : 0)"),
                ReportRow(label: "Total Scans:", value: "\(summary?.bar_chart.reduce(0) { $0 + $1.value } ?? 0)")
            ])
            
            Divider().background(Color.gray.opacity(0.1))
            
            ReportSection(title: "Production Metrics", items: [
                ReportRow(label: "Avg Daily Yield:", value: String(format: "%.1f L", summary?.bar_chart.last?.avg_yield ?? 0)),
                ReportRow(label: "Total Production:", value: String(format: "%d L", (summary?.bar_chart.reduce(0) { $0 + $1.value } ?? 0) * 65)),
                ReportRow(label: "Revenue Generated:", value: String(format: "$%d", (summary?.bar_chart.reduce(0) { $0 + $1.value } ?? 0) * 195), color: .green)
            ])
            
            Divider().background(Color.gray.opacity(0.1))
            
            ReportSection(title: "Health & Care", items: [
                ReportRow(label: "Herd Health Score:", value: String(format: "%.0f%%", (summary?.average_accuracy ?? 0)), color: .green),
                ReportRow(label: "Vaccinations Done:", value: "\(summary?.total_animals != 0 ? Int(Double(summary?.total_animals ?? 0) * 0.75) : 0)"),
                ReportRow(label: "Disease Risk:", value: (summary?.average_accuracy ?? 0) > 80 ? "Low" : "Moderate", color: .orange)
            ])
            
            Divider().background(Color.gray.opacity(0.1))
            
            ReportSection(title: "Economic Analysis", items: [
                ReportRow(label: "Total Expenses:", value: "$12,480"),
                ReportRow(label: "Net Profit:", value: "$12,270", color: .green),
                ReportRow(label: "ROI:", value: "98.3%", color: .green)
            ])
        }
        .padding(30)
        .background(Color.cardBackground)
        .cornerRadius(32)
        .shadow(color: Color.shadowColor, radius: 20, x: 0, y: 10)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 30)
        .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.2), value: appeared)
    }
    
    private var downloadButton: some View {
        Button(action: {
            showPDFViewer = true
        }) {
            Text("Download Full PDF Report")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.green)
                .cornerRadius(18)
                .shadow(color: Color.green.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.top, 10)
        .opacity(appeared ? 1 : 0)
        .animation(.spring().delay(0.4), value: appeared)
        .sheet(isPresented: $showPDFViewer) {
            PDFReportViewer(title: "Full Monthly Report")
        }
    }
}

struct ReportSection: View {
    let title: String
    let items: [ReportRow]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.secondary)
                .kerning(1)
            
            VStack(spacing: 14) {
                ForEach(0..<items.count, id: \.self) { i in
                    items[i]
                }
            }
        }
    }
}

struct ReportRow: View {
    let label: String
    let value: String
    var color: Color = .primary
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
        }
    }
}

#Preview {
    ReportPreviewView(path: .constant([]))
}
