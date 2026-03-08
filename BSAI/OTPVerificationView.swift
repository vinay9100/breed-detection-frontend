import SwiftUI

struct OTPVerificationView: View {
    @Binding var path: [AppRoute]
    let identifier: String

    @State private var otp: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedField: Int?
    
    @State private var timeRemaining = 60
    @State private var canResend = false
    @State private var appeared = false
    @State private var isValidating = false
    @State private var isSuccess = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.green.opacity(0.12), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 32) {

                // Back Button
                Button(action: { _ = path.removeLast() }) {
                    Image(systemName: "arrow.left")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                }
                .padding(.top, 10)

                // Header
                VStack(alignment: .leading, spacing: 14) {
                    Text("Verification Code")
                        .font(.system(size: 30, weight: .bold))

                    Text("We've sent a 6-digit code to")
                        .foregroundColor(.secondary)

                    Button {
                        if let url = URL(string: "googlegmail://") {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            } else {
                                // Fallback to generic mail
                                if let mailUrl = URL(string: "mailto:") {
                                    UIApplication.shared.open(mailUrl)
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(identifier)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            
                            Image(systemName: "envelope.fill")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.green.opacity(0.1))
                        .clipShape(Capsule())
                    }

                    Text("Touch the email above to verify in Gmail.\nEnter the code below.")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .lineSpacing(4)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring().delay(0.1), value: appeared)

                // OTP Boxes
                HStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { index in
                        TextField("", text: $otp[index])
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 24, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        focusedField == index ? Color.green : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                            .focused($focusedField, equals: index)
                            .onChange(of: otp[index]) { _, newValue in
                                if newValue.count > 1 {
                                    otp[index] = String(newValue.prefix(1))
                                }
                                if !newValue.isEmpty && index < 5 {
                                    focusedField = index + 1
                                }
                            }
                    }
                }
                .opacity(appeared ? 1 : 0)
                .animation(.spring().delay(0.2), value: appeared)


                // Verify Button
                Button(action: validateOTP) {
                    ZStack {
                        if isValidating {
                            ProgressView().tint(.white)
                        } else if isSuccess {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                        } else {
                            Text("Verify & Proceed")
                                .font(.headline)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        Group {
                            if isSuccess {
                                Color.green
                            } else {
                                LinearGradient(
                                    colors: [.green, Color(hex: "2E7D32")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            }
                        }
                    )                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .green.opacity(0.35), radius: 10, y: 5)
                }
                .buttonStyle(PressScaleButtonStyle())
                .disabled(isValidating || isSuccess)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring().delay(0.4), value: appeared)

                Spacer()
            }
            .padding(.horizontal, 28)
        }
        .onAppear {
            appeared = true
            focusedField = 0
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                canResend = true
            }
        }
    }

    private func validateOTP() {
        guard otp.allSatisfy({ !$0.isEmpty }) else { return }

        withAnimation {
            isValidating = true
        }

        let otpString = otp.joined()
        AuthManager.shared.verifyOTP(email: identifier, otp: otpString) { result in
            withAnimation(.spring()) {
                isValidating = false
            }
            
            switch result {
            case .success(_):
                withAnimation { isSuccess = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    path.removeAll(where: { 
                        if case .otpVerification = $0 { return true }
                        if case .register = $0 { return true }
                        return false 
                    }) // Go back to login after verification
                }
            case .failure(let error):
                print("OTP Error: \(error.localizedDescription)")
                // we can show error here
                withAnimation {
                    // Reset OTP fields on error
                    self.otp = Array(repeating: "", count: 6)
                    self.focusedField = 0
                }
            }
        }
    }
}
