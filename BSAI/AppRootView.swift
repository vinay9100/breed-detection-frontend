import SwiftUI

// MARK: - Navigation Route Enum
enum AppRoute: Hashable {
    case roleSelection
    case login
    case register
    case forgotPassword
    case otpVerification(identifier: String)
    case resetPassword
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
    case yieldForecast
    case breedComparison
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
    // bpaLogin removed — unified LoginView handles both Farmer and BPA
    case bpaRegister
    case bpaForgotPassword
    case bpaOTPVerification(identifier: String)
    case bpaResetPassword
    case bpaDashboard
    case bpaAnalytics
    case bpaReports
    case bpaSearch
    case bpaAnimalRegistration
    case bpaRegistrationReview(data: AnimalRegistrationData)
    case bpaRegistrationSuccess
    case bpaCamera
    case bpaAIProcessing
    case bpaDetectionResult
    case bpaAnimalDetail(data: AnimalRegistrationData)
}

// MARK: - App Root — owns the single NavigationStack
struct AppRootView: View {
    @State private var path: [AppRoute] = []
    @State private var isLaunched = false

    var body: some View {
        ZStack {
            if isLaunched {
                NavigationStack(path: $path) {
                    LoginView(path: $path)
                        .navigationBarHidden(true)
                        .navigationDestination(for: AppRoute.self) { route in
                            viewForRoute(route)
                        }
                }
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

        case .otpVerification(let identifier):
            OTPVerificationView(path: $path, identifier: identifier)
                .navigationBarHidden(true)

        case .resetPassword:
            ResetPasswordView(path: $path)

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

        case .yieldForecast:
            YieldForecastView(path: $path)
                .navigationBarHidden(true)

        case .breedComparison:
            BreedComparisonView(path: $path)
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
        case .bpaOTPVerification(let identifier):
            BPAOTPVerificationView(path: $path, identifier: identifier)
                .navigationBarHidden(true)
        case .bpaResetPassword:
            BPAResetPasswordView(path: $path)
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
        case .bpaCamera:
            BPACameraView(path: $path)
                .navigationBarHidden(true)
        case .bpaAIProcessing:
            BPAAIProcessingView(path: $path)
                .navigationBarHidden(true)
        case .bpaDetectionResult:
            BPADetectionResultView(path: $path)
                .navigationBarHidden(true)
        case .bpaAnimalDetail(let data):
            BPAAnimalDetailView(path: $path, animal: data)
                .navigationBarHidden(true)
        }
    }
}

#Preview {
    AppRootView()
}
