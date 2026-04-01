import SwiftUI

struct SplashView: View {
    @Binding var isLaunched: Bool

    @State private var progress: Double = 0
    @State private var iconScale: CGFloat = 0.6
    @State private var iconOpacity: Double = 0
    @State private var showName: Bool = false
    @State private var ringRotation: Double = 0
    
    var body: some View {
        ZStack {
            // Premium background
            Color(hex: "00A661").ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Animated Logo Section
                ZStack {
                    // Outer rotating rings
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 4)
                        .frame(width: 140, height: 140)
                    
                    Circle()
                        .trim(from: 0, to: 0.25)
                        .stroke(Color.white, lineWidth: 4)
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(ringRotation))
                    
                    // Main Icon
                    ZStack {
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                    }
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)
                }
                
                // App Name with modern typography
                VStack(spacing: 10) {
                    Text("BreedSure AI")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(1.2)
                    
                    Text("PRECISION LIVESTOCK INTELLIGENCE")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white.opacity(0.7))
                        .tracking(3)
                }
                .offset(y: showName ? 0 : 20)
                .opacity(showName ? 1 : 0)
                
                Spacer()
                
                // 100% Loading Animation
                VStack(spacing: 15) {
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 200, height: 6)
                        
                        Capsule()
                            .fill(Color.white)
                            .frame(width: 200 * CGFloat(progress), height: 6)
                    }
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            // Initial Animations
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                iconScale = 1.0
                iconOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
                showName = true
            }
            
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                ringRotation = 360
            }
            
            // Progress Loading
            Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
                if progress < 1.0 {
                    progress += 0.01
                } else {
                    timer.invalidate()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isLaunched = true
                        }
                    }
                }
            }
        }
    }
}



#Preview {
    SplashView(isLaunched: .constant(false))
}

