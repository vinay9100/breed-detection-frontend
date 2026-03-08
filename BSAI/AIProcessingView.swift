import SwiftUI

struct AIProcessingView: View {
    @Binding var path: [AppRoute]
    @State private var progress: CGFloat = 0.0
    @State private var currentStep = 0
    @State private var appeared = false
    
    let steps = [
        "Analyzing image quality...",
        "Detecting key features...",
        "Comparing breed patterns...",
        "Calculating confidence score..."
    ]
    
    @State private var rotation: Double = 0
    @State private var innerRotation: Double = 0
    
    var body: some View {
        ZStack {
            // Premium Dark/Green Duo Background
            ZStack {
                Color(hex: "0A1A0F").ignoresSafeArea()
                
                // Animated glow
                RadialGradient(colors: [Color.green.opacity(0.15), .clear], center: .center, startRadius: 0, endRadius: 400)
                    .scaleEffect(appeared ? 1.5 : 0.8)
                    .opacity(appeared ? 1 : 0)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // 1. Advanced Animated Scanner
                ZStack {
                    // Outer Ring
                    Circle()
                        .stroke(Color.green.opacity(0.1), lineWidth: 4)
                        .frame(width: 220, height: 220)
                    
                    // Rotating Gradient Ring
                    Circle()
                        .trim(from: 0, to: 0.3)
                        .stroke(
                            LinearGradient(colors: [.green, .clear], startPoint: .top, endPoint: .bottom),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 220, height: 220)
                        .rotationEffect(.degrees(rotation))
                    
                    // Inner Pulse
                    Circle()
                        .fill(Color.green.opacity(0.05))
                        .frame(width: 160, height: 160)
                        .scaleEffect(appeared ? 1.1 : 0.9)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: appeared)
                    
                    // The "Brain" Box
                    ZStack {
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .fill(Color.white)
                            .frame(width: 100, height: 100)
                            .shadow(color: .green.opacity(0.3), radius: 20, x: 0, y: 10)
                        
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 48, weight: .light))
                            .foregroundColor(.green)
                            .symbolEffect(.bounce, options: .repeating, value: appeared)
                    }
                    
                    // Floating Interactive Orbits
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                            .offset(x: 110)
                            .rotationEffect(.degrees(Double(i) * 120 + innerRotation))
                    }
                }
                .padding(.bottom, 60)
                
                // 2. Title Section
                VStack(spacing: 8) {
                    Text("AI Brain Processing")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Analyzing unique breed characteristics...")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                
                // 3. Status Steps
                VStack(spacing: 12) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        ProcessingRow(
                            text: steps[index],
                            isCompleted: currentStep > index,
                            isActive: currentStep == index
                        )
                        .opacity(currentStep >= index ? 1 : 0.3)
                        .scaleEffect(currentStep == index ? 1.05 : 1.0)
                        .animation(.spring(), value: currentStep)
                    }
                }
                .padding(30)
                
                Spacer()
                
                // 4. Custom Progress Bar
                VStack(spacing: 15) {
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(LinearGradient(colors: [.green, Color(hex: "81C784")], startPoint: .leading, endPoint: .trailing))
                            .frame(width: 280 * progress, height: 6)
                    }
                    .frame(width: 280)
                    .shadow(color: .green.opacity(0.4), radius: 8, x: 0, y: 0)
                    
                    HStack(spacing: 4) {
                        Text("\(Int(progress * 100))%")
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Text("Completed")
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .font(.caption)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            appeared = true
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                innerRotation = -360
            }
            startProcessing()
        }
    }
    
    func startProcessing() {
        // Dynamic timing for more "realistic" feel
        let intervals: [TimeInterval] = [0.8, 1.2, 1.5, 1.0]
        processNextStep(index: 0, intervals: intervals)
    }
    
    func processNextStep(index: Int, intervals: [TimeInterval]) {
        guard index < steps.count else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation { path.append(.detectionResult) }
            }
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + intervals[index]) {
            withAnimation(.spring()) {
                currentStep = index + 1
                progress = CGFloat(currentStep) / CGFloat(steps.count)
            }
            processNextStep(index: index + 1, intervals: intervals)
        }
    }
}

struct ProcessingRow: View {
    let text: String
    let isCompleted: Bool
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.green : (isActive ? Color.green.opacity(0.3) : Color.white.opacity(0.1)))
                    .frame(width: 28, height: 28)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                } else if isActive {
                    Circle()
                        .stroke(Color.green, lineWidth: 2)
                        .frame(width: 14, height: 14)
                }
            }
            
            Text(text)
                .font(.system(size: 15, weight: isActive ? .bold : .medium))
                .foregroundColor(isActive || isCompleted ? .white : .white.opacity(0.4))
            
            Spacer()
            
            if isActive {
                ProgressView()
                    .tint(.green)
                    .scaleEffect(0.8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(isActive ? Color.white.opacity(0.05) : Color.clear)
        .cornerRadius(16)
    }
}

