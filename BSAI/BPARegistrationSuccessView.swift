import SwiftUI

struct BPARegistrationSuccessView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            // Background Elements (Abstract shapes for "premium" feel)
            Circle()
                .fill(Color(hex: "00C853").opacity(0.05))
                .frame(width: 400)
                .offset(x: 200, y: -300)
            
            Circle()
                .fill(Color(hex: "00C853").opacity(0.03))
                .frame(width: 300)
                .offset(x: -150, y: 400)
            
            VStack(spacing: 30) {
                Spacer()
                
                // Success Icon with layered animation
                ZStack {
                    Circle()
                        .fill(Color(hex: "00C853").opacity(0.1))
                        .frame(width: 140, height: 140)
                        .scaleEffect(appeared ? 1 : 0.8)
                    
                    Circle()
                        .stroke(Color(hex: "00C853").opacity(0.2), lineWidth: 2)
                        .frame(width: 110, height: 110)
                        .scaleEffect(appeared ? 1.1 : 0.9)
                    
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 70))
                        .foregroundColor(Color(hex: "00C853"))
                        .scaleEffect(iconScale)
                        .opacity(iconOpacity)
                }
                .padding(.bottom, 20)
                
                VStack(spacing: 12) {
                    Text("Registration Successful")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("The animal registration record for **ET-2024-8472** has been successfully added to the BPA Government Database.")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .lineSpacing(4)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                
                // Details Card
                VStack(spacing: 20) {
                    HStack {
                        DetailItem(label: "Registration ID", value: "#BPA-REC-9382")
                        Spacer()
                        DetailItem(label: "Status", value: "Verified", isStatus: true)
                    }
                    
                    Divider()
                    
                    HStack {
                        DetailItem(label: "Submitted By", value: AuthManager.shared.currentUser?.fullName ?? "BPA Officer")
                        Spacer()
                        DetailItem(label: "Timestamp", value: DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))
                    }
                }
                .padding(24)
                .background(Color.cardBackground)
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 10)
                .padding(.horizontal, 24)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                
                Spacer()
                
                // Bottom Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        path = [.bpaDashboard] // Correctly return to primary BPA dashboard
                    }) {
                        Text("Back to Dashboard")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color(hex: "00C853"))
                            .cornerRadius(14)
                            .shadow(color: Color(hex: "00C853").opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    Button(action: {
                        path = [.bpaDashboard, .bpaAnimalRegistration] // Go back to Registration (initial)
                    }) {
                        Text("Register Another Animal")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "00C853"))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                appeared = true
                iconScale = 1.0
                iconOpacity = 1.0
            }
        }
    }
}

struct DetailItem: View {
    let label: String
    let value: String
    var isStatus: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            if isStatus {
                Text(value)
                    .font(.system(size: 13, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "00C853").opacity(0.1))
                    .foregroundColor(Color(hex: "00C853"))
                    .cornerRadius(6)
            } else {
                Text(value)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
            }
        }
    }
}

#Preview {
    BPARegistrationSuccessView(path: .constant([]))
}
