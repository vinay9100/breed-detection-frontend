import SwiftUI

struct HomeView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    
    // State for Dynamic Data
    @State private var analytics: AnalyticsSummaryResponse? = nil
    @State private var activities: [RecentActivity] = []
    @State private var isLoading = false

    var body: some View {
        ZStack {
            Color(hex: "F9FBF9").ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                        statsRow
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: appeared)
                        
                        recentActivitySection
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: appeared)
                        
                        bottomActionsGrid
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: appeared)
                    }
                    .padding(.top, 15)
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            loadAnalytics()
            fetchActivity()
            withAnimation {
                appeared = true
            }
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
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                
                // 🔹 Left Greeting + Right Logout
                HStack {
                    let userName = AuthManager.shared.currentUser?.fullName.split(separator: " ").first.map(String.init) ?? "Farmer"
                    let greetingText = GreetingHelper.getGreeting(for: userName)
                    
                    Text("\(greetingText) 👋")
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
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 5)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : -20)
                .animation(.easeOut(duration: 0.6).delay(0.1), value: appeared)
                
                Text("Ready to scan your livestock?")
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
                .shadow(color: Color(hex: "00A661").opacity(0.15), radius: 20, x: 0, y: 15)
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
                        .foregroundColor(Color(hex: "00A661"))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Scan Animal")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("AI-powered breed detection")
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
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 25, x: 0, y: 12)
            )
        }
        .buttonStyle(EnhancedRoleButtonStyle())
    }
    
    // MARK: - Stats
    
    private var statsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                StatsCard(icon: "viewfinder", value: "\(analytics?.total_animals ?? 0)", label: "Total Scans", color: Color(hex: "00A661")) {
                    path.append(.scanHistory)
                }
                StatsCard(icon: "waveform.path", value: "\(Int(analytics?.average_accuracy ?? 0))%", label: "Avg. Confidence", color: .blue) {
                    path.append(.analyticsHub)
                }
                StatsCard(icon: "chart.line.uptrend.xyaxis", value: "\(analytics?.total_animals ?? 0)", label: "Herd Size", color: .purple) {
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
                Text("Recent Activity")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                Button("See All") {
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
                    Text("No recent activity found")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(Color.white)
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
            QuickActionSmallCard(icon: "waveform.path", title: "Compare Breeds", color: .blue) {
                path.append(.breedComparison)
            }
            
            QuickActionSmallCard(icon: "chart.line.uptrend.xyaxis", title: "Predict Yield", color: .purple) {
                path.append(.yieldPrediction)
            }
        }
        .padding(.horizontal, 24)
    }
}

struct HomeActivityRow: View {
    let activity: RecentActivity
    
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
            
            Text(activity.time)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Quick Action Card

struct QuickActionSmallCard: View {
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
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Greeting Helper

struct GreetingHelper {
    static func getGreeting(for name: String) -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        if hour < 12 {
            return "Good Morning, \(name)"
        } else if hour < 17 {
            return "Good Afternoon, \(name)"
        } else {
            return "Good Evening, \(name)"
        }
    }
}

#Preview {
    HomeView(path: .constant([]))
}
