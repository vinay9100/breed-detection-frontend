import SwiftUI

struct RegisterView: View {
    @Binding var path: [AppRoute]
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var appeared = false
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var isRegistering = false
    @State private var emailError = ""

    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    logoHeader
                    fieldsBlock
                    registerButton
                    
                    loginLink
                        .padding(.top, 4)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 28)
            }
        }
        .onAppear {
            appeared = true
        }
    }
    
    // MARK: - Subviews
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.green.opacity(0.12), Color(.systemBackground)],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var logoHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.10))
                    .frame(width: 80, height: 80)
                Image(systemName: "person.badge.plus.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .green.opacity(0.5)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
            }
            .scaleEffect(appeared ? 1 : 0.3)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.58).delay(0.05), value: appeared)

            Text("Create Account")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
                .animation(.easeOut(duration: 0.4).delay(0.18), value: appeared)

            Text("Join the BreedSure AI community")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.24), value: appeared)
        }
        .padding(.top, 40)
    }
    
    private var fieldsBlock: some View {
        VStack(spacing: 14) {
            InputField(icon: "person.fill", placeholder: "Full Name") {
                TextField("Full Name", text: $fullName)
            }
            .opacity(appeared ? 1 : 0)
            .offset(x: appeared ? 0 : -20)
            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3), value: appeared)

            VStack(alignment: .leading, spacing: 6) {
                InputField(icon: "envelope.fill", placeholder: "Email address") {
                    TextField("Email address", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)
                }
                
                if !emailError.isEmpty {
                    Text(emailError)
                        .font(.system(size: 11))
                        .foregroundColor(.red)
                        .padding(.leading, 4)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.green)
                    Text("Only @gmail.com addresses are accepted for verification")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .padding(.leading, 4)
            }
            .opacity(appeared ? 1 : 0)
            .offset(x: appeared ? 0 : 20)
            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.35), value: appeared)
            .onChange(of: email) { _, newValue in
                if !newValue.isEmpty && !newValue.lowercased().hasSuffix("@gmail.com") {
                    emailError = "Please use a valid @gmail.com address"
                } else {
                    emailError = ""
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                InputField(icon: "lock.fill", placeholder: "Password") {
                    if showPassword {
                        TextField("Password", text: $password)
                            .textContentType(.newPassword)
                    } else {
                        SecureField("Password", text: $password)
                            .textContentType(.newPassword)
                    }
                } trailing: {
                    Button { showPassword.toggle() } label: {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.secondary)
                    }
                }
                
                if !password.isEmpty {
                    passwordStrengthBar
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(x: appeared ? 0 : -20)
            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.4), value: appeared)

            InputField(icon: "lock.shield.fill", placeholder: "Confirm Password") {
                if showConfirmPassword {
                    TextField("Confirm Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                } else {
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                }
            } trailing: {
                Button { showConfirmPassword.toggle() } label: {
                    Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.secondary)
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(x: appeared ? 0 : 20)
            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.45), value: appeared)
        }
    }
    
    private var passwordStrengthBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(passwordStrengthColor)
                        .frame(width: geo.size.width * passwordStrengthWidth)
                }
            }
            .frame(height: 4)
            
            Text(passwordStrengthText)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(passwordStrengthColor)
        }
        .padding(.horizontal, 4)
    }

    private var passwordStrengthWidth: CGFloat {
        if password.count < 4 { return 0.2 }
        if password.count < 8 { return 0.5 }
        if password.rangeOfCharacter(from: .punctuationCharacters) != nil { return 1.0 }
        return 0.8
    }

    private var passwordStrengthColor: Color {
        if password.count < 4 { return .red }
        if password.count < 8 { return .orange }
        if password.rangeOfCharacter(from: .punctuationCharacters) != nil { return .green }
        return .yellow
    }

    private var passwordStrengthText: String {
        if password.count < 4 { return "Weak" }
        if password.count < 8 { return "Fair" }
        if password.rangeOfCharacter(from: .punctuationCharacters) != nil { return "Strong" }
        return "Good"
    }
    
    private var registerButton: some View {
        Button {
            guard !isRegistering else { return }
            
            if !email.lowercased().hasSuffix("@gmail.com") {
                withAnimation { emailError = "Please use a valid @gmail.com address" }
                return
            }
            
            withAnimation { isRegistering = true }
            
            let req = RegisterRequest(
                email: email,
                password: password,
                full_name: fullName,
                phone_number: nil
            )
            
            AuthManager.shared.register(user: req) { result in
                withAnimation { isRegistering = false }
                
                switch result {
                case .success(_):
                    path.append(.otpVerification(identifier: email))
                case .failure(let error):
                    withAnimation { emailError = error.localizedDescription }
                }
            }
        } label: {
            ZStack {
                if isRegistering {
                    ProgressView().tint(.white)
                } else {
                    Text("Create Account")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(
                LinearGradient(
                    colors: [Color(hex: "00A661"), Color(hex: "008D43")],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color(hex: "00A661").opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(PressScaleButtonStyle())
        .disabled(isRegistering)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.55), value: appeared)
    }
    
    private var loginLink: some View {
        HStack {
            Text("Already have an account?")
                .foregroundColor(.secondary)
            Button {
                path.removeLast()
            } label: {
                Text("Sign In")
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "00A661"))
            }
        }
        .font(.subheadline)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.6), value: appeared)
    }
}

#Preview {
    RegisterView(path: .constant([]))
}
