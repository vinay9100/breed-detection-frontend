import SwiftUI

struct BPAOTPVerificationView: View {
    @Binding var path: [AppRoute]
    let identifier: String
    @State private var otpDigits = Array(repeating: "", count: 6)
    @FocusState private var focusedField: Int?
    @State private var timeRemaining = 30
    @State private var canResend = false
    @State private var appeared = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color(hex: "F8FBF9").ignoresSafeArea()
            
            VStack(spacing: 0) {
                navigationHeader
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        logoSection
                        
                        VStack(spacing: 8) {
                            Text("Verify Code")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color(hex: "1B5E20"))
                            Text("Enter the 6-digit code sent to")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(identifier)
                                .font(.subheadline.bold())
                                .foregroundColor(.primary)
                        }
                        
                        otpInputSection
                        
                        timerSection
                        
                        verifyButton
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .onAppear {
            appeared = true
            focusedField = 0
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
    
    private var otpInputSection: some View {
        HStack(spacing: 12) {
            ForEach(0..<6, id: \.self) { index in
                OTPDigitField(text: $otpDigits[index], isFocused: focusedField == index) { 
                    // Move forward
                    if index < 5 {
                        focusedField = index + 1
                    } else {
                        focusedField = nil
                    }
                } onBackspace: {
                    // Move backward
                    if index > 0 {
                        focusedField = index - 1
                    }
                }
                .focused($focusedField, equals: index)
            }
        }
    }
    
    private var timerSection: some View {
        VStack(spacing: 12) {
            if !canResend {
                Text("Resend code in \(timeRemaining)s")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            } else {
                Button(action: {
                    timeRemaining = 30
                    canResend = false
                }) {
                    Text("Resend Verification Code")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "00C853"))
                }
            }
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                canResend = true
            }
        }
    }
    
    private var verifyButton: some View {
        Button(action: {
            path.append(.bpaResetPassword)
        }) {
            Text("Verify & Continue")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color(hex: "008D43"))
                .cornerRadius(14)
                .shadow(color: Color(hex: "008D43").opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PressScaleButtonStyle())
        .padding(.top, 20)
    }
}

struct OTPDigitField: View {
    @Binding var text: String
    var isFocused: Bool
    let onDigitEntered: () -> Void
    let onBackspace: () -> Void
    
    var body: some View {
        TextField("", text: $text)
            .frame(width: 48, height: 60)
            .background(Color.white)
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(Color(hex: "00C853"))
            .cornerRadius(14)
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isFocused ? Color(hex: "00C853") : Color.gray.opacity(0.15), lineWidth: 2)
                    .shadow(color: isFocused ? Color(hex: "00C853").opacity(0.2) : Color.clear, radius: 8, x: 0, y: 0)
            )
            .onChange(of: text) { _, newValue in
                if newValue.count > 0 {
                    if newValue.count > 1 {
                        text = String(newValue.suffix(1))
                    }
                    onDigitEntered()
                } else {
                    onBackspace()
                }
            }
    }
}

#Preview {
    BPAOTPVerificationView(path: .constant([]), identifier: "officer@bpa.gov")
}
