import SwiftUI

struct ResetPasswordView: View {
    @Binding var path: [AppRoute]

    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var appeared = false
    @State private var isResetting = false
    @State private var showSuccessScreen = false
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false

    // Computed helpers
    var passwordsMatch: Bool { newPassword == confirmPassword && !newPassword.isEmpty }
    var isStrongEnough: Bool { newPassword.count >= 8 }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.green.opacity(0.12), Color(.systemBackground)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            if showSuccessScreen {
                successOverlay
            } else {
                mainContent
            }
        }
        .onAppear { appeared = true }
    }

    // MARK: - Subviews

    private var successOverlay: some View {
        SuccessOverlayView {
            // Redirect back to the unified login screen
            path.removeAll()
        }
        .transition(.move(edge: .trailing))
    }

    private var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                header
                newPasswordField
                confirmPasswordField
                resetButton
                Spacer()
            }
            .padding(.horizontal, 28)
            .padding(.top, 20)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("New Password")
                .font(.system(size: 30, weight: .bold))
            
            Text("Create a strong, unique password to secure your account.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring().delay(0.1), value: appeared)
    }

    private var newPasswordField: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Create Password")
                .font(.subheadline.weight(.semibold))

            InputField(icon: "lock.fill", placeholder: "Min. 8 characters") {
                Group {
                    if showNewPassword {
                        TextField("Min. 8 characters", text: $newPassword)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    } else {
                        SecureField("Min. 8 characters", text: $newPassword)
                    }
                }
            } trailing: {
                Button { showNewPassword.toggle() } label: {
                    Image(systemName: showNewPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.secondary)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(newPassword.isEmpty ? Color.clear : (isStrongEnough ? Color.green.opacity(0.5) : Color.orange.opacity(0.4)), lineWidth: 1.5)
            )

            // Strength bar
            if !newPassword.isEmpty {
                HStack(spacing: 5) {
                    ForEach(0..<4) { i in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(strengthBarColor(index: i))
                            .frame(height: 5)
                    }
                    Text(strengthLabel)
                        .font(.caption.bold())
                        .foregroundColor(strengthBarColor(index: 0))
                        .padding(.leading, 4)
                }
                .transition(.opacity)
            }
        }
        .opacity(appeared ? 1 : 0)
        .animation(.spring().delay(0.2), value: appeared)
    }

    private var confirmPasswordField: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Confirm Password")
                .font(.subheadline.weight(.semibold))

            InputField(icon: "lock.shield.fill", placeholder: "Re-enter password") {
                Group {
                    if showConfirmPassword {
                        TextField("Re-enter password", text: $confirmPassword)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    } else {
                        SecureField("Re-enter password", text: $confirmPassword)
                    }
                }
            } trailing: {
                Button { showConfirmPassword.toggle() } label: {
                    Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.secondary)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(!confirmPassword.isEmpty && !passwordsMatch ? Color.red.opacity(0.4) : Color.clear, lineWidth: 1.5)
            )
        }
        .opacity(appeared ? 1 : 0)
        .animation(.spring().delay(0.3), value: appeared)
    }

    private var resetButton: some View {
        Button {
            guard passwordsMatch && isStrongEnough else { return }
            withAnimation { isResetting = true }
            
            // Simulate Update
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.spring()) {
                    isResetting = false
                    showSuccessScreen = true
                }
            }
        } label: {
            ZStack {
                if isResetting {
                    ProgressView().tint(.white)
                } else {
                    Text("Update Password")
                        .font(.headline)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(
                LinearGradient(colors: [.green, Color(hex: "2E7D32")], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .green.opacity(0.35), radius: 12, y: 6)
        }
        .buttonStyle(PressScaleButtonStyle())
        .disabled(isResetting || !passwordsMatch || !isStrongEnough)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring().delay(0.4), value: appeared)
    }

    // MARK: - Helpers
    private var strengthLevel: Int {
        var score = 0
        if newPassword.count >= 8  { score += 1 }
        if newPassword.count >= 12 { score += 1 }
        if newPassword.contains(where: { $0.isNumber }) { score += 1 }
        if newPassword.contains(where: { !$0.isLetter && !$0.isNumber }) { score += 1 }
        return score
    }

    private var strengthLabel: String {
        switch strengthLevel {
        case 0, 1: return "Weak"
        case 2:    return "Fair"
        case 3:    return "Good"
        default:   return "Strong"
        }
    }

    private func strengthBarColor(index: Int) -> Color {
        guard index < strengthLevel else { return Color.gray.opacity(0.2) }
        switch strengthLevel {
        case 1:    return .red
        case 2:    return .orange
        case 3:    return .blue
        default:   return .green
        }
    }
}

// MARK: - Success UI
struct SuccessOverlayView: View {
    let onFinish: () -> Void
    @State private var iconScale = 0.0
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                    .scaleEffect(iconScale)
            }
            
            VStack(spacing: 12) {
                Text("Success!")
                    .font(.system(size: 32, weight: .bold))
                
                Text("Your password has been updated\nsuccessfully. Redirecting to login...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                iconScale = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                onFinish()
            }
        }
    }
}

#Preview {
    ResetPasswordView(path: .constant([]))
}
