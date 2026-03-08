import SwiftUI

struct BPADetectionResultView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    
    var body: some View {
        ZStack {
            Color(hex: "F8FBF9").ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        resultCard
                        
                        confidenceSection
                        
                        comparisonSection
                        
                        saveButton
                        
                        Spacer(minLength: 40)
                    }
                    .padding(24)
                    .padding(.top, -30)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 15) {
            HStack {
                Button(action: { 
                    if path.count >= 3 {
                        path.removeLast(3)
                    } else {
                        path.removeLast(path.count)
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
                
                Text("AI Result")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
            .padding(.bottom, 60)
        }
        .background(
            LinearGradient(
                colors: [Color(hex: "00C853"), Color(hex: "008D43")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
    
    private var resultCard: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 200)
                    .overlay(
                        VStack(spacing: 10) {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray.opacity(0.3))
                            Text("Analyzed Animal Image")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    )
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("DETECTED")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.purple)
                            .cornerRadius(8)
                            .padding(15)
                    }
                }
            }
            
            VStack(spacing: 8) {
                Text(AuthManager.shared.currentPrediction?.breed_name ?? "Unknown Breed")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: "1B5E20"))
                Text("Type: \(AuthManager.shared.currentPrediction?.animal_type ?? "Unknown") | Est. Yield: \(String(format: "%.1f", AuthManager.shared.currentPrediction?.yield_estimate ?? 0.0)) L/day")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 10)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }
    
    private var confidenceSection: some View {
        let confScore = AuthManager.shared.currentPrediction?.confidence_score ?? 0.0
        
        return VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("AI Confidence Score")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Text("\(String(format: "%.1f", confScore))%")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "00C853"))
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(colors: [Color(hex: "00C853"), Color(hex: "008D43")], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(min(confScore / 100.0, 1.0)))
                }
            }
            .frame(height: 12)
            
            Text("High confidence result. The features perfectly align with \(AuthManager.shared.currentPrediction?.breed_name ?? "this breed's") characteristics in the BPA database. Fat Content Est: \(AuthManager.shared.currentPrediction?.fat_content ?? "N/A")")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 10)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring().delay(0.1), value: appeared)
    }
    
    private var comparisonSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Key Characteristics Identified")
                .font(.system(size: 16, weight: .bold))
            
            VStack(spacing: 12) {
                CharacteristicRow(label: "Coat Pattern", value: "Black & White Spotted", matches: true)
                CharacteristicRow(label: "Body Structure", value: "Large Dairy Frame", matches: true)
                CharacteristicRow(label: "Head Shape", value: "Correct Proportions", matches: true)
                CharacteristicRow(label: "Horn Status", value: "Dehorning Verified", matches: true)
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 10)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring().delay(0.2), value: appeared)
    }
    
    private var saveButton: some View {
        VStack(spacing: 15) {
            Button(action: {
                // Read from the shared prediction state
                guard let prediction = AuthManager.shared.currentPrediction else { return }
                
                let breed = prediction.breed_name
                let confidence = prediction.confidence_score
                let yieldEstimate = prediction.yield_estimate ?? 0.0
                
                AuthManager.shared.saveDetection(breedName: breed, confidenceScore: confidence, yieldEstimate: yieldEstimate) { result in
                    switch result {
                    case .success(_):
                        if path.count >= 3 {
                            path.removeLast(3)
                        } else {
                            path.removeAll()
                        }
                    case .failure(let error):
                        print("Failed to save detection: \(error.localizedDescription)")
                        // Handle error (e.g., show an alert) 
                    }
                }
            }) {
                Text("Confirm & Use Result")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color(hex: "008D43"))
                    .cornerRadius(14)
                    .shadow(color: Color(hex: "008D43").opacity(0.3), radius: 10, x: 0, y: 5)
            }
            
            Button(action: {
                path.removeLast(2) // Back to Camera
            }) {
                Text("Retake Scan")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "008D43"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
        }
        .padding(.top, 10)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring().delay(0.3), value: appeared)
    }
}

struct CharacteristicRow: View {
    let label: String
    let value: String
    let matches: Bool
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            Spacer()
            HStack(spacing: 6) {
                if matches {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "00C853"))
                }
                Text(value)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "1B5E20"))
            }
        }
    }
}

#Preview {
    BPADetectionResultView(path: .constant([.bpaDashboard, .bpaAnimalRegistration, .bpaCamera, .bpaAIProcessing]))
}
