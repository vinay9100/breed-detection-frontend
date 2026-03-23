import SwiftUI

struct BPAForgotPasswordView: View {
    @Binding var path: [AppRoute]
    @State private var email = ""
    @State private var appeared = false
    @State private var isSending = false
    @State private var emailError = ""
    @State private var showToast = false
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                navigationHeader
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        logoSection
                        
                        VStack(spacing: 8) {
                            Text("Forgot Password")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Enter your email to reset your password")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        inputField(label: "Official Email Address", icon: "envelope", placeholder: "officer@bpa.gov", text: $email)
                        
                        Text("We'll send a verification code to this email address\nRemember to prefix with BPA- (e.g. BPA-officer@gmail.com)")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                        if !emailError.isEmpty {
                            Text(emailError)
                                .font(.system(size: 11))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        sendButton
                        
                        loginLink
                        
                        infoCard
                        
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
    
    private func inputField(label: String, icon: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary.opacity(0.8))
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                TextField(placeholder, text: text)
                    .font(.system(size: 16))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
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
    
    private var sendButton: some View {
        Button(action: {
            guard !email.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            
            withAnimation {
                isSending = true
                emailError = ""
            }
            
            AuthManager.shared.bpaForgotPassword(email: email) { result in
                withAnimation { isSending = false }
                switch result {
                case .success(_):
                    path.append(.bpaOTPVerification(identifier: email, isPasswordReset: true))
                case .failure(let error):
                    withAnimation { emailError = error.localizedDescription }
                }
            }
        }) {
            HStack(spacing: 10) {
                if isSending {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "paperplane.fill")
                    Text("Send Reset Code")
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color(hex: "008D43"))
            .cornerRadius(14)
            .shadow(color: Color(hex: "008D43").opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PressScaleButtonStyle())
        .disabled(isSending)
    }
    
    private var loginLink: some View {
        HStack(spacing: 4) {
            Text("Remember your password?")
                .foregroundColor(.secondary)
            Button(action: {
                if !path.isEmpty {
                    _ = path.removeLast()
                }
            }) {
                Text("Sign In")
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "00C853"))
            }
        }
        .font(.system(size: 14))
    }
    
    private var infoCard: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: "envelope.fill")
                .foregroundColor(Color(hex: "00C853"))
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Password Reset Process")
                    .font(.system(size: 14, weight: .bold))
                Text("A 6-digit verification code will be sent to your\nregistered email. Use it to create a new\npassword.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "00C853").opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "00C853").opacity(0.15), lineWidth: 1)
        )
        .padding(.top, 40)
    }
}

#Preview {
    BPAForgotPasswordView(path: .constant([]))
}
