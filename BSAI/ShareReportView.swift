import SwiftUI

struct ShareReportView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    @State private var reportURL = "https://breedsure.ai/reports/feb-20"
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    heroCard
                    shareOptionsSection
                    reportSettingsCard
                    securityNote
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .background(Color(hex: "F8FBF9").ignoresSafeArea())
        .onAppear {
            appeared = true
        }
    }
    
    // MARK: - Subviews
    
    private var navigationBar: some View {
        HStack {
            Button(action: {
                if !path.isEmpty {
                    _ = path.removeLast()
                }
            }) {
                Image(systemName: "arrow.left")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            Text("Share Report")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 10)
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Share Monthly Report")
                .font(.title3.bold())
            Text("Share your herd performance report with veterinarians, partners, or advisors")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding(25)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
        .padding(.top, 10)
    }
    
    private var shareOptionsSection: some View {
        VStack(spacing: 16) {
            ShareOptionRow(icon: "envelope.fill", iconColor: .blue, title: "Email", subtitle: "Send via email")
            ShareOptionRow(icon: "message.fill", iconColor: .green, title: "WhatsApp", subtitle: "Share via WhatsApp")
            
            // Copy Link Card
            VStack(alignment: .leading, spacing: 15) {
                HStack(spacing: 15) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.purple.opacity(0.1))
                            .frame(width: 44, height: 44)
                        Image(systemName: "link")
                            .foregroundColor(.purple)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Copy Link")
                            .font(.headline)
                        Text("Share report link")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack(spacing: 12) {
                    Text(reportURL)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    
                    Button(action: {}) {
                        Text("Copy")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.green)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.green.opacity(0.05))
                            .cornerRadius(12)
                    }
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(25)
            .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
        }
    }
    
    private var reportSettingsCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Report Settings")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 15) {
                ShareToggleRow(label: "Include financial data")
                ShareToggleRow(label: "Include breed details")
                ShareToggleRow(label: "Include health metrics")
            }
        }
        .padding(25)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 5)
    }
    
    private var securityNote: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .foregroundColor(Color(hex: "A67C00"))
            Text("Shared reports are password-protected and expire after 7 days")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "A67C00"))
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "FFF9E6"))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color(hex: "FFECB3"), lineWidth: 1)
        )
    }
}

struct ShareOptionRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.3))
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(22)
            .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ShareToggleRow: View {
    let label: String
    @State private var isOn = true
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.green)
        }
    }
}

#Preview {
    ShareReportView(path: .constant([]))
}
