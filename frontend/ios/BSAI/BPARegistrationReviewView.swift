import SwiftUI

struct BPARegistrationReviewView: View {
    @Binding var path: [AppRoute]
    let registrationData: AnimalRegistrationData
    @State private var appeared = false
    @State private var isSubmitting = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        reviewSection(title: "Animal Information", icon: "pawprint.fill", iconColor: Color(hex: "00C853"), items: [
                            ("Ear Tag Number", registrationData.ear_tag_number),
                            ("Animal Name", registrationData.animal_name ?? "Not provided"),
                            ("Species", registrationData.species),
                            ("Sex", registrationData.sex),
                            ("Breed", registrationData.breed),
                            ("Date of Birth", registrationData.dob ?? "Not provided")
                        ])
                        
                        reviewSection(title: "Owner Information", icon: "person.fill", iconColor: .blue, items: [
                            ("Owner Name", registrationData.owner_name),
                            ("Village", registrationData.village),
                            ("District", registrationData.district),
                            ("State", registrationData.state),
                            ("Address", registrationData.address ?? "Not provided")
                        ])
                        
                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        verificationDisclaimerCard
                        
                        actionButtons
                        
                        Spacer(minLength: 40)
                    }
                    .padding(24)
                    .padding(.top, -30)
                }
            }
            
            if isSubmitting {
                loadingOverlay
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        VStack(spacing: 15) {
            HStack(spacing: 20) {
                Button(action: {
                    if !path.isEmpty {
                        _ = path.removeLast()
                    }
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Review Registration")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text("Verify all details before final submission")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
            .padding(.bottom, 60)
        }
        .background(
            LinearGradient(
                colors: [Color(hex: "00C853"), Color(hex: "008D43")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
    
    private func reviewSection(title: String, icon: String, iconColor: Color, items: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                }
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: { path.removeLast() }) {
                    Text("Edit")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(iconColor)
                }
            }
            
            VStack(spacing: 15) {
                ForEach(0..<items.count, id: \.self) { index in
                    HStack(alignment: .top) {
                        Text(items[index].0)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .frame(width: 120, alignment: .leading)
                        
                        Text(items[index].1)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    if index < items.count - 1 {
                        Divider()
                            .opacity(0.5)
                    }
                }
            }
            .padding(15)
            .background(Color.gray.opacity(0.03))
            .cornerRadius(16)
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.shadowColor, radius: 15, x: 0, y: 10)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appeared)
    }
    
    private var verificationDisclaimerCard: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: "checkmark.shield.fill")
                .font(.title3)
                .foregroundColor(Color(hex: "00C853"))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Official Declaration")
                    .font(.system(size: 15, weight: .bold))
                Text("I hereby certify that the information provided is accurate to the best of my knowledge and complies with regional BPA standards.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "00C853").opacity(0.05))
        .cornerRadius(16)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appeared)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                submitRegistration()
            }) {
                HStack(spacing: 12) {
                    Text("Confirm & Submit")
                    Image(systemName: "arrow.right")
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "00C853"), Color(hex: "008D43")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(14)
                .shadow(color: Color(hex: "00C853").opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(ScaleButtonStyle())
            
            Button(action: {
                if !path.isEmpty {
                    path.removeLast()
                }
            }) {
                Text("Go Back")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "1B5E20"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.cardBackground)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: appeared)
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("Submitting to BPA Database...")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
    
    // MARK: - Logic
    
    private func submitRegistration() {
        withAnimation {
            isSubmitting = true
            errorMessage = nil
        }
        
        AuthManager.shared.registerAnimalDetails(animal: registrationData) { result in
            withAnimation {
                isSubmitting = false
                switch result {
                case .success(_):
                    path.append(.bpaRegistrationSuccess)
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    BPARegistrationReviewView(
        path: .constant([]),
        registrationData: AnimalRegistrationData(
            ear_tag_number: "ET-2024-8472",
            animal_name: "Gauri",
            species: "Cattle",
            sex: "Female",
            breed: "Holstein Friesian",
            dob: "2020-05-15",
            owner_name: "Ramesh Kumar",
            address: "Main Street, Sector 12",
            village: "Karnal",
            district: "Karnal",
            state: "Haryana",
            last_image_path: nil
        )
    )
}
