import SwiftUI

struct NotificationsView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    
    let notifications = [
        NotificationItem(icon: "calendar", iconColor: .blue, title: "Vaccination Due", message: "3 animals need vaccination this week", time: "2 hours ago", isUnread: true),
        NotificationItem(icon: "exclamationmark.triangle.fill", iconColor: .orange, title: "Heat Stress Warning", message: "High temperatures expected tomorrow", time: "5 hours ago", isUnread: true),
        NotificationItem(icon: "checkmark.circle.fill", iconColor: .green, title: "Report Generated", message: "Your monthly report is ready", time: "1 day ago", isUnread: false),
        NotificationItem(icon: "chart.line.uptrend.xyaxis", iconColor: .purple, title: "Yield Improvement", message: "Average yield increased by 5.3%", time: "2 days ago", isUnread: false)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 25) {
                    recentUpdatesHeader
                    
                    VStack(spacing: 12) {
                        ForEach(Array(notifications.enumerated()), id: \.offset) { index, item in
                            NotificationRow(item: item)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 20)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.1 + 0.2), value: appeared)
                        }
                    }
                    
                    preferencesSection
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
                .padding(.horizontal, 24)
            }
        }
        .background(Color(hex: "F8FBF9").ignoresSafeArea())
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
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
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
                Text("2 unread")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button("Mark all read") {
                // Action
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
        .background(Color.white)
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: appeared)
    }
}

struct NotificationItem {
    let icon: String
    let iconColor: Color
    let title: String
    let message: String
    let time: String
    let isUnread: Bool
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
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
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
