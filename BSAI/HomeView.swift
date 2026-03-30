import SwiftUI
import CoreLocation
import Combine

struct HomeView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    
    @ObservedObject var localization = LocalizationManager.shared
    
    // State for Dynamic Data
    @State private var analytics: AnalyticsSummaryResponse? = nil
    @State private var activities: [RecentActivity] = []
    @State private var vaccinations: [VaccinationRecord] = []
    @State private var alerts: [DiseaseAlert] = []
    @State private var isLoading = false
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                        if !alerts.isEmpty {
                            diseaseAlertsSection
                        }
                        
                        statsRow
                        
                        vaccinationRemindersSection
                        
                        recentActivitySection
                        
                        bottomActionsGrid
                    }
                    .padding(.top, 15)
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            loadAnalytics()
            fetchActivity()
            fetchVaccinations()
            fetchAlerts()
            withAnimation {
                appeared = true
            }
        }
        .onChange(of: locationManager.location) {
            fetchAlerts()
        }
    }
    
    private func loadAnalytics() {
        isLoading = true
        AuthManager.shared.fetchAnalytics(timeFilter: "All") { result in
            isLoading = false
            if case .success(let data) = result {
                self.analytics = data
            }
        }
    }
    
    private func fetchActivity() {
        AuthManager.shared.fetchRecentActivity { result in
            if case .success(let data) = result {
                self.activities = data
            }
        }
    }
    
    private func fetchVaccinations() {
        AuthManager.shared.fetchVaccinations { result in
            if case .success(let data) = result {
                self.vaccinations = data
            }
        }
    }
    
    private func fetchAlerts() {
        AuthManager.shared.fetchAlerts(
            lat: locationManager.location?.coordinate.latitude,
            lon: locationManager.location?.coordinate.longitude
        ) { result in
            if case .success(let data) = result {
                self.alerts = data
            }
        }
    }

    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                
                // 🔹 Left Greeting + Right Logout
                HStack {
                    let userName = AuthManager.shared.currentUser?.fullName.split(separator: " ").first.map(String.init) ?? localization.t("common_farmer")
                    let greetingKey = getGreetingKey()
                    
                    Text("\(localization.t(greetingKey)), \(userName) 👋")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Spacer()
                    
                    Button(action: {
                        AuthManager.shared.authToken = nil
                        path.removeAll()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 5)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : -20)
                .animation(.easeOut(duration: 0.6).delay(0.1), value: appeared)
                
                Text(localization.t("home_ready_to_scan"))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -20)
                    .animation(.easeOut(duration: 0.6).delay(0.15), value: appeared)
                
                scanAnimalCard
                    .padding(.horizontal, 24)
                    .scaleEffect(appeared ? 1 : 0.9)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.2), value: appeared)
            }
            .padding(.bottom, 25)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    Color(hex: "00A661")
                    
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 150, height: 150)
                        .offset(x: -100, y: -20)
                    
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 100, height: 100)
                        .offset(x: 160, y: 10)
                }
                .clipShape(RoundedCorner(radius: 30, corners: [.bottomLeft, .bottomRight]))
                .shadow(color: Color.primaryGreen.opacity(0.2), radius: 20, x: 0, y: 15)
                .ignoresSafeArea(edges: .top)
            )
        }
    }
    
    // MARK: - Scan Card
    
    private var scanAnimalCard: some View {
        Button(action: {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                path.append(.scanGuide)
            }
        }) {
            HStack(spacing: 18) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(hex: "00A661").opacity(0.08))
                        .frame(width: 68, height: 68)
                    
                    Image(systemName: "viewfinder")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.primaryGreen)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(localization.t("home_scan_animal"))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(localization.t("home_ai_detection"))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "00A661"), Color(hex: "008D43")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                .shadow(color: Color(hex: "00A661").opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.cardBackground)
                    .shadow(color: Color.shadowColor, radius: 25, x: 0, y: 12)
            )
        }
        .buttonStyle(EnhancedRoleButtonStyle())
    }

    private var diseaseAlertsSection: some View {
        VStack(spacing: 12) {
            ForEach(alerts) { alert in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.white)
                        Text(alert.disease_name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Text(alert.severity)
                            .font(.system(size: 12, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    
                    Text(alert.message)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12))
                        Text(alert.location)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
                .padding(20)
                .background(
                    LinearGradient(
                        colors: alert.severity == "High" ? [Color.red, Color(hex: "D32F2F")] : [Color.orange, Color(hex: "F57C00")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(24)
                .shadow(color: (alert.severity == "High" ? Color.red : Color.orange).opacity(0.3), radius: 10, x: 0, y: 5)
            }
        }
        .padding(.horizontal, 24)
    }

    private func getGreetingKey() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "home_greeting_morning" }
        else if hour < 17 { return "home_greeting_afternoon" }
        else { return "home_greeting_evening" }
    }

    private var vaccinationRemindersSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text(localization.t("home_vaccination_reminders"))
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                Button(action: { path.append(.vaccinationPlanner) }) {
                    Text(localization.t("home_see_all"))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "00A661"))
                }
            }
            .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
                let upcoming = vaccinations.filter { $0.status != "completed" }.prefix(2)
                
                if upcoming.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.green.opacity(0.5))
                        Text(localization.t("common_all_caught_up"))
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.cardBackground)
                    .cornerRadius(20)
                } else {
                    ForEach(upcoming) { vax in
                        VaccinationReminderRow(
                            title: vax.vaccine_name,
                            subtitle: vax.type ?? "Scheduled",
                            time: formatDate(vax.planned_date),
                            color: .orange
                        )
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private func formatDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var date = formatter.date(from: isoString)
        if date == nil {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: isoString)
        }
        
        guard let d = date else { return isoString }
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .short
        return displayFormatter.string(from: d)
    }
    
    // MARK: - Stats
    
    private var statsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                StatsCard(icon: "viewfinder", value: "\(analytics?.total_scans ?? 0)", label: localization.t("home_total_scans"), color: Color(hex: "00A661")) {
                    path.append(.scanHistory)
                }
                StatsCard(icon: "waveform.path", value: "\(Int(analytics?.average_accuracy ?? 0))%", label: localization.t("home_avg_confidence"), color: .blue) {
                    path.append(.analyticsHub)
                }
                StatsCard(icon: "chart.line.uptrend.xyaxis", value: "\(analytics?.total_animals ?? 0)", label: localization.t("home_herd_size"), color: .purple) {
                    path.append(.herdSummary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 5)
        }
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text(localization.t("home_recent_activity"))
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                Button(localization.t("home_see_all")) {
                    path.append(.scanHistory)
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "00A661"))
            }
            .padding(.horizontal, 24)
            
            if activities.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.badge.exclamationmark")
                        .font(.system(size: 30))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text(localization.t("home_no_activity"))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(Color.cardBackground)
                .cornerRadius(24)
                .padding(.horizontal, 24)
            } else {
                VStack(spacing: 12) {
                    ForEach(activities.prefix(3)) { activity in
                        HomeActivityRow(activity: activity)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
    private var bottomActionsGrid: some View {
        HStack(spacing: 16) {
            QuickActionSmallCard(icon: "waveform.path", title: localization.t("home_compare_breeds"), color: .blue) {
                path.append(.breedComparison(detectedBreed: nil))
            }
            
            QuickActionSmallCard(icon: "chart.line.uptrend.xyaxis", title: localization.t("home_predict_yield"), color: .purple) {
                path.append(.yieldPrediction)
            }
        }
        .padding(.horizontal, 24)
    }
}

struct VaccinationReminderRow: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    let title: String
    let subtitle: String
    let time: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "syringe.fill")
                    .foregroundColor(color)
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(time)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.shadowColor, radius: 5, x: 0, y: 2)
    }
}

struct HomeActivityRow: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    let activity: RecentActivity
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss"
        ]
        
        var date: Date?
        for format in formats {
            formatter.dateFormat = format
            if let d = formatter.date(from: activity.time) {
                date = d
                break
            }
        }
        
        if let date = date {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "hh:mm a"
            displayFormatter.timeZone = .current
            return displayFormatter.string(from: date)
        }
        
        return activity.time
    }
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(activity.type == "scan" ? Color.blue.opacity(0.1) : Color(hex: "00A661").opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: activity.type == "scan" ? "viewfinder" : "tag.fill")
                    .foregroundColor(activity.type == "scan" ? .blue : Color(hex: "00A661"))
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.system(size: 15, weight: .bold))
                Text(activity.subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(formattedTime)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.shadowColor, radius: 5, x: 0, y: 2)
    }
}

// MARK: - Quick Action Card

struct QuickActionSmallCard: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(color.opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 25)
            .background(Color.cardBackground)
            .cornerRadius(24)
            .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}


#Preview {
    HomeView(path: .constant([AppRoute]()))
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
    }
}
