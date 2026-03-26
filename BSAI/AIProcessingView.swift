import SwiftUI
import PhotosUI

struct AIProcessingView: View {
    @Binding var path: [AppRoute]
    
    @State private var progress: CGFloat = 0.0
    @State private var currentStepIndex: Int = 0
    @State private var rotation: Double = 0.0
    @State private var appeared = false
    @State private var showRejectionAlert = false
    @State private var rejectionMessage = ""
    @State private var processingStarted = false
    
    let steps = [
        "Analyzing physical features",
        "Matching breed patterns",
        "Calculating confidence score",
        "Finalizing results"
    ]
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Header
                HStack {
                    Button(action: { path.removeLast() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                // Progress Hexagon/Circle
                ZStack {
                    Circle()
                        .stroke(Color.green.opacity(0.1), lineWidth: 15)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(colors: [.green, Color(hex: "4CAF50")], startPoint: .top, endPoint: .bottom),
                            style: StrokeStyle(lineWidth: 15, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 8) {
                        Image(systemName: "cpu.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                            .rotationEffect(.degrees(rotation))
                        
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 30, weight: .bold))
                            .monospacedDigit()
                    }
                }
                .scaleEffect(appeared ? 1 : 0.8)
                .opacity(appeared ? 1 : 0)
                
                VStack(spacing: 16) {
                    Text("AI Breed Recognition")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("Analyzing the image to identify breed\ncharacteristics and physical markers...")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Steps
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        HStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .fill(currentStepIndex > index ? Color.green : Color.gray.opacity(0.1))
                                    .frame(width: 24, height: 24)
                                
                                if currentStepIndex > index {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Text(steps[index])
                                .font(.system(size: 16, weight: currentStepIndex == index ? .semibold : .regular))
                                .foregroundColor(currentStepIndex == index ? .primary : .secondary)
                            
                            if currentStepIndex == index {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .padding(.leading, 5)
                            }
                            
                            Spacer()
                        }
                        .opacity(currentStepIndex >= index ? 1 : 0.3)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                
                Spacer()
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring()) { appeared = true }
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            startProcessing()
        }
        .alert("Recognition Issue", isPresented: $showRejectionAlert) {
            Button("Retake", role: .cancel) {
                path.removeLast()
            }
        } message: {
            Text(rejectionMessage)
        }
    }
    
    func startProcessing() {
        guard !processingStarted else { return }
        processingStarted = true
        
        // Simulating milestones (Scaled to ~20 seconds total)
        let milestones: [(Double, Double, Int)] = [
            (4.0, 0.25, 0),
            (7.5, 0.50, 1),
            (11.0, 0.75, 2),
            (14.0, 0.95, 3)
        ]
        
        for m in milestones {
            DispatchQueue.main.asyncAfter(deadline: .now() + m.0) {
                withAnimation(.easeInOut(duration: 2.0)) {
                    self.progress = m.1
                    self.currentStepIndex = m.2
                }
            }
        }
        
        let startTime = Date()
        
        // Actually upload if we have a pending image
        if let image = AuthManager.shared.pendingImage {
            AuthManager.shared.uploadImageForPrediction(image: image) { result in
                let elapsedTime = Date().timeIntervalSince(startTime)
                let minimumWait: Double = 15.1 // Approximately 15 seconds
                let remainingWait = max(0, minimumWait - elapsedTime)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + remainingWait) {
                    switch result {
                    case .success(let prediction):
                        AuthManager.shared.currentPrediction = prediction
                        
                        if let msg = prediction.message {
                            // REJECTION CASE
                            self.rejectionMessage = msg
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                if self.appeared {
                                    self.showRejectionAlert = true
                                }
                            }
                        } else {
                            // SUCCESS CASE
                            withAnimation(.easeOut(duration: 1.0)) { 
                                self.progress = 1.0
                                self.currentStepIndex = 4 
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                withAnimation { path.append(.detectionResult) }
                            }
                        }
                        
                    case .failure(let error):
                        print("AI Error: \(error.localizedDescription)")
                        self.rejectionMessage = "Could not reach the AI analyzer. Please check your connection."
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if self.appeared {
                                self.showRejectionAlert = true
                            }
                        }
                    }
                }
            }
        } else {
            // No image found? Simulate extended delay then go
            DispatchQueue.main.asyncAfter(deadline: .now() + 19.5) {
                finishProcessing()
            }
        }
    }
    
    func finishProcessing() {
        withAnimation(.easeOut(duration: 1.0)) {
            progress = 1.0
            currentStepIndex = steps.count
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            path.append(.detectionResult)
        }
    }
}
