import SwiftUI

struct BPAResetPasswordView: View {
    @Binding var path: [AppRoute]
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var appeared = false
    @State private var showSuccess = false
    
    var body: some View {
        ZStack {
            Color(hex: "F8FBF9").ignoresSafeArea()
            
            VStack(spacing: 0) {
                navigationHeader
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        logoSection
                        
                        VStack(spacing: 8) {
                            Text("Reset Password")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color(hex: "1B5E20"))
                            Text("Create a strong new password")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 20) {
                            passwordField(label: "New Password", placeholder: "Enter new password", text: $newPassword)
                            passwordField(label: "Confirm Password", placeholder: "Confirm your password", text: $confirmPassword)
                        }
                        
                        resetButton
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 24)
                }
            }
            
        }
        .onAppear {
            appeared = true
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
    
    private func passwordField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary.opacity(0.8))
            
            HStack(spacing: 12) {
                Image(systemName: "lock")
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                SecureField(placeholder, text: text)
                    .font(.system(size: 16))
                
                Image(systemName: "eye.slash")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private var resetButton: some View {
        Button(action: {
            // After reset, return to the start — unified login screen
            path.removeAll()
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
    BPAResetPasswordView(path: .constant([]))
}
