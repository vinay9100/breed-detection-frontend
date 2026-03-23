import SwiftUI
import PhotosUI

struct CameraView: View {
    @Binding var path: [AppRoute]
    @State private var selectedMode = "Front View"
    @State private var appeared = false
    
    // Image Upload State
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var isUploading = false
    @State private var uploadError: String? = nil
    @State private var showRejectionAlert = false
    @State private var rejectionMessage: String = ""
    
    let modes = ["Front View", "Side Profile", "Full Body"]
    
    var body: some View {
        ZStack {
            // Camera Background (Dark Blue/Gray)
            Color(red: 10/255, green: 20/255, blue: 30/255)
                .ignoresSafeArea()
            
            // Simulation of Camera View
            VStack {
                Spacer()
                VStack(spacing: 15) {
                    Image(systemName: "camera")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.3))
                    Text("Camera View")
                        .font(.headline)
                        .foregroundColor(.gray.opacity(0.3))
                }
                Spacer()
            }
            
            // Top Controls
            VStack {
                HStack {
                    Button(action: {
                        if !path.isEmpty {
                            _ = path.removeLast()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 5) {
                        Image(systemName: "bolt.fill")
                        Text("Front View")
                            .font(.subheadline.bold())
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(Color.green)
                    .cornerRadius(25)
                    
                    Spacer()
                    
                    Button(action: {
                        // Flash or settings
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                Spacer()
                
                // Overlay Message
                VStack(spacing: 8) {
                    Text("Position the animal within the frame")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Ensure good lighting and steady position")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.7))
                .cornerRadius(15)
                .padding(.horizontal, 25)
                .padding(.bottom, 20)
                
                // Bottom Controls
                VStack(spacing: 25) {
                    // Shutter Button
                    Button(action: {
                        simulateCapture()
                    }) {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 80, height: 80)
                            Circle()
                                .fill(Color.green)
                                .frame(width: 65, height: 65)
                        }
                    }
                    .overlay(alignment: .trailing) {
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 50, height: 50)
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                        }
                        .offset(x: 80)
                    }
                    
                    // Mode Picker
                    HStack(spacing: 10) {
                        ForEach(modes, id: \.self) { mode in
                            Button(action: {
                                withAnimation(.spring()) {
                                    selectedMode = mode
                                }
                            }) {
                                Text(mode)
                                    .font(.system(size: 14, weight: selectedMode == mode ? .semibold : .regular))
                                    .foregroundColor(selectedMode == mode ? .white : .gray)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 10)
                                    .background(selectedMode == mode ? Color.white.opacity(0.15) : Color.clear)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity)
                .background(Color(red: 10/255, green: 20/255, blue: 30/255))
            }
        }
        .onAppear {
            appeared = true
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    // Resize immediately to prevent memory crashes
                    let resized = image.size.width > 1024 || image.size.height > 1024 ? 
                        image.resized(to: CGSize(width: 1024, height: 1024)) ?? image : image
                    uploadImage(resized)
                }
            }
        }
        .alert("Image Rejected", isPresented: $showRejectionAlert) {
            Button("Try Again", role: .cancel) { }
        } message: {
            Text(rejectionMessage)
        }
        .overlay {
            if isUploading {
                ZStack {
                    Color.black.opacity(0.6).ignoresSafeArea()
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        Text("Analyzing Image...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
            }
        }
    }
    
    private func simulateCapture() {
        // In a real app, this would use the camera sensor.
        // For simulation, we'll use a placeholder but prepare the pending state.
        AuthManager.shared.pendingImage = UIImage(named: "cow_temp_1")
        withAnimation {
            path.append(.aiProcessing)
        }
    }

    private func uploadImage(_ image: UIImage) {
        isUploading = true
        AuthManager.shared.uploadImageForPrediction(image: image) { result in
            isUploading = false
            switch result {
            case .success(let prediction):
                AuthManager.shared.currentPrediction = prediction
                if let message = prediction.message {
                    // This is the "Not Cattle/Buffalo" rejection
                    self.rejectionMessage = message
                    self.showRejectionAlert = true
                } else {
                    path.append(.detectionResult)
                }
            case .failure(let error):
                self.uploadError = error.localizedDescription
            }
        }
    }
}
