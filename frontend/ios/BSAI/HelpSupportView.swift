import SwiftUI

struct HelpSupportView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 30) {
                    helpHeaderCard
                    
                    contactSection
                    
                    faqsSection
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
                .padding(.horizontal, 24)
            }
        }
        .background(Color(hex: "F8FBF9").ignoresSafeArea())
        .onAppear {
            appeared = true
        }
    }
    
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
            
            Text("Help & Support")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 10)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var helpHeaderCard: some View {
        HStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 56, height: 56)
                Image(systemName: "questionmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("How can we help?")
                    .font(.system(size: 18, weight: .bold))
                Text("We're here to assist you")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.95)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)
    }
    
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Contact Support")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary.opacity(0.8))
            
            VStack(spacing: 12) {
                Button(action: {
                    if let url = URL(string: "mailto:breedsureai@gmail.com") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    ContactRow(icon: "envelope.fill", iconColor: .purple, title: "Email Support", subtitle: "breedsureai@gmail.com", detail: "Response in 24h")
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appeared)
    }
    
    private var faqsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Frequently Asked Questions")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary.opacity(0.8))
            
            VStack(spacing: 12) {
                FAQRow(question: "How accurate is the breed detection?", category: "Scanning")
                FAQRow(question: "How do I add multiple animals?", category: "Management")
                FAQRow(question: "Can I export my reports?", category: "Reports")
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: appeared)
    }
}

struct ContactRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let detail: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                Text(detail)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(iconColor)
                    .padding(.top, 2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundColor(.gray.opacity(0.3))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
    }
}

struct FAQRow: View {
    let question: String
    let category: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(question)
                    .font(.system(size: 15, weight: .semibold))
                Text(category)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundColor(.gray.opacity(0.3))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    HelpSupportView(path: .constant([]))
}
