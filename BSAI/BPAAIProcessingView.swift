import SwiftUI
import PhotosUI

struct BPAAIProcessingView: View {
    @Binding var path: [AppRoute]
    let earTag: String?
    
    @State private var progress: CGFloat = 0.0
    @State private var currentStepIndex: Int = 0
    @State private var hasNavigated = false
    @State private var showErrorAlert = false
    @State private var errorMessage: String = ""
    @State private var isProcessing = false
    
    @State private var analysisStarted = false
    @State private var viewDidAppear = false
    
    private let steps = [
        "Analyzing anatomical features",
        "Comparing with BPA database",
        "Calculating confidence score"
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "F8FBF9").ignoresSafeArea()
            
            VStack(spacing: 40) {
                HStack {
                    Button(action: { 
                        if !path.isEmpty { path.removeLast() }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "1B5E20"))
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 4)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                // Progress Ring
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.1), lineWidth: 10)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "00C853"), Color(hex: "008D43")],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.4), value: progress)
                    
                    VStack(spacing: 10) {
                        Image(systemName: "cpu")
                            .font(.system(size: 44))
                            .foregroundColor(Color(hex: "00C853"))
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(Color(hex: "1B5E20"))
                    }
                }
                
                VStack(spacing: 12) {
                    Text("AI Breed Recognition")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "1B5E20"))
                    
                    Text("Analyzing patterns, physical features, and\ncharacteristics to identify the breed...")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        ProcessingStep(label: step, completed: currentStepIndex > index)
                    }
                }
                .padding(.top, 10)
                
                Spacer()
            }
            .padding(20)
        }
        .navigationBarHidden(true)
        .alert(errorMessage.contains("DISCLAIMER") ? "Image Rejected" : "Analysis Error", isPresented: $showErrorAlert) {
            Button("Try Again", role: .cancel) {
                if !path.isEmpty { path.removeLast() }
            }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            hideKeyboard() // Dismiss any leftover keyboard from registration
            viewDidAppear = true
            if !analysisStarted {
                startAnalysis()
            }
        }
    }
    
    private func startAnalysis() {
        // Ensure keyboard is dismissed
        hideKeyboard()
        
        guard !analysisStarted else { return }
        analysisStarted = true
        
        // REQUIRED FIX: Clear old prediction before starting
        AuthManager.shared.currentPrediction = nil
        
        // REQUIRED FIX: Reset loading state and progress
        self.isProcessing = true
        self.progress = 0.05 // Immediate feedback
        self.currentStepIndex = 0
        self.hasNavigated = false
        
        guard let uiImage = AuthManager.shared.pendingImage else {
            return
        }
        
        print("🧪 BPA AI: Starting Analysis for EarTag: \(earTag ?? "nil")")
        // Start animation milestones
        animateProgress()
        
        // Trigger AI Call
        AuthManager.shared.uploadImageForPrediction(image: uiImage, earTag: earTag) { result in
            DispatchQueue.main.async {
                print("🧪 BPA AI: API Response Received")
                self.isProcessing = false
                guard !self.hasNavigated else { 
                    print("🧪 BPA AI: Already navigated, ignoring response")
                    return 
                }
                
                switch result {
                case .success(let prediction):
                    print("🧪 BPA AI: Success! Breed: \(prediction.breed_name ?? "nil")")
                    AuthManager.shared.currentPrediction = prediction
                    
                    if let msg = prediction.message {
                        print("🧪 BPA AI: Result contains rejection message")
                        self.errorMessage = msg
                        self.hasNavigated = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if self.viewDidAppear {
                                self.showErrorAlert = true
                            }
                        }
                    } else {
                        // SUCCESS CASE
                        print("🧪 BPA AI: High confidence result, navigating...")
                        
                        // Stop milestones and jump to 100%
                        withAnimation(.easeOut(duration: 0.4)) {
                            self.progress = 1.0
                            self.currentStepIndex = self.steps.count
                        }
                        
                        // Navigate after brief pause to show 100%
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            if !self.hasNavigated {
                                self.hasNavigated = true
                                print("🧪 BPA AI: Appending .bpaDetectionResult to path")
                                self.path.append(.bpaDetectionResult(earTag: self.earTag))
                            }
                        }
                    }
                    
                case .failure(let error):
                    print("🧪 BPA AI: API Failure - \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    // Small delay for alert stability
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if self.viewDidAppear {
                            self.showErrorAlert = true
                        }
                    }
                }
            }
        }
    }
    
    private func animateProgress() {
        let milestones: [(Double, Int, Double)] = [
            (0.4, 1, 0.33),
            (1.0, 2, 0.66),
            (2.0, 3, 0.90)
        ]
        
        for (delay, step, targetProgress) in milestones {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard !self.hasNavigated && self.analysisStarted else { return }
                withAnimation(.easeInOut(duration: 0.8)) {
                    self.progress = targetProgress
                    self.currentStepIndex = step
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
                    .fill(completed ? Color(hex: "00C853") : Color.gray.opacity(0.12))
                    .frame(width: 26, height: 26)
                    .animation(.easeInOut(duration: 0.3), value: completed)
                
                if completed {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .transition(.scale)
                }
            }
            
            Text(label)
                .font(.system(size: 15, weight: completed ? .semibold : .regular))
                .foregroundColor(completed ? Color(hex: "1B5E20") : .secondary)
            
            Spacer()
        }
        .opacity(completed ? 1 : 0.6)
        .animation(.easeInOut(duration: 0.3), value: completed)
    }
}

#Preview {
    BPAAIProcessingView(path: .constant([]), earTag: nil)
}
