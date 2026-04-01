import SwiftUI
import UIKit

struct SettingsView: View {
    @Binding var path: [AppRoute]
    @ObservedObject private var localization = LocalizationManager.shared
    @State private var appeared = false
    
    // App Preferences
    @AppStorage("app_language") private var appLanguage: String = "en"
    @State private var selectedLanguage: Language = .english
    @State private var showLanguagePicker = false
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var notificationsEnabled = true
    @State private var biometricLock = false
    @State private var autoSync = true
    @State private var locationServices = true
    @State private var hapticFeedback = true
    
    // Animation States
    @State private var languageChangeTrigger = false
    
    enum Language: String, CaseIterable, Identifiable {
        case english = "en"
        case hindi = "hi"
        case telugu = "te"
        case tamil = "ta"
        case kannada = "kn"
        
        var id: String { self.rawValue }
        
        var title: String {
            switch self {
            case .english: return "English"
            case .hindi: return "Hindi"
            case .telugu: return "Telugu"
            case .tamil: return "Tamil"
            case .kannada: return "Kannada"
            }
        }
        
        var nativeName: String {
            switch self {
            case .english: return "English"
            case .hindi: return "हिन्दी"
            case .telugu: return "తెలుగు"
            case .tamil: return "தமிழ்"
            case .kannada: return "ಕನ್ನಡ"
            }
        }
        
        var flag: String {
            switch self {
            case .english: return "🇺🇸"
            default: return "🇮🇳"
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                premiumNavigationBar
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        
                        // Language Section
                        languageSelectionCard
                        
                        // Notifications & Security
                        settingsSection(title: localization.t("settings_system")) {
                            SettingsToggleRow(icon: "moon.stars.fill", iconColor: .indigo, title: localization.t("settings_dark_mode"), isOn: $isDarkMode)
                            SettingsToggleRow(icon: "bell.badge.fill", iconColor: .orange, title: localization.t("settings_push_notifications"), isOn: $notificationsEnabled)
                            SettingsToggleRow(icon: "faceid", iconColor: .green, title: localization.t("settings_biometric"), isOn: $biometricLock)
                            SettingsToggleRow(icon: "hand.tap.fill", iconColor: .blue, title: localization.t("settings_haptic"), isOn: $hapticFeedback)
                        }
                        
                        // Data & Sync
                        settingsSection(title: localization.t("settings_data")) {
                            SettingsToggleRow(icon: "arrow.triangle.2.circlepath", iconColor: .purple, title: localization.t("settings_auto_sync"), isOn: $autoSync)
                            SettingsToggleRow(icon: "location.fill", iconColor: .red, title: localization.t("settings_location"), isOn: $locationServices)
                        }
                        
                        // About Section
                        settingsSection(title: localization.t("settings_about")) {
                            SettingsActionRow(icon: "info.circle.fill", iconColor: .blue, title: localization.t("settings_version"), value: "v2.1.0 (Stable)") {
                                // Action
                            }
                        }
                        
                        Spacer(minLength: 60)
                    }
                    .padding(24)
                }
            }
            
            // Language Picker Overlay
            if showLanguagePicker {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showLanguagePicker = false
                        }
                    }
                
                languagePickerSheet
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(10)
            }
            
            // Language Change Flash Effect
            if languageChangeTrigger {
                Color.white.opacity(0.8)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation { languageChangeTrigger = false }
                        }
                    }
            }
        }
        .onAppear {
            if let lang = Language(rawValue: appLanguage) {
                selectedLanguage = lang
            }
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }
    
    // MARK: - Components
    
    private var premiumNavigationBar: some View {
        HStack {
            Button(action: { 
                if !path.isEmpty {
                    _ = path.removeLast()
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(12)
                    .background(Color.cardBackground)
                    .clipShape(Circle())
                    .shadow(color: Color.shadowColor, radius: 5, x: 0, y: 2)
            }
            
            Spacer()
            
            Text(localization.t("settings_title"))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Empty space for balance
            Rectangle()
                .fill(Color.clear)
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 15)
        .background(Color.cardBackground)
    }
    
    private var languageSelectionCard: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showLanguagePicker = true
            }
        }) {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "00A661").opacity(0.1))
                            .frame(width: 44, height: 44)
                        Image(systemName: "globe")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "00A661"))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(localization.t("settings_app_language"))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                        Text("\(localization.t("settings_selected")): \(selectedLanguage.title) (\(selectedLanguage.nativeName))")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.secondary.opacity(0.5))
                }
            }
            .padding(20)
            .background(Color.cardBackground)
            .cornerRadius(25)
            .shadow(color: Color.shadowColor, radius: 15, x: 0, y: 8)
        }
        .buttonStyle(ScaleButtonStyle())
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appeared)
    }
    
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                content()
            }
            .background(Color.cardBackground)
            .cornerRadius(25)
            .shadow(color: Color.shadowColor, radius: 15, x: 0, y: 8)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appeared)
    }
    
    private var languagePickerSheet: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 40, height: 5)
                .padding(.vertical, 12)
            
            Text(localization.t("settings_select_language"))
                .font(.system(size: 18, weight: .bold))
                .padding(.bottom, 20)
            
            VStack(spacing: 8) {
                ForEach(Language.allCases) { language in
                    Button(action: {
                        withAnimation {
                            selectedLanguage = language
                            appLanguage = language.rawValue
                            languageChangeTrigger = true
                            showLanguagePicker = false
                        }
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }) {
                        HStack(spacing: 15) {
                            Text(language.flag)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(language.title)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                Text(language.nativeName)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedLanguage == language {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "00A661"))
                                    .font(.title3)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 20)
                        .background(selectedLanguage == language ? Color(hex: "00A661").opacity(0.05) : Color.clear)
                        .cornerRadius(15)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.cardBackground)
        .clipShape(RoundedCorner(radius: 35, corners: [.topLeft, .topRight]))
        .frame(maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
    }
}

struct SettingsActionRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(iconColor)
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !value.isEmpty {
                    Text(value)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary.opacity(0.3))
            }
            .padding(16)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
            }
            
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(Color(hex: "00A661"))
                .labelsHidden()
                .scaleEffect(0.9)
        }
        .padding(16)
    }
}


#Preview {
    SettingsView(path: .constant([]))
}
