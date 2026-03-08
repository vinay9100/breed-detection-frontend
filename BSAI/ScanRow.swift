import SwiftUI

struct ScanRow: View {
    @Binding var path: [AppRoute]
    let breed: String
    let confidence: String
    let time: String
    var imageName: String = ""
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                path.append(.detectionResult)
            }
        }) {
            HStack(spacing: 15) {
                // Image Section
                Group {
                    if !imageName.isEmpty, let image = UIImage(named: imageName) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 70, height: 70)
                            .cornerRadius(15)
                    } else {
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 70, height: 70)
                                .cornerRadius(15)
                            
                            Image(systemName: "pawprint.fill")
                                .foregroundColor(Color(hex: "00A661").opacity(0.3))
                        }
                    }
                }

                
                VStack(alignment: .leading, spacing: 6) {
                    Text(breed)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                        Text(time)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(confidence)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "00A661"))
                    Text("Confidence")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray.opacity(0.4))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(25)
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}





