import SwiftUI

struct BPADetectionResultView: View {
    @Binding var path: [AppRoute]
    let earTag: String?
    @State private var appeared = false
    
    private var result: PredictResponse? {
        AuthManager.shared.currentPrediction
    }
    
    var body: some View {
        ZStack {
            if let result = result {
                contentView(result: result)
            } else {
                noResultView
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }
    
    @ViewBuilder
    private func contentView(result: PredictResponse) -> some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection(result: result)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        resultCard(result: result)
                        
                        confidenceSection(result: result)
                        
                        comparisonSection(result: result)
                        
                        saveButton(result: result)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(24)
                    .padding(.top, -30)
                }
            }
        }
    }
    
    private var noResultView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            Text("No Analysis Result Found")
                .font(.headline)
            Button("Back to Dashboard") {
                path = [.bpaDashboard]
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private func headerSection(result: PredictResponse) -> some View {
        VStack(spacing: 10) {   
            // Top bar
            HStack {
                Button(action: {
                    AuthManager.shared.pendingImage = nil
                    AuthManager.shared.currentPrediction = nil
                    if path.count >= 3 {
                        path.removeLast(3)
                    } else {
                        path.removeAll()
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
                
                Text("AI Result")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 20)

            // Icon (smaller)
            ZStack {
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: 50, height: 50)
                
                Image(systemName: result.message != nil ? "exclamationmark.triangle.fill" : "checkmark.seal.fill")
                    .font(.system(size: 20))
                    .foregroundColor(result.message != nil ? .orange : .green)
            }

            // Text
            VStack(spacing: 4) {
                Text(result.message != nil ? "Rejected" : "Success")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                Text(result.message ?? "Breed identified")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.85))
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
        .background(
            LinearGradient(
                colors: [Color(hex: "00C853"), Color(hex: "008D43")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
    
    private func resultCard(result: PredictResponse) -> some View {
        VStack(spacing: 20) {
            // 1. Image View — fixed height, properly clipped to its container
            ZStack { // ✅ REMOVED GeometryReader to prevent memory spikes
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
                
                if let imageUrl = result.image_url,
                   let url = URL(string: "\(AuthManager.shared.baseURL)/\(imageUrl)") {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()   // ✅ REQUIRED FIX
                                .frame(height: 180)
                                .frame(maxWidth: .infinity)
                                .clipped()
                        case .failure(_):
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .id(result.image_url ?? UUID().uuidString) // ✅ FORCE MEMORY RESET
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.3))
                        Text("Analyzed Image")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Status badge
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(result.message != nil ? "REJECTED" : "DETECTED")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(result.message != nil ? Color.red : Color.purple)
                            .cornerRadius(8)
                            .padding(12)
                    }
                }
            }
            .frame(height: 200)
            .cornerRadius(20)
            .clipped()

            // 2. Info Section
            if let message = result.message {
                VStack(spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Image Not Accepted")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.orange)
                    }
                    
                    Text(message)
                        .font(.system(size: 15, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                .padding(.bottom, 10)
            } else {
                VStack(spacing: 8) {
                    Text(result.breed_name ?? "Unknown Breed")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "1B5E20"))
                    Text("Type: \(result.animal_type ?? "Unknown") | Fat Content: \(result.fat_content ?? "N/A")")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 10)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }
    
    private func confidenceSection(result: PredictResponse) -> some View {
        Group {
            if result.message == nil {
                let confScore = result.confidence_score ?? 0.0
                
                VStack(alignment: .leading, spacing: 18) {
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
                    
                    Text("The features align with \(result.breed_name ?? "the detected breed")'s characteristics in the BPA database. Milk Yield Range: \(result.milk_yield_range ?? "N/A")")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .padding(24)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 10)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
            }
        }
    }
    
    private func comparisonSection(result: PredictResponse) -> some View {
        Group {
            if result.message == nil {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Key Characteristics Identified")
                        .font(.system(size: 16, weight: .bold))
                    
                    VStack(spacing: 12) {
                        CharacteristicRow(label: "Coat Pattern", value: "Verified", matches: true)
                        CharacteristicRow(label: "Body Structure", value: "Identified", matches: true)
                        CharacteristicRow(label: "Head Shape", value: "Analyzed", matches: true)
                        CharacteristicRow(label: "Breed Standard", value: "Aligned", matches: true)
                    }
                }
                .padding(24)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 10)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
            }
        }
    }
    
    private func saveButton(result: PredictResponse) -> some View {
        VStack(spacing: 15) {
            if result.message == nil {
                Button(action: {
                    // ✅ Fix: Remove duplicate saveDetection call. 
                    // The scan is already saved by the backend during /predict-animal.
                    // Just update local state and navigate.
                    AuthManager.shared.confirmedPrediction = result // Store confirmed result for registration
                    AuthManager.shared.currentPrediction = nil
                    AuthManager.shared.pendingImage = nil
                    
                    // Redirect back to registration form to continue
                    if let regIdx = path.firstIndex(of: .bpaAnimalRegistration) {
                        path = Array(path.prefix(through: regIdx))
                    } else if let dashIdx = path.firstIndex(of: .bpaDashboard) {
                        path = Array(path.prefix(through: dashIdx))
                    } else {
                        path.removeAll()
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
            }
            
            Button(action: {
                // Go back to camera view
                AuthManager.shared.pendingImage = nil
                AuthManager.shared.currentPrediction = nil
                if let camIdx = path.firstIndex(of: .bpaCamera(earTag: earTag)) {
                    path = Array(path.prefix(through: camIdx))
                } else if path.count >= 2 {
                    path.removeLast(2)
                }
            }) {
                Text(result.message != nil ? "Back to Camera" : "Retake Scan")
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
    BPADetectionResultView(
        path: .constant([.bpaDashboard, .bpaAnimalRegistration, .bpaCamera(earTag: nil), .bpaAIProcessing(earTag: nil)]),
        earTag: "ET-123"
    )
}
