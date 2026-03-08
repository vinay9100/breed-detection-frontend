import SwiftUI

struct BPARegistrationView: View {
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
            colors: [Color(hex: "1B5E20").opacity(0.12), Color(.systemBackground)],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var logoHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: "1B5E20").opacity(0.10))
                    .frame(width: 80, height: 80)
                Image(systemName: "shield.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "1B5E20"), Color(hex: "00C853")],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
            }
            .scaleEffect(appeared ? 1 : 0.3)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.58).delay(0.05), value: appeared)

            Text("BPA Officer Registration")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
                .animation(.easeOut(duration: 0.4).delay(0.18), value: appeared)

            Text("Join the BreedSure AI verification network")
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
            .offset(x: appeared ? 0 : 20)
            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3), value: appeared)

            VStack(alignment: .leading, spacing: 6) {
                InputField(icon: "envelope.fill", placeholder: "BPA Email address") {
                    TextField("BPA-XXXX@gmail.com", text: $email)
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
                        .foregroundColor(Color(hex: "00C853"))
                    Text("Secure verification required via OTP. Must start with BPA-")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .padding(.leading, 4)
            }
            .opacity(appeared ? 1 : 0)
            .offset(x: appeared ? 0 : -20)
            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.35), value: appeared)

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
            .offset(x: appeared ? 0 : 20)
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
            .offset(x: appeared ? 0 : -20)
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
            
            // Validate Input
            emailError = ""
            
            if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                withAnimation { emailError = "Email is required" }
                return
            }
            
            if !email.uppercased().hasPrefix("BPA-") {
                withAnimation { emailError = "Officer email must start with BPA-" }
                return
            }
            
            if password != confirmPassword {
                withAnimation { emailError = "Passwords do not match" }
                return
            }
            
            withAnimation { isRegistering = true }
            
            let req = BPARegisterRequest(
                email: email,
                password: password,
                full_name: fullName,
                phone_number: nil
            )
            
            AuthManager.shared.registerBPA(user: req) { result in
                withAnimation { isRegistering = false }
                
                switch result {
                case .success(_):
                    path.append(.bpaOTPVerification(identifier: req.email))
                case .failure(let error):
                    withAnimation { emailError = error.localizedDescription }
                }
            }
        } label: {
            ZStack {
                if isRegistering {
                    ProgressView().tint(.white)
                } else {
                    Text("Create BPA Account")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(
                LinearGradient(
                    colors: [Color(hex: "1B5E20"), Color(hex: "00C853")],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color(hex: "1B5E20").opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(PressScaleButtonStyle())
        .disabled(isRegistering)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.55), value: appeared)
    }
    
    private var loginLink: some View {
        HStack {
            Text("Already registered?")
                .foregroundColor(.secondary)
            Button {
                path.removeLast()
            } label: {
                Text("Sign In")
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "1B5E20"))
            }
        }
        .font(.subheadline)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.6), value: appeared)
    }
}

#Preview {
    BPARegistrationView(path: .constant([]))
}
