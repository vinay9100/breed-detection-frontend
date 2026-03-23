import SwiftUI

struct BreedProfileView: View {
    @Binding var path: [AppRoute]
    @ObservedObject private var localization = LocalizationManager.shared
    @State private var appeared = false
    @State private var selectedTab = 0
    
    var prediction: PredictResponse? {
        AuthManager.shared.currentPrediction
    }
    
    var breedInfo: BreedInfo? {
        if let breedName = prediction?.breed_name {
            return BreedRepository.getBreed(named: breedName)
        }
        return nil
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background Gradient
            LinearGradient(colors: [Color.green.opacity(0.1), Color.appBackground], startPoint: .top, endPoint: .bottom)
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
                    .background(Color.cardBackground)
                    .clipShape(Circle())
                    .shadow(color: Color.shadowColor, radius: 5, x: 0, y: 2)
            }
            
            Text(LocalizationManager.shared.t("breed_profile_title"))
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 10)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
    
    private var heroImageSection: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 32)
                    .fill(LinearGradient(colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 300)
                    .overlay(
                        Group {
                             if let imageUrl = prediction?.image_url,
                                let url = URL(string: "\(AuthManager.shared.baseURL)/\(imageUrl)") {
                                 AsyncImage(url: url) { phase in
                                     switch phase {
                                     case .empty:
                                         ProgressView()
                                     case .success(let image):
                                         image
                                             .resizable()
                                             .aspectRatio(contentMode: .fill)
                                             .frame(width: geo.size.width, height: 300)
                                             .clipped()
                                     case .failure(_):
                                         Image(systemName: "photo")
                                             .font(.system(size: 50))
                                             .foregroundColor(.gray.opacity(0.3))
                                     @unknown default:
                                         EmptyView()
                                     }
                                 }
                             } else {
                                 Image(systemName: "photo")
                                     .font(.system(size: 50))
                                     .foregroundColor(.gray.opacity(0.3))
                             }
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                    .shadow(color: Color.shadowColor, radius: 20, x: 0, y: 15)
                
                Text(prediction?.breed_name ?? "Unknown Breed")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .padding(20)
            }
        }
        .frame(height: 300)
        .padding(.horizontal)
        .scaleEffect(appeared ? 1 : 0.95)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)
    }
    
    private var quickStatsRow: some View {
        HStack(spacing: 15) {
            QuickStatView(label: LocalizationManager.shared.t("breed_profile_origin"), value: breedInfo?.origin ?? "India", icon: "globe.europe.africa.fill", color: .blue)
            QuickStatView(label: LocalizationManager.shared.t("breed_profile_purpose"), value: breedInfo?.category ?? "Dairy", icon: "drop.fill", color: .cyan)
            QuickStatView(label: LocalizationManager.shared.t("breed_profile_confidence"), value: String(format: "%.0f%%", prediction?.confidence_score ?? 0), icon: "checkmark.shield.fill", color: .green)
        }
        .padding(.horizontal)
        .offset(y: appeared ? 0 : 20)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appeared)
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(LocalizationManager.shared.t("breed_profile_about"))
                .font(.system(size: 22, weight: .bold))
            
            let description = breedInfo != nil ? 
                "The \(breedInfo!.name) is a premium \(breedInfo!.category.lowercased()) originating from \(breedInfo!.origin). It is known for its \(breedInfo!.productivity.lowercased()) productivity and \(breedInfo!.climateTolerance.lowercased()) climate tolerance." :
                "Detailed information about this specific breed characterization and its distinctive markings as identified by our AI scanning system."

            Text(description)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .cornerRadius(28)
        .shadow(color: Color.shadowColor, radius: 15, x: 0, y: 10)
        .padding(.horizontal)
        .offset(y: appeared ? 0 : 20)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: appeared)
    }
    
    private var detailedAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(LocalizationManager.shared.t("breed_profile_analysis"))
                .font(.system(size: 22, weight: .bold))
                .padding(.horizontal)
            
            VStack(spacing: 14) {
                AnalysisButton(title: LocalizationManager.shared.t("breed_profile_care"), subtitle: "Personalized Daily Plan", icon: "heart.fill", color: .pink) {
                    path.append(.careRecommendations)
                }
                AnalysisButton(title: LocalizationManager.shared.t("breed_profile_seasonal"), subtitle: "Climate Optimized Guide", icon: "snow", color: .blue) {
                    path.append(.seasonalCare)
                }
                AnalysisButton(title: LocalizationManager.shared.t("breed_profile_economic"), subtitle: "\(breedInfo?.cost ?? "Medium") Input Cost", icon: "dollarsign.circle.fill", color: .green) {
                    path.append(.economicPotential)
                }
                AnalysisButton(title: LocalizationManager.shared.t("breed_profile_milk_yield"), subtitle: "\(prediction?.milk_yield_range ?? "12-15L") Daily Range", icon: "drop.fill", color: .blue) {
                    path.append(.milkYieldAnalysis)
                }
                AnalysisButton(title: LocalizationManager.shared.t("breed_profile_productivity"), subtitle: "\(breedInfo?.productivity ?? "High") Efficiency", icon: "chart.bar.fill", color: .green) {
                    path.append(.productivityScore)
                }
                
                // Fixed Side-by-Side Layout
                HStack(spacing: 14) {
                    SmallAnalysisCard(title: LocalizationManager.shared.t("breed_profile_fat"), value: "\(prediction?.fat_content ?? "4.5%")", icon: "percent", color: .orange)
                    SmallAnalysisCard(title: LocalizationManager.shared.t("breed_profile_yield_est"), value: "\(String(format: "%.1f", prediction?.yield_estimate ?? 0))L", icon: "calendar.badge.clock", color: .purple)
                }
                
                AnalysisButton(title: LocalizationManager.shared.t("breed_profile_disease"), subtitle: "Genomic Health Score", icon: "shield.checkered", color: .red) {
                    path.append(.diseaseRisk)
                }
                AnalysisButton(title: LocalizationManager.shared.t("breed_profile_climate"), subtitle: "\(breedInfo?.climate ?? "Optimal") Tolerance", icon: "thermometer.medium", color: .orange) {
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

struct SmallAnalysisCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.primary)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(18)
        .shadow(color: Color.shadowColor, radius: 8, x: 0, y: 4)
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
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
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
            .background(Color.cardBackground)
            .cornerRadius(22)
            .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    BreedProfileView(path: .constant([]))
}
