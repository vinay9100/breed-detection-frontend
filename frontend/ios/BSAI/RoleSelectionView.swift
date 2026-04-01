import SwiftUI

struct RoleSelectionView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            // Background branding element
            VStack {
                HStack {
                    Spacer()
                    Circle()
                        .fill(LinearGradient(colors: [Color(hex: "00A661").opacity(0.06), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 300, height: 300)
                        .offset(x: 100, y: -50)
                }
                Spacer()
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                headerSection
                    .padding(.bottom, 60)
                
                roleButtonsSection
                
                Spacer()
                
                // Bottom help text
                HStack(spacing: 4) {
                    Text("Need help?")
                        .foregroundColor(.secondary)
                    Button("Support Center") {
                        path.append(.helpSupport)
                    }
                    .foregroundColor(.primary)
                    .fontWeight(.bold)
                }
                .font(.system(size: 14))
                .padding(.bottom, 20)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.7), value: appeared)
                
                Text("Version 2.1.0")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary.opacity(0.4))
                    .padding(.bottom, 10)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.03))
                    .frame(width: 130, height: 130)
                
                Circle()
                    .stroke(Color.accentColor.opacity(0.1), lineWidth: 1)
                    .frame(width: 110, height: 110)
                
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color.accentColor, Color(hex: "008D43")], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.accentColor.opacity(0.3), radius: 15, x: 0, y: 8)
                    
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 58, height: 58)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
            .scaleEffect(appeared ? 1 : 0.4)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.8, dampingFraction: 0.65).delay(0.1), value: appeared)

            VStack(spacing: 8) {
                Text("Select Access Mode")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Choose your gateway to the\nBreedSure AI Ecosystem")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: appeared)
        }
    }
    
    private var roleButtonsSection: some View {
        VStack(spacing: 24) {
            RoleCard(
                icon: "tractor.fill",
                title: "Farmer / Owner",
                subtitle: "Manage inventory, yields, and analytics",
                color: .accentColor,
                delay: 0.5
            ) {
                path.append(.login)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 40)
            .animation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.5), value: appeared)

            RoleCard(
                icon: "shield.checkered",
                title: "BPA Officer",
                subtitle: "Official registration and verifications",
                color: .blue,
                delay: 0.6
            ) {
                path.append(.login)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 40)
            .animation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.6), value: appeared)
        }
        .padding(.horizontal, 24)
    }
}

struct RoleCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let delay: Double
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                // Logo Composition
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(LinearGradient(colors: [color.opacity(0.15), color.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 72, height: 72)
                    
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(color.opacity(0.1), lineWidth: 1)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(color)
                        .shadow(color: color.opacity(0.2), radius: 5, x: 0, y: 3)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(color.opacity(0.3))
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Color.cardBackground)
                    .shadow(color: Color.black.opacity(0.03), radius: 20, x: 0, y: 15)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(Color.white, lineWidth: 1)
            )
        }
        .buttonStyle(EnhancedRoleButtonStyle())
    }
}

struct EnhancedRoleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .brightness(configuration.isPressed ? -0.02 : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}



#Preview {
    struct Preview: View {
        @State var path: [AppRoute] = []
        var body: some View {
            NavigationStack(path: $path) {
                RoleSelectionView(path: $path) 
            }
        }
    }
    return Preview()
}
