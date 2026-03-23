import SwiftUI

struct BPAReportsView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showPDFViewer = false
    
    // State for Dynamic Data
    @State private var animals: [AnimalRegistrationData] = []
    @State private var breedStats: [APIPieChartData] = []
    @State private var totalAnimalsCount: Int = 0
    @State private var isLoading = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                reportsHeader

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        mainReportCard
                        registrationSummaryTable
                        breedStatisticsTable
                        verificationReportPreview
                        downloadSection
                        autoRefreshNote

                        Spacer(minLength: 40)
                    }
                    .padding(24)
                }
            }
            if isLoading && animals.isEmpty {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
        .onAppear {
            loadData()
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func loadData() {
        isLoading = true
        AuthManager.shared.fetchAnimals { result in
            if case .success(let fetchedAnimals) = result {
                self.animals = fetchedAnimals
            }
            
            // Also fetch analytics for breed stats
            AuthManager.shared.fetchAnalytics(timeFilter: "All") { result in
                isLoading = false
                if case .success(let analytics) = result {
                    self.breedStats = analytics.pie_chart
                    self.totalAnimalsCount = analytics.total_animals
                }
            }
        }
    }

    // MARK: - Header
    
    private var reportsHeader: some View {
        VStack(spacing: 15) {
            HStack(spacing: 20) {
                Button(action: {
                    if !path.isEmpty {
                        _ = path.removeLast()
                    }
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("BPA Reports")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Text("Export and share comprehensive reports")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 25)
        }
        .background(
            LinearGradient(
                colors: [Color(hex: "00C853"), Color(hex: "008D43")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }

    // MARK: - Main Report Card

    private var mainReportCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    let dateStr = DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .none)
                    Text("Real-time Status Report")
                        .font(.system(size: 18, weight: .bold))

                    Text("Generated on \(dateStr)")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }

                Spacer()

                HStack(spacing: 12) {
                    IconButton(icon: "arrow.clockwise") {
                        loadData()
                    }
                }
            }
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.shadowColor, radius: 15, x: 0, y: 10)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appeared)
    }

    // MARK: - Registration Summary

    private var registrationSummaryTable: some View {
        TableCard(title: "Animal Registration Summary", icon: "doc.text.fill") {
            VStack(spacing: 0) {
                TableHeader(columns: ["Ear Tag", "Breed", "Owner"])

                if animals.isEmpty {
                    Text("No records found")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(Array(animals.prefix(5).enumerated()), id: \.element.ear_tag_number) { index, animal in
                        InteractiveTableRow(
                            path: $path,
                            data: [animal.ear_tag_number, animal.breed, animal.owner_name],
                            isLast: index == min(animals.count, 5) - 1,
                            navigateTo: .bpaAnimalDetail(data: animal)
                        )
                    }
                }
            }

            Text("Showing \(min(animals.count, 5)) of \(totalAnimalsCount) total registrations")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .padding(.top, 15)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appeared)
    }

    // MARK: - Breed Statistics

    private var breedStatisticsTable: some View {
        TableCard(title: "Breed Statistics", icon: "chart.pie.fill", titleColor: .purple) {
            VStack(spacing: 0) {
                TableHeader(columns: ["Breed", "Count", "%"], color: .purple)

                if breedStats.isEmpty {
                    Text("Gathering data...")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(Array(breedStats.enumerated()), id: \.element.name) { index, stat in
                        let percentage = totalAnimalsCount > 0 ? (Double(stat.count) / Double(totalAnimalsCount) * 100) : 0
                        TableRow(
                            data: [stat.name, "\(stat.count)", String(format: "%.1f%%", percentage)],
                            isLast: index == breedStats.count - 1
                        )
                    }
                }
            }
            .padding(.bottom, 10)

            Divider()

            HStack {
                Text("Total: \(totalAnimalsCount) animals")
                    .font(.system(size: 12, weight: .bold))

                Spacer()

                Text("\(totalAnimalsCount) verified (100%)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "00C853"))
            }
            .padding(.top, 10)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: appeared)
    }

    // MARK: - Verification Preview

    private var verificationReportPreview: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "doc.badge.checkmark.fill")
                    .foregroundColor(.orange)

                Text("Verification Report Preview")
                    .font(.system(size: 18, weight: .bold))
            }

            HStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Verified")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)

                    Text("\(totalAnimalsCount)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "00C853"))

                    Text("100% completion")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "00C853"))
                }
                .padding(15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "00C853").opacity(0.05))
                .cornerRadius(16)
            }
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.shadowColor, radius: 15, x: 0, y: 10)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(Animation.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: appeared)
    }

    // MARK: - Download Section

    private var downloadSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color(hex: "00C853").opacity(0.1))
                    .frame(width: 50, height: 50)

                Image(systemName: "arrow.down.to.line")
                    .font(.title2)
                    .foregroundColor(Color(hex: "00C853"))
            }

            VStack(spacing: 8) {
                Text("Download Complete Report")
                    .font(.system(size: 16, weight: .bold))

                Text("Export the complete report in PDF or\nExcel format with all detailed analytics and\ntables.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 15) {
                Button(action: {
                    showPDFViewer = true
                }) {
                    Text("Preview & Download")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(hex: "008D43"))
                        .cornerRadius(12)
                }

                Button(action: {
                    alertTitle = "Excel Download"
                    alertMessage = "Your excel report is being generated and will be saved to your files shortly."
                    showAlert = true
                }) {
                    Text("Download Excel")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "00C853"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "00C853").opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
        .padding(30)
        .background(Color(hex: "00C853").opacity(0.05))
        .cornerRadius(24)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(Animation.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: appeared)
        .sheet(isPresented: $showPDFViewer) {
            PDFReportViewer(title: "Comprehensive BPA Report")
        }
    }

    // MARK: - Auto Refresh

    private var autoRefreshNote: some View {
        HStack {
            Image(systemName: "chart.bar.fill")
                .foregroundColor(.blue)

            Text("Reports are automatically generated and\nupdated in real-time")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.blue.opacity(0.8))

            Spacer()
        }
        .padding(15)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(Animation.spring(response: 0.6, dampingFraction: 0.8).delay(0.7), value: appeared)
    }
}

// MARK: - Helper Components

struct IconButton: View {
    var icon: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.black)
                .frame(width: 40, height: 40)
                .background(Color.gray.opacity(0.1))
                .clipShape(Circle())
        }
    }
}

struct ReportActionButton: View {
    var title: String
    var icon: String?
    var isSpecial: Bool = false
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                }
                Text(title)
                    .font(.system(size: 13, weight: .bold))
            }
            .foregroundColor(isSpecial ? .white : .black)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSpecial ? Color(hex: "00C853") : Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

struct TableCard<Content: View>: View {
    var title: String
    var icon: String
    var titleColor: Color = .primary
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(titleColor.opacity(0.1))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .foregroundColor(titleColor)
                        .font(.system(size: 14))
                }
                Text(title)
                    .font(.system(size: 16, weight: .bold))
            }
            content()
        }
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.shadowColor, radius: 15, x: 0, y: 10)
    }
}

struct TableHeader: View {
    var columns: [String]
    var color: Color = .gray
    
    var body: some View {
        HStack {
            ForEach(0..<columns.count, id: \.self) { index in
                Text(columns[index])
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity, alignment: index == 0 ? .leading : (index == columns.count - 1 ? .trailing : .center))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 10)
        .background(color.opacity(0.05))
        .cornerRadius(8)
        .padding(.bottom, 5)
    }
}

struct InteractiveTableRow: View {
    @Binding var path: [AppRoute]
    var data: [String]
    var isLast: Bool = false
    var navigateTo: AppRoute
    
    var body: some View {
        Button(action: {
            path.append(navigateTo)
        }) {
            TableRow(data: data, isLast: isLast)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TableRow: View {
    var data: [String]
    var isLast: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(0..<data.count, id: \.self) { index in
                    Text(data[index])
                        .font(.system(size: 13))
                        .foregroundColor(index == 0 ? .blue : .primary)
                        .lineLimit(index == 0 ? 1 : 2)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity, alignment: index == 0 ? .leading : (index == data.count - 1 ? .trailing : .center))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 10)
            
            if !isLast {
                Divider()
                    .padding(.horizontal, 10)
            }
        }
    }
}

struct BreakdownRow: View {
    var label: String
    var value: String
    var color: Color = .black
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(color)
        }
    }
}
