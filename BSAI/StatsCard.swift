import SwiftUI

struct StatsCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    var action: (() -> Void)? = nil
    
    @State private var appeared = false
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            VStack(alignment: .leading, spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(color.opacity(0.1))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(color)
                }
                .scaleEffect(appeared ? 1 : 0.5)
                .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1), value: appeared)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.primary)
                        .scaleEffect(appeared ? 1 : 0.8)
                        .opacity(appeared ? 1 : 0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.2), value: appeared)
                    
                    Text(label)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 5)
                        .animation(.easeOut(duration: 0.4).delay(0.3), value: appeared)
                }
            }
            .padding(18)
            .frame(width: 135, height: 170, alignment: .topLeading)
            .background(Color.cardBackground)
            .cornerRadius(25)
            .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
        .onAppear {
            appeared = true
        }
    }
}


#Preview {
    HStack {
        StatsCard(icon: "viewfinder", value: "24", label: "Total Scans", color: .green)
        StatsCard(icon: "waveform.path.ecg", value: "96.8%", label: "Avg. Confidence", color: .blue)
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
