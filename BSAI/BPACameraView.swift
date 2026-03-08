import SwiftUI

struct BPACameraView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    @State private var isFlashOn = false
    
    var body: some View {
        ZStack {
            // Camera Mock
            Rectangle()
                .fill(Color.black)
                .ignoresSafeArea()
            
            // Viewfinder
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                .frame(width: 300, height: 400)
                .overlay(
                    VStack {
                        HStack {
                            cornerMark(rotation: 0)
                            Spacer()
                            cornerMark(rotation: 90)
                        }
                        Spacer()
                        HStack {
                            cornerMark(rotation: 270)
                            Spacer()
                            cornerMark(rotation: 180)
                        }
                    }
                )
            
            VStack {
                HStack {
                    Button(action: { path.removeLast() }) {
                        Image(systemName: "xmark")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .padding(15)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Button(action: { isFlashOn.toggle() }) {
                        Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                            .foregroundColor(isFlashOn ? .yellow : .white)
                            .padding(15)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 50)
                
                Spacer()
                
                VStack(spacing: 25) {
                    Text("Align animal in the frame")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(20)
                    
                    HStack(spacing: 60) {
                        Button(action: {}) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            path.append(.bpaAIProcessing)
                        }) {
                            ZStack {
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                                    .frame(width: 80, height: 80)
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 66, height: 66)
                            }
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
        }
    }
    
    private func cornerMark(rotation: Double) -> some View {
        Image(systemName: "plus")
            .font(.title2)
            .foregroundColor(.white)
            .rotationEffect(.degrees(45))
            .offset(x: 20, y: 20)
            .rotationEffect(.degrees(rotation))
    }
}

#Preview {
    BPACameraView(path: .constant([]))
}
