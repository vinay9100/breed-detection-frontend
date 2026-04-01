import SwiftUI

// MARK: - Navigation Route Enum
enum AppRoute: Hashable {
    case roleSelection
    case login
    case register
    case forgotPassword
    case otpVerification(identifier: String, isPasswordReset: Bool)
    case resetPassword(token: String)
    case dashboard
    case scanGuide
    case camera
    case aiProcessing
    case detectionResult
    case breedProfile
    case milkYieldAnalysis
    case productivityScore
    case diseaseRisk
    case climateSuitability
    case economicPotential
    case seasonalCare
    case careRecommendations
    case vaccinationPlanner
    case reportPreview
    case analyticsHub
    case yieldPrediction
    case yieldForecast(params: YieldPredictionParams)
    case breedComparison(detectedBreed: String? = nil)
    case shareReport
    case scanHistory
    case performanceTrends
    case herdSummary
    case breedDistribution
    case productivityAnalytics
    case notifications
    case profile
    case editProfile
    case settings
    case helpSupport
    
    // BPA Routes
    case bpaRegister
    case bpaForgotPassword
    case bpaOTPVerification(identifier: String, isPasswordReset: Bool)
    case bpaResetPassword(token: String)
    case bpaDashboard
    case bpaAnalytics
    case bpaReports
    case bpaSearch
    case bpaAnimalRegistration
    case bpaRegistrationReview(data: AnimalRegistrationData)
    case bpaRegistrationSuccess
    case bpaCamera(earTag: String? = nil)
    case bpaAIProcessing(earTag: String? = nil)
    case bpaDetectionResult(earTag: String? = nil)
    case bpaAnimalDetail(data: AnimalRegistrationData)
    case addVaccination
}

// MARK: - App Root — owns the single NavigationStack
struct AppRootView: View {
    @State private var path: [AppRoute] = []
    @State private var isLaunched = false
    @ObservedObject private var authManager = AuthManager.shared
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    var body: some View {
        ZStack {
            if isLaunched {
                NavigationStack(path: $path) {
                    ZStack {
                        if authManager.isAuthenticated {
                            if authManager.currentUser?.email.uppercased().hasPrefix("BPA-") == true {
                                BPADashboardView(path: $path)
                            } else if authManager.currentUser != nil {
                                DashboardView(path: $path)
                            } else {
                                Color(.systemBackground).ignoresSafeArea()
                                ProgressView("Recovering Session...")
                                    .foregroundColor(.primary)
                            }
                        } else {
                            LoginView(path: $path)
                        }
                    }
                    .navigationBarHidden(true)
                    .navigationDestination(for: AppRoute.self) { route in
                        viewForRoute(route)
                    }
                }
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .transition(.opacity)
            } else {
                SplashView(isLaunched: $isLaunched)
                    .transition(.opacity)
            }
        }
    }

    @ViewBuilder
    private func viewForRoute(_ route: AppRoute) -> some View {
        switch route {
        case .roleSelection:
            LoginView(path: $path)
                .navigationBarHidden(true)

        case .login:
            LoginView(path: $path)
                .navigationBarHidden(true)

        case .register:
            RegisterView(path: $path)
                .navigationBarHidden(true)

        case .forgotPassword:
            ForgotPasswordView(path: $path)

        case .otpVerification(let identifier, let isPasswordReset):
            OTPVerificationView(path: $path, identifier: identifier, isPasswordReset: isPasswordReset)
                .navigationBarHidden(true)

        case .resetPassword(let token):
            ResetPasswordView(path: $path, token: token)

        case .dashboard:
            DashboardView(path: $path)
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)

        case .scanGuide:
            ScanGuideView(path: $path)
                .navigationBarHidden(true)

        case .camera:
            CameraView(path: $path)
                .navigationBarHidden(true)

        case .aiProcessing:
            AIProcessingView(path: $path)
                .navigationBarHidden(true)

        case .detectionResult:
            DetectionResultView(path: $path)
                .navigationBarHidden(true)

        case .milkYieldAnalysis:
            MilkYieldAnalysisView(path: $path)
                .navigationBarHidden(true)

        case .productivityScore:
            ProductivityScoreView(path: $path)
                .navigationBarHidden(true)

        case .diseaseRisk:
            DiseaseRiskView(path: $path)
                .navigationBarHidden(true)

        case .climateSuitability:
            ClimateSuitabilityView(path: $path)
                .navigationBarHidden(true)

        case .economicPotential:
            EconomicPotentialView(path: $path)
                .navigationBarHidden(true)

        case .seasonalCare:
            SeasonalCareView(path: $path)
                .navigationBarHidden(true)

        case .careRecommendations:
            CareRecommendationsView(path: $path)
                .navigationBarHidden(true)

        case .vaccinationPlanner:
            VaccinationPlannerView(path: $path)
                .navigationBarHidden(true)

        case .reportPreview:
            ReportPreviewView(path: $path)
                .navigationBarHidden(true)

        case .analyticsHub:
            AnalyticsHubView(path: $path)
                .navigationBarHidden(true)

        case .yieldPrediction:
            YieldPredictionView(path: $path)
                .navigationBarHidden(true)

        case .yieldForecast(let params):
            YieldForecastView(path: $path, params: params)
                .navigationBarHidden(true)

        case .breedComparison(let detectedBreed):
            BreedComparisonView(path: $path, initialBreedName: detectedBreed)
                .navigationBarHidden(true)

        case .shareReport:
            ShareReportView(path: $path)
                .navigationBarHidden(true)

        case .scanHistory:
            ScanHistoryView(path: $path)
                .navigationBarHidden(true)

        case .performanceTrends:
            PerformanceTrendsView(path: $path)
                .navigationBarHidden(true)

        case .herdSummary:
            HerdSummaryView(path: $path)
                .navigationBarHidden(true)

        case .breedDistribution:
            BreedDistributionView(path: $path)
                .navigationBarHidden(true)

        case .productivityAnalytics:
            ProductivityAnalyticsView(path: $path)
                .navigationBarHidden(true)

        case .notifications:
            NotificationsView(path: $path)
                .navigationBarHidden(true)

        case .profile:
            ProfileView(path: $path)
                .navigationBarHidden(true)

        case .editProfile:
            EditProfileView(path: $path)
                .navigationBarHidden(true)

        case .settings:
            SettingsView(path: $path)
                .navigationBarHidden(true)

        case .helpSupport:
            HelpSupportView(path: $path)
                .navigationBarHidden(true)

        // BPA Cases
        case .bpaRegister:
            BPARegistrationView(path: $path)
                .navigationBarHidden(true)
        case .bpaForgotPassword:
            BPAForgotPasswordView(path: $path)
                .navigationBarHidden(true)
        case .bpaOTPVerification(let identifier, let isPasswordReset):
            BPAOTPVerificationView(path: $path, identifier: identifier, isPasswordReset: isPasswordReset)
                .navigationBarHidden(true)
        case .bpaResetPassword(let token):
            BPAResetPasswordView(path: $path, token: token)
                .navigationBarHidden(true)
        case .bpaDashboard:
            BPADashboardView(path: $path)
                .navigationBarHidden(true)
        case .bpaAnalytics:
            BPAAnalyticsView(path: $path)
                .navigationBarHidden(true)
        case .bpaReports:
            BPAReportsView(path: $path)
                .navigationBarHidden(true)
        case .bpaSearch:
            BPASearchView(path: $path)
                .navigationBarHidden(true)
        case .breedProfile:
            BreedProfileView(path: $path)
                .navigationBarHidden(true)

        case .bpaAnimalRegistration:
            BPAAnimalRegistrationView(path: $path)
                .navigationBarHidden(true)
        case .bpaRegistrationReview(let data):
            BPARegistrationReviewView(path: $path, registrationData: data)
                .navigationBarHidden(true)
        case .bpaRegistrationSuccess:
            BPARegistrationSuccessView(path: $path)
                .navigationBarHidden(true)
        case .bpaCamera(let earTag):
            BPACameraView(path: $path, earTag: earTag)
                .navigationBarHidden(true)
        case .bpaAIProcessing(let earTag):
            BPAAIProcessingView(path: $path, earTag: earTag)
                .navigationBarHidden(true)
        case .bpaDetectionResult(let earTag):
            BPADetectionResultView(path: $path, earTag: earTag)
                .navigationBarHidden(true)
        case .bpaAnimalDetail(let data):
            BPAAnimalDetailView(path: $path, animal: data)
                .navigationBarHidden(true)
        case .addVaccination:
            AddVaccinationView(path: $path)
                .navigationBarHidden(true)
        }
    }
}

struct AddVaccinationView: View {
    @Binding var path: [AppRoute]
    @State private var vaccineName: String = ""
    @State private var vaccineType: String = "Annual"
    @State private var selectedDate = Date()
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    let vaccineTypes = ["Annual", "Bi-annual", "One-time", "Monthly"]
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView {
                VStack(spacing: 30) {
                    headerSection
                    
                    formSection
                    
                    saveButton
                        .padding(.top, 20)
                }
                .padding(24)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.1).ignoresSafeArea()
                    ProgressView()
                        .padding(20)
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        .shadow(color: Color.shadowColor, radius: 10)
                }
            }
        }
    }
    
    private var navigationBar: some View {
        HStack {
            Button(action: { path.removeLast() }) {
                Image(systemName: "arrow.left")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                    .padding(12)
                    .background(Color.cardBackground)
                    .clipShape(Circle())
                    .shadow(color: Color.shadowColor, radius: 5, x: 0, y: 2)
            }
            Spacer()
        }
        .padding()
        .background(Color.clear)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Add Vaccination")
                .font(.system(size: 32, weight: .bold, design: .rounded))
            Text("Schedule a new vaccination for your livestock to keep them healthy.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var formSection: some View {
        VStack(spacing: 24) {
            // Vaccine Name
            VStack(alignment: .leading, spacing: 8) {
                Text("Vaccine Name")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                TextField("e.g. FMD Vaccine", text: $vaccineName)
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                    .shadow(color: Color.shadowColor, radius: 5, x: 0, y: 2)
            }
            
            // Vaccine Type
            VStack(alignment: .leading, spacing: 8) {
                Text("Frequency")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Picker("Type", selection: $vaccineType) {
                    ForEach(vaccineTypes, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            // Date Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Scheduled Date")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                DatePicker("Pick a date", selection: $selectedDate, in: Date()...Calendar.current.date(from: DateComponents(year: 2060, month: 12, day: 31))!, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                    .shadow(color: Color.shadowColor, radius: 5, x: 0, y: 2)
                    .accentColor(Color.primaryGreen)
            }
        }
    }
    
    private var saveButton: some View {
        Button(action: saveVaccination) {
            Text("Schedule Vaccination")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(vaccineName.isEmpty ? Color.gray.opacity(0.5) : Color.primaryGreen)
                .cornerRadius(16)
                .shadow(color: Color.primaryGreen.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .disabled(vaccineName.isEmpty || isLoading)
    }
    
    private func saveVaccination() {
        isLoading = true
        
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: selectedDate)
        
        let newVax = VaccinationCreate(vaccine_name: vaccineName, type: vaccineType, planned_date: dateString)
        
        AuthManager.shared.addVaccination(vaccine: newVax) { result in
            isLoading = false
            switch result {
            case .success:
                path.removeLast()
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    AppRootView()
}
