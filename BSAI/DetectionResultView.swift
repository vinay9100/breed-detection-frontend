import SwiftUI
import UIKit


struct DetectionResultView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection
                    
                    VStack(spacing: 25) {
                        mainResultCard
                        insightsSection
                        bottomActions
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
        .onAppear {
            appeared = true
        }
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        ZStack(alignment: .top) {
            LinearGradient(colors: [.green, Color(hex: "1B5E20")], startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(height: 280)
                .clipShape(RoundedCorner(radius: 45, corners: [.bottomLeft, .bottomRight]))
                .shadow(color: .green.opacity(0.3), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 25) {
                // Dashboard button removed
                Spacer().frame(height: 10)
                
                ZStack {
                    Circle()
                        .fill(Color(.systemBackground))
                        .frame(width: 90, height: 90)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: AuthManager.shared.currentPrediction?.message != nil ? "exclamationmark.triangle.fill" : "checkmark.seal.fill")
                        .font(.system(size: 45))
                        .foregroundColor(AuthManager.shared.currentPrediction?.message != nil ? .orange : .green)
                }
                .scaleEffect(appeared ? 1 : 0.5)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2), value: appeared)
                
                VStack(spacing: 8) {
                    Text(AuthManager.shared.currentPrediction?.message != nil ? "Recognition Rejected" : "Analysis Successful!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text(AuthManager.shared.currentPrediction?.message ?? "Our AI has identified the breed")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 15)
                .animation(.easeOut(duration: 0.5).delay(0.4), value: appeared)
            }
            .padding(.top, 40)
        }
    }
    
    private var mainResultCard: some View {
        VStack(spacing: 24) {
            // 1. Image View — fixed height, properly clipped
            GeometryReader { geo in
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray6))
                    
                    if let imageUrl = AuthManager.shared.currentPrediction?.image_url,
                       let url = URL(string: "\(AuthManager.shared.baseURL)/\(imageUrl)") {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geo.size.width, height: 200)
                                    .clipped()
                            case .failure(_):
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 34))
                                .foregroundColor(.gray.opacity(0.4))
                            Text("Analyzed Image")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Status badge
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text(AuthManager.shared.currentPrediction?.message != nil ? "REJECTED" : "DETECTED")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(AuthManager.shared.currentPrediction?.message != nil ? Color.red : Color.green)
                                .cornerRadius(10)
                                .padding(12)
                        }
                    }
                }
            }
            .frame(height: 200)
            .cornerRadius(20)
            .clipped()
            
            // 2. Info Section
            if let message = AuthManager.shared.currentPrediction?.message {
                VStack(spacing: 15) {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Cattle Not Detected")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.orange)
                    }
                    
                    Text(message)
                        .font(.system(size: 15, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 10)
                }
                .padding(.bottom, 5)
            } else {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("BREED IDENTIFIED")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.green)
                            Text(AuthManager.shared.currentPrediction?.breed_name ?? "Unknown")
                                .font(.system(size: 24, weight: .bold))
                        }
                        Spacer()
                    }
                    
                    Divider().background(Color.gray.opacity(0.1))
                    
                    confidenceLevelView
                    
                    viewProfileButton
                }
            }
        }
        .padding(24)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(32)
        .shadow(color: Color.black.opacity(0.06), radius: 20, x: 0, y: 15)
        .padding(.horizontal, 24)
        .offset(y: -50)
        .scaleEffect(appeared ? 1 : 0.92)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.6), value: appeared)
    }
    
    private var confidenceLevelView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Confidence Level")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "%.1f%%", AuthManager.shared.currentPrediction?.confidence_score ?? 0))
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(.green)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.green.opacity(0.1))
                        .frame(height: 12)
                    
                    Capsule()
                        .fill(LinearGradient(colors: [.green, Color(hex: "4CAF50")], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat((AuthManager.shared.currentPrediction?.confidence_score ?? 0) / 100), height: 12)
                }
            }
            .frame(height: 12)
        }
    }
    
    private var viewProfileButton: some View {
        Button(action: {
            withAnimation(.spring()) {
                path.append(.breedProfile)
            }
        }) {
            HStack {
                Text("View Detailed Breed Profile")
                    .font(.system(size: 16, weight: .bold))
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.green)
            .cornerRadius(18)
            .shadow(color: .green.opacity(0.2), radius: 10, x: 0, y: 5)
        }	
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var insightsSection: some View {
        Group {
            if AuthManager.shared.currentPrediction?.message == nil {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Quick Insights")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.horizontal, 24)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        InsightCard(icon: "drop.fill", title: "Milk Yield", value: "High", color: .blue) {
                            path.append(.milkYieldAnalysis)
                        }
                        InsightCard(icon: "chart.line.uptrend.xyaxis", title: "Productivity", value: "Excellent", color: .green) {
                            path.append(.productivityScore)
                        }
                        InsightCard(icon: "thermometer.medium", title: "Climate", value: "Optimal", color: .orange) {
                            path.append(.climateSuitability)
                        }
                        InsightCard(icon: "heart.text.square.fill", title: "Health Risk", value: "Low", color: .red) {
                            path.append(.diseaseRisk)
                        }
                        InsightCard(icon: "arrow.left.and.right.righttriangle.left.righttriangle.right.fill", title: "Comparison", value: "Benchmarks", color: .purple) {
                            path.append(.breedComparison)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .offset(y: -20)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.7), value: appeared)
            }
        }
    }
    
    private var bottomActions: some View {
        VStack(spacing: 14) {
            Button(action: {
                withAnimation(.spring()) {
                    AuthManager.shared.pendingImage = nil
                    AuthManager.shared.currentPrediction = nil
                    // Try to go back to the camera screen if it exists in path
                    if let cameraIndex = path.firstIndex(where: { $0 == .camera }) {
                        path = Array(path.prefix(through: cameraIndex))
                    } else {
                        // Fallback if camera isn't in path
                        path.append(.camera)
                    }
                }
            }) {
                Text("Retake Scan")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(18)
            }
            
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    AuthManager.shared.pendingImage = nil
                    AuthManager.shared.currentPrediction = nil
                    path = [.dashboard]
                }
            }) {
                Text("Done")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.green)
                    .cornerRadius(18)
                    .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.top, 10)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }
}
