import SwiftUI

struct ForgotPasswordView: View {
    @Binding var path: [AppRoute]

    @State private var identifier = ""
    @State private var appeared = false
    @State private var isSending = false
    @State private var showToast = false
    @State private var emailError = ""

    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(alignment: .leading, spacing: 30) {
                headerSection
                inputFieldBlock
                sendOTPButton
                Spacer()
            }
            .padding(.horizontal, 28)
            .padding(.top, 24)
            
            toastOverlay
        }
        .navigationTitle("Recovery")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            appeared = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { appeared = true }
        }
    }
    
    // MARK: - Subviews
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.green.opacity(0.10), Color(.systemBackground)],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "envelope.badge.shield.half.filled")
                .font(.system(size: 38))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green, .green.opacity(0.5)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(appeared ? 1 : 0.3)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.58).delay(0.05), value: appeared)

            Text("Recovery")
                .font(.system(size: 30, weight: .bold))
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.15), value: appeared)

            Text("Enter your registered email address\nto receive a verification code.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(4)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
                .animation(.easeOut(duration: 0.4).delay(0.22), value: appeared)
        }
    }
    
    private var inputFieldBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Email Address")
                .font(.subheadline.weight(.semibold))
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.3).delay(0.3), value: appeared)

            InputField(icon: "envelope.fill", placeholder: "e.g. farmer@gmail.com") {
                TextField("Email Address", text: $identifier)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.emailAddress)
            }
            .opacity(appeared ? 1 : 0)
            .offset(x: appeared ? 0 : -24)
            .animation(.spring(response: 0.55, dampingFraction: 0.7).delay(0.35), value: appeared)
            .onChange(of: identifier) { _, newValue in
                if !newValue.isEmpty && !newValue.lowercased().hasSuffix("@gmail.com") {
                    emailError = "Please use a valid @gmail.com address"
                } else {
                    emailError = ""
                }
            }

            if !emailError.isEmpty {
                Text(emailError)
                    .font(.system(size: 11))
                    .foregroundColor(.red)
                    .padding(.leading, 4)
            }
        }
    }
    
    private var sendOTPButton: some View {
        Button {
            guard !identifier.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            
            if !identifier.lowercased().hasSuffix("@gmail.com") {
                withAnimation { emailError = "Please use a valid @gmail.com address" }
                return
            }
            
            withAnimation { isSending = true }
            
            // Simulate API Call
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.spring()) { 
                    isSending = false
                    showToast = true
                }
                
                // Hide toast and navigate
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation { showToast = false }
                    path.append(.otpVerification(identifier: identifier))
                }
            }
        } label: {
            ZStack {
                if isSending {
                    ProgressView().tint(.white)
                } else {
                    Text("Send Reset Code")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(
                LinearGradient(
                    colors: [.green, Color(hex: "2E7D32")],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .green.opacity(0.38), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(PressScaleButtonStyle())
        .disabled(isSending)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.55, dampingFraction: 0.7).delay(0.44), value: appeared)
    }
    
    private var toastOverlay: some View {
        Group {
            if showToast {
                VStack {
                    Spacer()
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                        Text("OTP sent successfully")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 24)
                    .background(Color.green)
                    .clipShape(Capsule())
                    .shadow(radius: 10)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 40)
                }
                .zIndex(10)
            }
        }
    }
}

#Preview {
    struct Preview: View {
        @State var path: [AppRoute] = []
        var body: some View {
            NavigationStack(path: $path) {
                ForgotPasswordView(path: $path)
            }
        }
    }
    return Preview()
}
