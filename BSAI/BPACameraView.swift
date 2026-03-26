import SwiftUI
import PhotosUI

struct BPACameraView: View {
    @Binding var path: [AppRoute]
    let earTag: String?
    @State private var appeared = false
    @State private var isFlashOn = false
    @State private var selectedItem: PhotosPickerItem? = nil
    
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
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            // In simulation, we'll use a placeholder for now
                            // but in a real app, this would be a camera capture
                            AuthManager.shared.pendingImage = UIImage(named: "cow_temp_1")
                            path.append(.bpaAIProcessing(earTag: earTag))
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
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    // Resize immediately to prevent memory crashes
                    let resized = image.size.width > 1024 || image.size.height > 1024 ? 
                        image.resized(to: CGSize(width: 1024, height: 1024)) ?? image : image
                        
                    await MainActor.run {
                        AuthManager.shared.pendingImage = resized
                        path.append(.bpaAIProcessing(earTag: earTag))
                    }
                }
            }
        }
        .onAppear {
            selectedItem = nil
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
    BPACameraView(path: .constant([]), earTag: nil)
}
