import SwiftUI

struct BPAAIProcessingView: View {
    @Binding var path: [AppRoute]
    @State private var progress: CGFloat = 0.0
    @State private var appeared = false
    
    var body: some View {
        ZStack {
            Color(hex: "F8FBF9").ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                ZStack {
                    // Scanning Animation
                    Circle()
                        .stroke(Color.gray.opacity(0.1), lineWidth: 8)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(colors: [Color(hex: "00C853"), Color(hex: "008D43")], startPoint: .top, endPoint: .bottom),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 12) {
                        Image(systemName: "cpu")
                            .font(.system(size: 44))
                            .foregroundColor(Color(hex: "00C853"))
                        
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "1B5E20"))
                    }
                }
                
                VStack(spacing: 15) {
                    Text("AI Breed Recognition")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "1B5E20"))
                    
                    Text("Analyzing patterns, physical features, and\ncharacteristics to identify the breed...")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    ProcessingStep(label: "Analyzing anatomical features", completed: progress > 0.3)
                    ProcessingStep(label: "Comparing with BPA database", completed: progress > 0.6)
                    ProcessingStep(label: "Calculating confidence score", completed: progress > 0.9)
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding(30)
        }
        .onAppear {
            appeared = true
            
            // Start upload
            if let uiImage = UIImage(named: "cow_temp_1") {
                AuthManager.shared.uploadImageForPrediction(image: uiImage) { result in
                    switch result {
                    case .success(let prediction):
                        AuthManager.shared.currentPrediction = prediction
                        withAnimation(.linear(duration: 0.5)) {
                            progress = 1.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            path.append(.bpaDetectionResult)
                        }
                    case .failure(let error):
                        print("Error in AI prediction:", error.localizedDescription)
                        // Even on fail, simulate finish for demo purposes
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            path.append(.bpaDetectionResult)
                        }
                    }
                }
            } else {
                // Fallback simulation
                withAnimation(.linear(duration: 3.0)) {
                    progress = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                    path.append(.bpaDetectionResult)
                }
            }
            
            // Simulate progress artificially while waiting for network
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                if progress >= 0.95 {
                    timer.invalidate()
                } else if AuthManager.shared.currentPrediction == nil {
                    withAnimation {
                        progress += 0.05
                    }
                }
            }
        }
    }
}

struct ProcessingStep: View {
    let label: String
    let completed: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(completed ? Color(hex: "00C853") : Color.gray.opacity(0.1))
                    .frame(width: 24, height: 24)
                
                if completed {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            Text(label)
                .font(.system(size: 15, weight: completed ? .semibold : .medium))
                .foregroundColor(completed ? Color(hex: "1B5E20") : .secondary)
            
            Spacer()
        }
        .opacity(completed ? 1 : 0.6)
    }
}

#Preview {
    BPAAIProcessingView(path: .constant([]))
}
