import SwiftUI

struct AlertRow: View {
    let icon: String
    let message: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(color)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(color)
        }
        .padding()
        .background(color.opacity(0.05))
        .cornerRadius(15)

    }
}
