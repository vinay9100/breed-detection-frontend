import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Binding var path: [AppRoute]
    @ObservedObject private var localization = LocalizationManager.shared
    @ObservedObject private var authManager = AuthManager.shared
    @State private var appeared = false
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var location = "India"
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var profileImage: Image?
    @State private var selectedUIImage: UIImage?
    @State private var isLoading = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    private var imageBaseURL: String { AuthManager.shared.baseURL }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    profileImageSection
                    
                    VStack(spacing: 20) {
                        EditInfoField(label: LocalizationManager.shared.t("edit_profile_name"), icon: "person", text: $fullName)
                        EditInfoField(label: LocalizationManager.shared.t("edit_profile_email"), icon: "envelope", text: $email)
                        EditInfoField(label: LocalizationManager.shared.t("edit_profile_phone"), icon: "phone", text: $phoneNumber)
                        EditInfoField(label: LocalizationManager.shared.t("edit_profile_location"), icon: "mappin.circle", text: $location)
                    }
                    .padding(.horizontal, 24)
                    
                    saveButton
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.4)
                        Text("Saving changes...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(30)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(16)
                }
            }
        }
        .alert("Profile Updated!", isPresented: $showSuccessAlert) {
            Button("OK") { path.removeLast() }
        } message: {
            Text("Your profile has been successfully updated.")
        }
        .alert("Update Failed", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            if !appeared {
                fullName = AuthManager.shared.currentUser?.fullName ?? ""
                email = AuthManager.shared.currentUser?.email ?? ""
                phoneNumber = AuthManager.shared.currentUser?.phoneNumber ?? ""
            }
            appeared = true
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        selectedUIImage = uiImage
                        profileImage = Image(uiImage: uiImage)
                    }
                }
            }
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
                    .background(Color.cardBackground)
                    .clipShape(Circle())
                    .shadow(color: Color.shadowColor, radius: 5, x: 0, y: 2)
            }
            
            Text(LocalizationManager.shared.t("edit_profile_title"))
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 10)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var profileImageSection: some View {
        VStack(spacing: 15) {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                ZStack(alignment: .bottomTrailing) {
                    if let profileImage = profileImage {
                        profileImage
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else if let photoPath = AuthManager.shared.currentUser?.profilePhoto {
                        AsyncImage(url: URL(string: "\(imageBaseURL)/\(photoPath)")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } placeholder: {
                            Circle()
                                .fill(Color(hex: "00C853"))
                                .frame(width: 120, height: 120)
                            ProgressView()
                        }
                    } else {
                        Circle()
                            .fill(Color(hex: "00C853"))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    }
                    
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 32, height: 32)
                            .shadow(radius: 4)
                        
                        Image(systemName: "camera.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                    }
                }
            }
            
            Text(LocalizationManager.shared.t("edit_profile_tap_photo"))
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.95)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)
    }
    
    private var saveButton: some View {
        Button(action: { 
            isLoading = true
            if let image = selectedUIImage {
                AuthManager.shared.uploadProfilePhoto(image: image) { result in
                    switch result {
                    case .success(let photoURL):
                        updateProfile(photoURL: photoURL)
                    case .failure(let error):
                        print("Upload failed: \(error.localizedDescription)")
                        isLoading = false
                    }
                }
            } else {
                updateProfile(photoURL: nil)
            }
        }) {
            Text(LocalizationManager.shared.t("edit_profile_save"))
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.green)
                .cornerRadius(18)
                .shadow(color: Color.green.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: appeared)
    }
    
    private func updateProfile(photoURL: String?) {
        AuthManager.shared.updateProfile(fullName: fullName, phoneNumber: phoneNumber, profilePhoto: photoURL) { result in
            switch result {
            case .success:
                // Refresh user data from server to ensure local state is in sync
                AuthManager.shared.fetchMe { _ in
                    DispatchQueue.main.async {
                        isLoading = false
                        showSuccessAlert = true
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
}

struct EditInfoField: View {
    let label: String
    let icon: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Text(label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            
            TextField(label, text: $text)
                .font(.system(size: 16, weight: .medium))
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.shadowColor, lineWidth: 1)
                )
        }
    }
}

#Preview {
    EditProfileView(path: .constant([]))
}
