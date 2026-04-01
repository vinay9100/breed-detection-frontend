import SwiftUI
import UIKit


// MARK: - Shape Utilities
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Button Styles
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Color Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    static var cardBackground: Color {
        Color(.secondarySystemGroupedBackground)
    }
    
    static var appBackground: Color {
        Color(.systemGroupedBackground)
    }
    
    static var secondaryAppBackground: Color {
        Color(.systemBackground)
    }
    
    static var shadowColor: Color {
        Color.black.opacity(0.06)
    }
    
    static var primaryGreen: Color {
        Color(hex: "00C853")
    }
}

// MARK: - Shared Views
struct InsightCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 15) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text(value)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cardBackground)
            .cornerRadius(24)
            .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Generic Input Field
struct InputField<Content: View, Trailing: View>: View {
    let icon: String
    let placeholder: String
    let content: () -> Content
    let trailing: () -> Trailing

    init(icon: String,
         placeholder: String,
         @ViewBuilder content: @escaping () -> Content,
         @ViewBuilder trailing: @escaping () -> Trailing) {
        self.icon = icon
        self.placeholder = placeholder
        self.content = content
        self.trailing = trailing
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.green.opacity(0.7))
                .frame(width: 20)
            content()
            trailing()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.green.opacity(0.22), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

extension InputField where Trailing == EmptyView {
    init(icon: String,
         placeholder: String,
         @ViewBuilder content: @escaping () -> Content) {
        self.init(icon: icon, placeholder: placeholder, content: content, trailing: { EmptyView() })
    }
}

// MARK: - Reusable press animation button style
struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

// MARK: - Image Utilities
extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage? {
        guard size.width > 0 && size.height > 0 else { return nil }
        
        // Calculate aspect ratio
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        if newSize.width <= 0 || newSize.height <= 0 { return nil }
        
        // Use UIGraphicsImageRenderer for better memory efficiency
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
