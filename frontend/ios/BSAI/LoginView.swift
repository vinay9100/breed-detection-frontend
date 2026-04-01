import SwiftUI

struct LoginView: View {
    @Binding var path: [AppRoute]

    @State private var loginId = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var isSigningIn = false
    @State private var appeared = false
    @State private var loginError = false
    @State private var emailError = ""
    @State private var emailAddressForLogin = ""

    private var isBPAOfficer: Bool {
        loginId.uppercased().hasPrefix("BPA-")
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: isBPAOfficer
                    ? [Color(hex: "1B5E20").opacity(0.12), Color(.systemBackground)]
                    : [Color.green.opacity(0.10), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: isBPAOfficer)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    logoHeader
                    roleIndicator
                    fieldsBlock
                    signInSection
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 28)
            }
        }
        .onAppear {
            appeared = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                appeared = true
            }
        }
    }

    // MARK: - VALIDATION
    
    private func validate() -> Bool {
        var isValid = true
        emailError = ""
        loginError = false
        
        let trimmedLogin = loginId.trimmingCharacters(in: .whitespacesAndNewlines)
        emailAddressForLogin = trimmedLogin
        
        if trimmedLogin.isEmpty {
            emailError = "Email address is required"
            isValid = false
        } else {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            if !emailPred.evaluate(with: trimmedLogin) {
                emailError = "Please enter a valid email address"
                isValid = false
            } else if isBPAOfficer && !trimmedLogin.uppercased().hasPrefix("BPA-") {
                emailError = "BPA email must start with BPA-"
                isValid = false
            }
        }
        
        if password.isEmpty {
            loginError = true
            isValid = false
        }
        
        return isValid
    }

    // MARK: - LOGO HEADER

    private var logoHeader: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isBPAOfficer
                                ? [Color(hex: "1B5E20").opacity(0.3), Color.cardBackground]
                                : [Color(hex: "00A661").opacity(0.3), Color.cardBackground],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 110, height: 110)
                    .shadow(color: .black.opacity(0.1), radius: 8)

                // 🔥 New Futuristic App Logo
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            }
            .scaleEffect(appeared ? 1 : 0.3)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.6), value: appeared)

            Text("Welcome Back")
                .font(.title.bold())
                .foregroundColor(.primary)

            Text("Sign in to BreedSure AI")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 30)
    }

    // MARK: - ROLE INDICATOR

    private var roleIndicator: some View {
        HStack(spacing: 6) {
            Image(systemName: isBPAOfficer ? "shield.fill" : "leaf.fill")
                .font(.system(size: 12, weight: .bold))
            Text(isBPAOfficer ? "BPA Officer Login" : "Farmer / Owner Login")
                .font(.system(size: 13, weight: .semibold))
        }
        .foregroundColor(isBPAOfficer ? Color(hex: "1B5E20") : Color(hex: "00A661"))
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill((isBPAOfficer ? Color(hex: "1B5E20") : Color.green).opacity(0.10))
        )
    }

    // MARK: - FIELDS

    private var fieldsBlock: some View {
        VStack(spacing: 14) {

            VStack(alignment: .leading, spacing: 4) {
                TextField(
                    isBPAOfficer ? "BPA Email (e.g. BPA-XXXX@gmail.com)" : "Email address",
                    text: $loginId
                )
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
                .onChange(of: loginId) { emailError = "" }

                if !emailError.isEmpty {
                    Text(emailError)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 8)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Group {
                        if showPassword {
                            TextField("Password", text: $password)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        } else {
                            SecureField("Password", text: $password)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                    }
                    
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
                .onChange(of: password) { loginError = false }

                if loginError {
                    Text("Password is required")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 8)
                }
            }
        }
    }

    // MARK: - SIGN IN

    private var signInSection: some View {
        VStack(spacing: 18) {
            Button {
                guard !isSigningIn else { return }
                guard validate() else { return }

                withAnimation { isSigningIn = true }

                let req = LoginRequest(email: emailAddressForLogin, password: password)
                
                AuthManager.shared.login(credentials: req) { result in
                    withAnimation { isSigningIn = false }
                    
                    switch result {
                    case .success(_):
                        if isBPAOfficer {
                            path.append(.bpaDashboard)
                        } else {
                            path.append(.dashboard)
                        }
                    case .failure(let error):
                        loginError = true
                        emailError = error.localizedDescription
                    }
                }
            } label: {
                ZStack {
                    if isSigningIn {
                        ProgressView().tint(.white)
                    } else {
                        Text(isBPAOfficer ? "Sign In as BPA Officer" : "Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: isBPAOfficer
                            ? [Color(hex: "1B5E20"), Color(hex: "00C853")]
                            : [Color(hex: "00A661"), Color(hex: "008D43")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.2), radius: 8)
            }
            
            HStack {
                Button {
                    path.append(isBPAOfficer ? .bpaForgotPassword : .forgotPassword)
                } label: {
                    Text("Forgot Password?")
                        .font(.footnote)
                        .foregroundColor(isBPAOfficer ? Color(hex: "1B5E20") : Color(hex: "00A661"))
                }
                
                Spacer()
                
                Button {
                    path.append(isBPAOfficer ? .bpaRegister : .register)
                } label: {
                    Text("Sign Up")
                        .font(.footnote)
                        .foregroundColor(isBPAOfficer ? Color(hex: "1B5E20") : Color(hex: "00A661"))
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 4)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var path: [AppRoute] = []
        var body: some View {
            NavigationStack(path: $path) {
                LoginView(path: $path)
            }
        }
    }
    return PreviewWrapper()
}
