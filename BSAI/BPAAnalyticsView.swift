import SwiftUI

struct BreedData: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
    let color: Color
}

struct BPAAnalyticsView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    @State private var selectedBreed: String? = nil
    @State private var selectedBarIndex: Int? = nil
    @State private var timeFilter = "Week"
    let timeFilters = ["Week", "15 Days", "30 Days", "Custom"]
    @State private var customStartDate = Date().addingTimeInterval(-86400 * 7)
    @State private var customEndDate = Date()
    @State private var showDatePickerSheet = false
    @State private var activeDateSelection: String = "start" // "start" or "end"
    
    // State for API Data
    @State private var analyticsData: AnalyticsSummaryResponse? = nil
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil
    
    // Mapping API PieChartData to SwiftUI BreedData struct
    var breedData: [BreedData] {
        guard let data = analyticsData?.pie_chart else { return [] }
        let colors: [Color] = [.green, .blue, .orange, .purple, .pink, .yellow, .cyan]
        return data.enumerated().map { index, apiData in
            BreedData(name: apiData.name, count: apiData.count, color: colors[index % colors.count])
        }
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                analyticsHeader
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        Picker("Time Range", selection: $timeFilter) {
                            ForEach(timeFilters, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 4)
                        .padding(.top, 10)
                        
                        if timeFilter == "Custom" {
                            HStack(spacing: 15) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Start Date").font(.system(size: 12, weight: .semibold)).foregroundColor(.secondary)
                                    Button(action: {
                                        activeDateSelection = "start"
                                        showDatePickerSheet = true
                                    }) {
                                        Text(formattedDate(customStartDate))
                                            .font(.system(size: 14))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color(.systemGray5))
                                            .cornerRadius(8)
                                            .foregroundColor(.primary)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("End Date").font(.system(size: 12, weight: .semibold)).foregroundColor(.secondary)
                                    Button(action: {
                                        activeDateSelection = "end"
                                        showDatePickerSheet = true
                                    }) {
                                        Text(formattedDate(customEndDate))
                                            .font(.system(size: 14))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color(.systemGray5))
                                            .cornerRadius(8)
                                            .foregroundColor(.primary)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }
                        
                        dailyRegistrationsCard
                        breedDistributionCard
                        aiDetectionsCard // Replaced AI Accuracy with simpler count
                        
                        analyticsSummaryCard
                        
                        Spacer(minLength: 40)
                    }
                    .padding(24)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: timeFilter)
                }
            }
        }
        .sheet(isPresented: $showDatePickerSheet) {
            NavigationView {
                VStack {
                    if activeDateSelection == "start" {
                        DatePicker("Select Start Date", selection: $customStartDate, in: ...Date(), displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                    } else {
                        DatePicker("Select End Date", selection: $customEndDate, in: ...Date(), displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                    }
                    Spacer()
                }
                .navigationBarTitle(activeDateSelection == "start" ? "Start Date" : "End Date", displayMode: .inline)
                .navigationBarItems(trailing: Button("Done") {
                    showDatePickerSheet = false
                })
            }
            .presentationDetents([.medium])
        }
        .onAppear {
            fetchData()
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
        .onChange(of: timeFilter) {
            fetchData()
        }
    }
    
    private func fetchData() {
        isLoading = true
        errorMessage = nil
        AuthManager.shared.fetchAnalytics(timeFilter: timeFilter) { result in
            self.isLoading = false
            switch result {
            case .success(let data):
                self.analyticsData = data
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Subviews
    
    private var analyticsHeader: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    Button(action: {
                        if !path.isEmpty {
                            _ = path.removeLast()
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        let officerName = AuthManager.shared.currentUser?.fullName.split(separator: " ").first.map(String.init) ?? "Officer"
                        let greeting = GreetingHelper.getGreeting(for: officerName)
                        
                        Text("\(greeting)👋")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        Text("Officer")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("BPA Analytics")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 5)
            }
            .padding(.bottom, 25)
            .background(
                ZStack {
                    LinearGradient(
                        colors: [Color(hex: "00C853"), Color(hex: "008D43")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    Circle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 150, height: 150)
                        .offset(x: -80, y: -20)
                    
                    Circle()
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 100, height: 100)
                        .offset(x: 120, y: 20)
                }
                .clipShape(RoundedCorner(radius: 30, corners: [.bottomLeft, .bottomRight]))
                .shadow(color: Color(hex: "00C853").opacity(0.2), radius: 20, x: 0, y: 15)
                .ignoresSafeArea(edges: .top)
            )
        }
    }
    
    private var dailyRegistrationsCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(Color(hex: "00C853"))
                Text(timeFilter == "Week" ? "Daily Registrations" : (timeFilter == "15 Days" ? "Daily Registrations" : (timeFilter == "30 Days" ? "Daily Registrations" : "Total Registrations")))
                    .font(.system(size: 18, weight: .bold))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(timeFilter == "Week" ? "Last 7 days" : (timeFilter == "15 Days" ? "Last 15 days" : (timeFilter == "30 Days" ? "Last 30 days" : "Since beginning")))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if let bars = analyticsData?.bar_chart, !bars.isEmpty {
                // Dynamic mapping of Bar Chart Data
                let dataCount = bars.count
                let maxValue = bars.map { CGFloat($0.value) }.max() ?? 1
                let maxHeight: CGFloat = 100 // Maximum height map for scale
                
                HStack(alignment: .bottom, spacing: dataCount > 15 ? 2 : (dataCount > 7 ? 6 : 18)) {
                    ForEach(0..<dataCount, id: \.self) { i in
                        let barValue = CGFloat(bars[i].value)
                        let barHeight = (barValue / maxValue) * maxHeight
                        
                        VStack(spacing: 8) {
                            if selectedBarIndex == i {
                                Text("\(Int(barValue))")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 4)
                                    .background(Color.black.opacity(0.8))
                                    .cornerRadius(4)
                                    .offset(y: -4)
                            } else {
                                Text(" ")
                                    .font(.system(size: 10))
                                    .padding(.vertical, 4)
                                    .opacity(0)
                            }
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(selectedBarIndex == i ? Color(hex: "00C853").opacity(0.8) : Color(hex: "00C853"))
                                .frame(width: dataCount > 15 ? 8 : (dataCount > 7 ? 14 : 28), height: max(barHeight, 5))
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        if selectedBarIndex == i {
                                            selectedBarIndex = nil
                                        } else {
                                            selectedBarIndex = i
                                        }
                                    }
                                }
                            
                            // Shortened Date Label under bar based on string "YYYY-MM-DD" -> "DD" or "MMM DD"
                            Text(String(bars[i].date.suffix(5))) // Just shows MM-DD
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                                .rotationEffect(.degrees(-45))
                                .padding(.top, 4)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
            } else {
                Text("No data available")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 10)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appeared)
    }
    
    private var breedDistributionCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                Text("Breed-wise Distribution")
                    .font(.system(size: 18, weight: .bold))
            }
            
            HStack {
                Text("Total Animals: \(analyticsData?.total_animals ?? 0)")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Spacer()
                Text(timeFilter)
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
            
            ZStack {
                // Background circle indicating 100% capacity
                Circle()
                    .fill(Color.gray.opacity(0.05))
                    .frame(width: 200, height: 200)
                
                // Solid Pie Segments
                let total = breedData.reduce(0) { $0 + $1.count }
                var currentAngle: Double = -90 // Start at top (12 o'clock)
                
                ForEach(breedData) { breed in
                    let fraction = Double(breed.count) / Double(total)
                    let degrees = fraction * 360.0
                    // Added a +0.5 degree overlap to endAngle to completely eliminate white rendering gaps
                    let endAngle = currentAngle + degrees + 0.5
                    
                    PieSlice(startAngle: .degrees(currentAngle), endAngle: .degrees(endAngle))
                        .fill(breed.color)
                        .scaleEffect(selectedBreed == breed.name ? 1.08 : 1.0)
                        .shadow(color: selectedBreed == breed.name ? breed.color.opacity(0.5) : .clear, radius: 10)
                        .zIndex(selectedBreed == breed.name ? 1 : 0) // Bring tapped slice to front
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                if selectedBreed == breed.name {
                                    selectedBreed = nil
                                } else {
                                    selectedBreed = breed.name
                                }
                            }
                        }
                    
                    let _ = { currentAngle = endAngle }()
                }
                
                // Central White Cutout to make it a thick ring, or keep it solid? The user specifically asked for "solid pie chart... should be fully circle", so we do NOT add a center cutout. It is a true pie chart.
                
                // Tooltip Overlay on tap
                if let selectedName = selectedBreed, let selectedObj = breedData.first(where: { $0.name == selectedName }) {
                     VStack(spacing: 4) {
                         Text(selectedObj.name)
                             .font(.system(size: 14, weight: .bold))
                             .multilineTextAlignment(.center)
                             .foregroundColor(.white)
                         Text("\(selectedObj.count) cows")
                             .font(.system(size: 12, weight: .medium))
                             .foregroundColor(.white.opacity(0.9))
                         Text("\(String(format: "%.1f", (Double(selectedObj.count) / Double(total)) * 100))%")
                             .font(.system(size: 16, weight: .black))
                             .foregroundColor(.white)
                     }
                     .padding(12)
                     .background(Color.black.opacity(0.75))
                     .cornerRadius(12)
                     .shadow(radius: 10)
                     .transition(.scale.combined(with: .opacity))
                     .id(selectedName)
                     .zIndex(2) // Above the pie
                }
            }
            .frame(width: 220, height: 220)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(breedData) { breed in
                    DistributionItem(label: breed.name, color: breed.color, value: "\(breed.count)")
                }
            }
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 10)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appeared)
    }

    private var aiDetectionsCard: some View {
        VStack(spacing: 25) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.purple)
                Text("AI Activity")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
            }
            
            VStack(spacing: 12) {
                Text("\(analyticsData?.total_animals ?? 0)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.purple)
                Text("Total processed as of today")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 10)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: appeared)
    }


    private var analyticsSummaryCard: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.title3)
                .foregroundColor(Color(hex: "00C853"))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Analytics Summary")
                    .font(.system(size: 15, weight: .bold))
                Text("All data is updated in real-time and\nreflects the current status of the BPA\nregistration system.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "00C853").opacity(0.05))
        .cornerRadius(24)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: appeared)
    }
    
    // MARK: - Helpers
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date)
    }
    
    private func donutSegment(start: Double, end: Double, color: Color) -> some View {
        Circle()
            .trim(from: start, to: end)
            .stroke(color, lineWidth: 35)
            .rotationEffect(.degrees(-90))
    }
}

struct DistributionItem: View {
    let label: String
    let color: Color
    let value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .bold))
        }
    }
}

struct StatusRow: View {
    let label: String
    let value: String
    let total: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(label)
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Text(value)
                    .font(.system(size: 14, weight: .bold))
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.1))
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * (Double(value) ?? 0) / (Double(total) ?? 1))
                }
            }
            .frame(height: 8)
            
            Text("\(String(format: "%.1f", (Double(value) ?? 0) / (Double(total) ?? 1) * 100))% of total")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }
}

struct AccuracyTag: View {
    let label: String
    let sublabel: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)
            Text(sublabel)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.05))
        .cornerRadius(12)
    }
}

struct LegendItem: View {
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }
}


// Custom Shape for solid Pie Chart Slices
struct PieSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    BPAAnalyticsView(path: .constant([]))
}
