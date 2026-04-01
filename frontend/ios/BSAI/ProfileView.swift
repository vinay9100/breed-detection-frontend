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
    @State private var showAboutApp = false

    
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
                        ProfileMenuRow(
                            icon: "info.circle", // better standard icon
                            iconColor: Color(red: 0, green: 166/255, blue: 97/255),
                            title: LocalizationManager.shared.t("About App") // clearer key
                        ) {
                            showAboutApp = true
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
        .sheet(isPresented: $showAboutApp) {
            AboutAppView()
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
                        
                        // ✅ Use stable token from AuthManager to avoid flickering
                        let fullURL = (AuthManager.shared.baseURL.hasSuffix("/")
                            ? AuthManager.shared.baseURL + photoPath
                            : AuthManager.shared.baseURL + "/" + photoPath) + "?t=\(AuthManager.shared.profileImageToken)"
                        
                        if let url = URL(string: fullURL) {

                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 0, green: 200/255, blue: 83/255))
                                    ProgressView()
                                }
                            }
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())

                            
                        } else {
                            // ✅ Same fallback (unchanged)
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0, green: 200/255, blue: 83/255))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                            }
                        }
                        
                    } else {
                        // ✅ Same fallback (unchanged)
                        ZStack {
                            Circle()
                                .fill(Color(red: 0, green: 200/255, blue: 83/255))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(AuthManager.shared.currentUser?.fullName ?? "User")
                        .font(.system(size: 22, weight: .bold))
                    Text(AuthManager.shared.currentUser?.email ?? "user@email.com")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
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

// MARK: - About App View
struct AboutAppView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // Logo Header
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 60))
                                .foregroundColor(Color(hex: "00A661"))
                            
                            Text("BreedSureAI")
                                .font(.system(size: 28, weight: .bold))
                            
                            Text("Version 1.0.2")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.top, 30)
                    
                    // App Description
                    AboutSection(title: "About This App", icon: "info.circle.fill") {
                        Text("BreedSureAI is an AI-powered application developed as a final year academic project to assist in cattle breed identification and livestock data management. The app uses image-based analysis to provide breed insights and estimated productivity information to support farmers and livestock officers in decision-making.")
                    }
                    
                    // Features
                    AboutSection(title: "Key Features", icon: "star.fill") {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("• AI-based cattle breed identification")
                            Text("• Estimated milk yield insights")
                            Text("• Digital livestock record management")
                            Text("• Simple and user-friendly interface")
                        }
                    }
                    
                    // Safety & Disclaimer
                    AboutSection(title: "Safety & Disclaimer", icon: "shield.fill") {
                        VStack(alignment: .leading, spacing: 15) {
                            
                            SafetyPoint(
                                title: "For Informational Use Only",
                                detail: "The predictions provided by this app are for educational and informational purposes only and should not be considered as professional veterinary advice."
                            )
                            
                            SafetyPoint(
                                title: "Animal Safety",
                                detail: "Always maintain a safe distance while capturing images. Do not disturb or stress animals during usage."
                            )
                            
                            SafetyPoint(
                                title: "Accuracy Notice",
                                detail: "AI results may vary depending on image quality, lighting, and visibility. The app does not guarantee 100% accuracy."
                            )
                            
                            SafetyPoint(
                                title: "Data Privacy",
                                detail: "User data and livestock information are handled securely. No sensitive data is shared without user consent."
                            )
                        }
                    }
                    
                    // Footer
                    VStack(alignment: .center, spacing: 20) {
                        Divider()
                        
                        Text("Developed as an academic project")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("© 2026 BreedSureAI")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                }
                .padding(24)
            }
            .background(Color.appBackground)
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
struct AboutSection<Content: View>: View {
    let title: String
    let icon: String
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "00A661"))
                Text(title)
                    .font(.headline)
            }
            content()
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(18)
        .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
    }
}

struct SafetyPoint: View {
    let title: String
    let detail: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.primary)
            Text(detail)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ProfileView(path: .constant([AppRoute]()))
}
