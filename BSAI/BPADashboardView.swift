import SwiftUI

struct BPADashboardView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    @State private var selectedTab: String = "Overview"
    @Namespace private var animation // For tab sliding effect
    let dashboardTabs = ["Overview", "Actions", "Activity"]
    
    // State for Dynamic Data
    @State private var stats: BPAStats? = nil
    @State private var activities: [RecentActivity] = []
    @State private var analytics: AnalyticsSummaryResponse? = nil
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                dashboardHeader
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                            // Content starts straight after the header now
                        if selectedTab == "Overview" {
                            statsGrid
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 20)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appeared)
                                
                            registrationGrowthSection
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 20)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appeared)
                        } else if selectedTab == "Actions" {
                            quickActionsSection
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 20)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appeared)
                        } else if selectedTab == "Activity" {
                            recentActivitySection
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 20)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appeared)
                        }
                        
                    }
                    .padding(.top, 25) // Push content away from the green header safely
                    .padding(.bottom, 120) // Adds scroll safe area for the tab bar at the bottom
                }
            }
            
            // New iOS-Style Floating Bottom Navigation Bar
            VStack {
                Spacer()
                
                HStack(spacing: 0) {
                    bottomTabItem(title: "Overview", icon: "rectangle.grid.2x2.fill")
                    bottomTabItem(title: "Actions", icon: "plus.circle.fill")
                    bottomTabItem(title: "Activity", icon: "clock.fill")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.cardBackground)
                        .shadow(color: Color.shadowColor, radius: 15, x: 0, y: 5)
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 20) // Margin from standard safe area bottom edge
            }
        }
        .onAppear {
            loadStats()
            withAnimation {
                appeared = true
            }
        }
    }
    
    private func loadStats() {
        isLoading = true
        let group = DispatchGroup()
        
        group.enter()
        AuthManager.shared.fetchBPAStats { result in
            if case .success(let bpaStats) = result {
                self.stats = bpaStats
            }
            group.leave()
        }
        
        group.enter()
        AuthManager.shared.fetchRecentActivity { result in
            if case .success(let data) = result {
                self.activities = data
            }
            group.leave()
        }
        
        group.enter()
        AuthManager.shared.fetchAnalytics(timeFilter: "Week") { result in
            if case .success(let data) = result {
                self.analytics = data
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.isLoading = false
        }
    }
    
    // MARK: - Subviews
    
    private var dashboardHeader: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                // Top Row: Centered Greeting and Logout
                HStack(alignment: .top) {
                    
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
                        
                        Text("BPA Dashboard")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        AuthManager.shared.authToken = nil
                        path.removeAll()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
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
                    
                    // Decorative patterns
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
    
    private var statsGrid: some View {
        VStack(spacing: 16) {
            BPAStatCard(icon: "viewfinder", iconColor: .green, value: "\(stats?.total_scans ?? 0)", title: "Total Scans", trend: "All time detections", delay: 0.1, appeared: appeared) {
                path.append(.bpaReports)
            }
            .frame(maxWidth: .infinity)
            
            HStack(spacing: 16) {
                BPAStatCard(icon: "person.2.fill", iconColor: .blue, value: "\(stats?.total_owners ?? 0)", title: "Total Owners", trend: "Direct registration", delay: 0.2, appeared: appeared) {
                    path.append(.bpaAnalytics)
                }
                
                BPAStatCard(icon: "rays", iconColor: .purple, value: "\(stats?.ai_detections ?? 0)", title: "AI Detections Today", trend: "Global stats", delay: 0.3, appeared: appeared) {
                    path.append(.bpaReports)
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Quick Actions")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
                .padding(.horizontal, 24)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                BPAActionButton(icon: "plus", iconColor: Color(hex: "00C853"), title: "Register New Animal") {
                    path.append(.bpaAnimalRegistration)
                }
                BPAActionButton(icon: "magnifyingglass", iconColor: .blue, title: "Search Animal by ID") {
                    path.append(.bpaSearch)
                }
                BPAActionButton(icon: "doc.text.fill", iconColor: .purple, title: "View Reports") {
                    path.append(.bpaReports)
                }
                BPAActionButton(icon: "chart.bar.xaxis", iconColor: .orange, title: "Analytics") {
                    path.append(.bpaAnalytics)
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var registrationGrowthSection: some View {
        RegistrationGrowthChartView(rawData: analytics?.bar_chart ?? [])
            .padding(.horizontal, 24)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.55), value: appeared)
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Recent Activity")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
                .padding(.horizontal, 24)
            
            VStack(spacing: 1) {
                if activities.isEmpty {
                    Text("No recent activity")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(Array(activities.enumerated()), id: \.element.id) { index, activity in
                        ActivityRow(
                            title: activity.title,
                            subtitle: activity.subtitle,
                            time: activity.time,
                            isLast: index == activities.count - 1
                        )
                    }
                }
            }
            .background(Color.cardBackground)
            .cornerRadius(24)
            .shadow(color: Color.shadowColor, radius: 15, x: 0, y: 10)
            .padding(.horizontal, 24)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: appeared)
        }
        .padding(.top, 10)
    }
    
    // MARK: - Navigation Components
    private func bottomTabItem(title: String, icon: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedTab = title
            }
        } label: {
            // Selected Tab State
            if selectedTab == title {
                VStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                    Text(title)
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color(hex: "00C853"))
                        .shadow(color: Color(hex: "00C853").opacity(0.4), radius: 8, x: 0, y: 4)
                        .scaleEffect(1.05)
                )
            } else {
                // Unselected Tab State
                VStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                    Text(title)
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BPAStatCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let title: String
    let trend: String
    let delay: Double
    let appeared: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 15) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .font(.system(size: 20, weight: .bold))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text(title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                    Text(trend)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(iconColor == .orange ? .orange : (iconColor == .green || iconColor == .blue ? iconColor : .secondary))
                        .padding(.top, 2)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cardBackground)
            .cornerRadius(24)
            .shadow(color: Color.shadowColor, radius: 15, x: 0, y: 10)
        }
        .buttonStyle(EnhancedRoleButtonStyle()) // Uses the scaling/haptic style
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: appeared)
    }
}


struct BPAActionButton: View {
    let icon: String
    let iconColor: Color
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 56, height: 56)
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(iconColor)
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(Color.cardBackground)
            .cornerRadius(24)
            .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
        }
        .buttonStyle(EnhancedRoleButtonStyle())
    }
}

#Preview {
    BPADashboardView(path: .constant([]))
}

struct ActivityRow: View {
    let title: String
    let subtitle: String
    let time: String
    let isLast: Bool
    
    private var formattedTime: String {
        // Try parsing ISO8601 format from backend
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Backend sends UTC
        
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss"
        ]
        
        var date: Date?
        for format in formats {
            formatter.dateFormat = format
            if let d = formatter.date(from: time) {
                date = d
                break
            }
        }
        
        if let date = date {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "hh:mm a"
            displayFormatter.timeZone = .current // Convert to local time
            return displayFormatter.string(from: date)
        }
        
        return time // Fallback
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "00C853").opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: "clock.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "00C853"))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(formattedTime)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(20)
            
            if !isLast {
                Divider()
                    .padding(.leading, 76)
            }
        }
    }
}

