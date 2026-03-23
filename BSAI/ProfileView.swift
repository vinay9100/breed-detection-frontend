import SwiftUI

struct ProfileView: View {
    @Binding var path: [AppRoute]
    @ObservedObject private var authManager = AuthManager.shared
    @ObservedObject private var localization = LocalizationManager.shared
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var appeared = false
    @State private var showDeleteConfirmation = false
    
    @State private var animalCount = 0
    @State private var scanCount = 0
    @State private var healthScore = 0.0
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    profileHeaderCard
                    
                    VStack(spacing: 12) {
                        ProfileMenuRow(icon: "square.and.pencil", iconColor: .blue, title: LocalizationManager.shared.t("profile_edit")) {
                            path.append(.editProfile)
                        }
                        ProfileMenuRow(icon: "gearshape.fill", iconColor: Color(red: 156/255, green: 39/255, blue: 176/255), title: LocalizationManager.shared.t("profile_settings")) {
                            path.append(.settings)
                        }
                        
                        ProfileMenuRow(icon: "bell.fill", iconColor: .orange, title: LocalizationManager.shared.t("profile_notifications")) {
                            path.append(.notifications)
                        }
                        ProfileMenuRow(icon: "questionmark.circle.fill", iconColor: Color(red: 0, green: 200/255, blue: 83/255), title: LocalizationManager.shared.t("profile_help")) {
                            path.append(.helpSupport)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    ProfileMenuRow(icon: "rectangle.portrait.and.arrow.right", iconColor: .red, title: LocalizationManager.shared.t("profile_logout")) {
                        AuthManager.shared.logout()
                        path.removeAll()
                    }
                    .padding(.horizontal, 20)
                    
                    ProfileMenuRow(icon: "trash.fill", iconColor: .red, title: LocalizationManager.shared.t("profile_delete")) {
                        showDeleteConfirmation = true
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 10)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .onAppear {
            loadProfileStats()
            withAnimation {
                appeared = true
            }
        }
        .alert(localization.t("common_delete_title"), isPresented: $showDeleteConfirmation) {
            Button(localization.t("common_delete_confirm"), role: .destructive) {
                AuthManager.shared.deleteAccount { result in
                    switch result {
                    case .success:
                        path.removeAll()
                    case .failure(let error):
                        print("Error deleting account: \(error.localizedDescription)")
                    }
                }
            }
            Button(localization.t("common_cancel"), role: .cancel) { }
        } message: {
            Text(localization.t("common_delete_message"))
        }
    }
    
    private func loadProfileStats() {
        isLoading = true
        let group = DispatchGroup()
        
        group.enter()
        AuthManager.shared.fetchAnalytics(timeFilter: "All") { result in
            if case .success(let data) = result {
                self.animalCount = data.total_animals
                self.healthScore = data.average_accuracy
            }
            group.leave()
        }
        
        group.enter()
        AuthManager.shared.fetchMyDetections { result in
            if case .success(let data) = result {
                self.scanCount = data.count
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.isLoading = false
        }
    }
    
    private var navigationBar: some View {
        HStack {
            Text(localization.t("profile_title"))
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 5)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 15)
        .background(Color.secondaryAppBackground)
    }
    
    private var profileHeaderCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                ZStack {
                    if let photoPath = AuthManager.shared.currentUser?.profilePhoto {
                        AsyncImage(url: URL(string: "http://127.0.0.1:8000/\(photoPath)")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } placeholder: {
                            Circle()
                                .fill(Color(red: 0, green: 200/255, blue: 83/255))
                                .frame(width: 80, height: 80)
                            ProgressView()
                        }
                    } else {
                        Circle()
                            .fill(Color(red: 0, green: 200/255, blue: 83/255))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(AuthManager.shared.currentUser?.fullName ?? "User")
                        .font(.system(size: 22, weight: .bold))
                    Text(AuthManager.shared.currentUser?.email ?? "user@email.com")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Text("\(localization.t("profile_member_since")) 2024")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary.opacity(0.8))
                }
                Spacer()
            }
            
            Divider().background(Color.gray.opacity(0.1))
            
            HStack(spacing: 0) {
                ProfileStatItem(value: "\(animalCount)", label: localization.t("profile_animals"))
                ProfileStatItem(value: "\(scanCount)", label: localization.t("profile_scans"))
                ProfileStatItem(value: (animalCount > 0 || scanCount > 0) ? "\(Int(healthScore))%" : "0%", label: localization.t("profile_health"))
            }
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(28)
        .shadow(color: Color.shadowColor, radius: 15, x: 0, y: 10)
        .padding(.horizontal, 20)
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.95)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)
    }
}

struct ProfileStatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProfileMenuRow: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    let icon: String
    let iconColor: Color
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundColor(.gray.opacity(0.3))
            }
            .padding(12)
            .background(Color.cardBackground)
            .cornerRadius(18)
            .shadow(color: Color.shadowColor, radius: 8, x: 0, y: 4)
        }
    }
}

#Preview {
    ProfileView(path: .constant([AppRoute]()))
}
