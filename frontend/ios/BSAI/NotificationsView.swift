import SwiftUI

struct NotificationsView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    
    @State private var notifications = [
        NotificationItem(icon: "calendar", iconColor: .blue, title: "Vaccination Due", message: "3 animals need vaccination this week", time: "2 hours ago", isUnread: true, route: .vaccinationPlanner),
        NotificationItem(icon: "exclamationmark.triangle.fill", iconColor: .orange, title: "Heat Stress Warning", message: "High temperatures expected tomorrow", time: "5 hours ago", isUnread: true, route: .climateSuitability),
        NotificationItem(icon: "checkmark.circle.fill", iconColor: .green, title: "Report Generated", message: "Your monthly report is ready", time: "1 day ago", isUnread: false, route: .bpaReports),
        NotificationItem(icon: "chart.line.uptrend.xyaxis", iconColor: .purple, title: "Yield Improvement", message: "Average yield increased by 5.3%", time: "2 days ago", isUnread: false, route: .performanceTrends)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 25) {
                    recentUpdatesHeader
                    
                    VStack(spacing: 12) {
                        ForEach(notifications) { item in
                            Button(action: {
                                // Mark as read and navigate
                                if let index = notifications.firstIndex(where: { $0.id == item.id }) {
                                    notifications[index].isUnread = false
                                }
                                if let route = item.route {
                                    path.append(route)
                                }
                            }) {
                                NotificationRow(item: item)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(notifications.firstIndex(where: { $0.id == item.id }) ?? 0) * 0.1 + 0.2), value: appeared)
                        }
                    }
                    
                    preferencesSection
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
                .padding(.horizontal, 24)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .onAppear {
            appeared = true
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
                    .background(Color.cardBackground)
                    .clipShape(Circle())
                    .shadow(color: Color.shadowColor, radius: 5, x: 0, y: 2)
            }
            
            Text("Notifications")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 10)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var recentUpdatesHeader: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Recent Updates")
                    .font(.system(size: 18, weight: .bold))
                Text("\(notifications.filter({$0.isUnread}).count) unread")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button("Mark all read") {
                withAnimation {
                    for i in 0..<notifications.count {
                        notifications[i].isUnread = false
                    }
                }
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.green)
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5), value: appeared)
    }
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Notification Preferences")
                .font(.system(size: 18, weight: .bold))
            
            VStack(spacing: 14) {
                PreferenceRow(title: "Health Alerts")
                PreferenceRow(title: "Vaccination Reminders")
                PreferenceRow(title: "Performance Updates")
                PreferenceRow(title: "Weather Warnings")
            }
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(28)
        .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: appeared)
    }
}

struct NotificationItem: Identifiable {
    let id = UUID()
    let icon: String
    let iconColor: Color
    let title: String
    let message: String
    let time: String
    var isUnread: Bool
    var route: AppRoute? = nil
}

struct NotificationRow: View {
    let item: NotificationItem
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(item.iconColor.opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: item.icon)
                    .font(.system(size: 18))
                    .foregroundColor(item.iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.title)
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                    if item.isUnread {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                    }
                }
                
                Text(item.message)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "bell")
                        .font(.system(size: 10))
                    Text(item.time)
                        .font(.system(size: 11))
                }
                .foregroundColor(.secondary.opacity(0.8))
                .padding(.top, 2)
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(22)
        .shadow(color: Color.shadowColor, radius: 8, x: 0, y: 4)
    }
}

struct PreferenceRow: View {
    let title: String
    @State private var isOn = true
    
    var body: some View {
        Toggle(title, isOn: $isOn)
            .font(.system(size: 15, weight: .medium))
            .tint(.green)
    }
}

#Preview {
    NotificationsView(path: .constant([]))
}
