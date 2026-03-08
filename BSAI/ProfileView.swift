import SwiftUI

struct ProfileView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    profileHeaderCard
                    
                    VStack(spacing: 12) {
                        ProfileMenuRow(icon: "square.and.pencil", iconColor: .blue, title: "Edit Profile") {
                            path.append(.editProfile)
                        }
                        ProfileMenuRow(icon: "gearshape.fill", iconColor: Color(red: 156/255, green: 39/255, blue: 176/255), title: "Settings") {
                            path.append(.settings)
                        }
                        
                        ProfileMenuRow(icon: "bell.fill", iconColor: .orange, title: "Notifications") {
                            path.append(.notifications)
                        }
                        ProfileMenuRow(icon: "questionmark.circle.fill", iconColor: Color(red: 0, green: 200/255, blue: 83/255), title: "Help & Support") {
                            path.append(.helpSupport)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    ProfileMenuRow(icon: "rectangle.portrait.and.arrow.right", iconColor: .red, title: "Log Out") {
                        path.removeAll()
                    }
                    .padding(.horizontal, 20)
                    
                    ProfileMenuRow(icon: "trash.fill", iconColor: .red, title: "Delete Account") {
                        showDeleteConfirmation = true
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 10)
            }
        }
        .background(Color(red: 248/255, green: 251/255, blue: 249/255).ignoresSafeArea())
        .onAppear {
            appeared = true
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Account"),
                message: Text("Are you sure you want to delete your account? This action cannot be undone and will permanently erase all your data."),
                primaryButton: .destructive(Text("Delete")) {
                    AuthManager.shared.deleteAccount { result in
                        switch result {
                        case .success(_):
                            path.removeAll()
                        case .failure(let error):
                            print("Error deleting account: \(error.localizedDescription)")
                            // Optionally handle errors, e.g., show another alert
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private var navigationBar: some View {
        HStack {
            Text("Profile")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 5)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 15)
        .background(Color.white)
    }
    
    private var profileHeaderCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0, green: 200/255, blue: 83/255))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("User")
                        .font(.system(size: 22, weight: .bold))
                    Text("user@email.com")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Text("Member")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary.opacity(0.8))
                }
                Spacer()
            }
            
            Divider().background(Color.gray.opacity(0.1))
            
            HStack(spacing: 0) {
                ProfileStatItem(value: "0", label: "Animals")
                ProfileStatItem(value: "0", label: "Scans")
                ProfileStatItem(value: "0%", label: "Health")
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 10)
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
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProfileMenuRow: View {
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
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
        }
    }
}

#Preview {
    ProfileView(path: .constant([]))
}
