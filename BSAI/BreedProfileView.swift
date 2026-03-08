import SwiftUI

struct BreedProfileView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background Gradient
            LinearGradient(colors: [Color.green.opacity(0.1), Color.white], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                navigationBar
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        heroImageSection
                        quickStatsRow
                        aboutSection
                        detailedAnalysisSection
                        
                        Spacer(minLength: 50)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            appeared = true
        }
    }
    
    // MARK: - Subviews
    
    private var navigationBar: some View {
        HStack {
            Button(action: {
                if !path.isEmpty {
                    withAnimation(.easeIn(duration: 0.2)) {
                        _ = path.removeLast()
                    }
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            
            Text("Breed Profile")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 10)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
    
    private var heroImageSection: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 32)
                .fill(LinearGradient(colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 300)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 50))
                        .foregroundColor(.gray.opacity(0.3))
                )
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 15)
            
            Text("Holstein Friesian")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(20)
        }
        .scaleEffect(appeared ? 1 : 0.95)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)
    }
    
    private var quickStatsRow: some View {
        HStack(spacing: 15) {
            QuickStatView(label: "Origin", value: "Netherlands", icon: "globe.europe.africa.fill", color: .blue)
            QuickStatView(label: "Purpose", value: "Dairy", icon: "drop.fill", color: .cyan)
            QuickStatView(label: "Type", value: "Bovine", icon: "leaf.fill", color: .green)
        }
        .padding(.horizontal)
        .offset(y: appeared ? 0 : 20)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appeared)
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About the Breed")
                .font(.system(size: 22, weight: .bold))
            
            Text("The Holstein-Friesian is a breed of cattle originating from the Dutch provinces of North Holland and Friesland. They are known as the world's highest-production dairy animals, recognized by their distinctive black-and-white markings.")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(28)
        .shadow(color: .black.opacity(0.03), radius: 15, x: 0, y: 10)
        .padding(.horizontal)
        .offset(y: appeared ? 0 : 20)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: appeared)
    }
    
    private var detailedAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Detailed Analysis")
                .font(.system(size: 22, weight: .bold))
                .padding(.horizontal)
            
            VStack(spacing: 14) {
                AnalysisButton(title: "Care Recommendations", subtitle: "Personalized Daily Plan", icon: "heart.fill", color: .pink) {
                    path.append(.careRecommendations)
                }
                AnalysisButton(title: "Seasonal Care", subtitle: "Winter Guidelines Active", icon: "snow", color: .blue) {
                    path.append(.seasonalCare)
                }
                AnalysisButton(title: "Economic Potential", subtitle: "Revenue & ROI Analysis", icon: "dollarsign.circle.fill", color: .green) {
                    path.append(.economicPotential)
                }
                AnalysisButton(title: "Milk Yield Analysis", subtitle: "24.5L Daily Average", icon: "drop.fill", color: .blue) {
                    path.append(.milkYieldAnalysis)
                }
                AnalysisButton(title: "Productivity Score", subtitle: "Outstanding (94/100)", icon: "chart.bar.fill", color: .green) {
                    path.append(.productivityScore)
                }
                AnalysisButton(title: "Disease Risk Profile", subtitle: "Low Risk Environment", icon: "shield.checkered", color: .red) {
                    path.append(.diseaseRisk)
                }
                AnalysisButton(title: "Climate Suitability", subtitle: "Optimal (15-25°C)", icon: "thermometer.medium", color: .orange) {
                    path.append(.climateSuitability)
                }
            }
            .padding(.horizontal)
        }
        .offset(y: appeared ? 0 : 20)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: appeared)
    }
}

struct QuickStatView: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.02), radius: 10, x: 0, y: 5)
    }
}

struct AnalysisButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color.opacity(0.1))
                        .frame(width: 56, height: 56)
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray.opacity(0.4))
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(22)
            .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    BreedProfileView(path: .constant([]))
}
