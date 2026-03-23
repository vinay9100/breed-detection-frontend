import SwiftUI

struct BPAResetPasswordView: View {
    @Binding var path: [AppRoute]
    var token: String
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var appeared = false
    @State private var showSuccess = false
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            if showSuccess {
                successOverlay
            } else {
                mainContent
            }
        }
        .onAppear {
            appeared = true
        }
    }
    
    private var successOverlay: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color(hex: "00C853").opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: "00C853"))
                    .scaleEffect(appeared ? 1 : 0.1)
            }
            
            VStack(spacing: 12) {
                Text("Success!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Your password has been updated\nsuccessfully. Redirecting to login...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                path = []
            }
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            navigationHeader
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    logoSection
                    
                    VStack(spacing: 8) {
                        Text("Reset Password")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        Text("Create a strong new password")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 20) {
                        passwordField(label: "New Password", placeholder: "Enter new password", text: $newPassword, showPassword: $showNewPassword)
                        passwordField(label: "Confirm Password", placeholder: "Confirm your password", text: $confirmPassword, showPassword: $showConfirmPassword)
                    }
                    
                    resetButton
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    private var navigationHeader: some View {
        HStack {
            Button(action: {
                if !path.isEmpty {
                    _ = path.removeLast()
                }
            }) {
                Image(systemName: "arrow.left")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding()
    }
    
    private var logoSection: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "00C853").opacity(0.1))
                .frame(width: 80, height: 80)
            
            Circle()
                .fill(LinearGradient(colors: [Color(hex: "00C853"), Color(hex: "00A843")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 60, height: 60)
            
            Image(systemName: "shield.checkered")
                .font(.system(size: 28))
                .foregroundColor(.white)
        }
        .scaleEffect(appeared ? 1 : 0.8)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)
    }
    
    private func passwordField(label: String, placeholder: String, text: Binding<String>, showPassword: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary.opacity(0.8))
            
            HStack(spacing: 12) {
                Image(systemName: "lock")
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                if showPassword.wrappedValue {
                    TextField(placeholder, text: text)
                        .font(.system(size: 16))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                } else {
                    SecureField(placeholder, text: text)
                        .font(.system(size: 16))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Button {
                    showPassword.wrappedValue.toggle()
                } label: {
                    Image(systemName: showPassword.wrappedValue ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private var resetButton: some View {
        Button(action: {
            guard newPassword == confirmPassword && !newPassword.isEmpty else { return }
            AuthManager.shared.resetPassword(token: token, newPassword: newPassword) { result in
                switch result {
                case .success(_):
                    withAnimation {
                        showSuccess = true
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }) {
            Text("Update Password")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color(hex: "008D43"))
                .cornerRadius(14)
                .shadow(color: Color(hex: "008D43").opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PressScaleButtonStyle())
        .padding(.top, 10)
    }
}

#Preview {
    BPAResetPasswordView(path: .constant([]), token: "preview-token")
}
