import SwiftUI

struct BPAAnimalRegistrationView: View {
    @Binding var path: [AppRoute]
    
    @State private var earTagNumber = "ET-"
    @State private var animalName = ""
    @State private var species = ""
    @State private var sex = ""
    @State private var breed = ""
    @State private var dob = ""
    @State private var ownerName = ""
    @State private var phoneNumber = ""
    @State private var address = ""
    @State private var village = ""
    @State private var district = ""
    @State private var stateName = ""
    @State private var showDatePicker = false
    @State private var selectedDate = Calendar.current.date(byAdding: .month, value: -18, to: Date()) ?? Date()
    @State private var appeared = false
    
    @ObservedObject private var authManager = AuthManager.shared
    
    let indianStates: [String: [String]] = [
        "Andhra Pradesh": ["Visakhapatnam", "Vijayawada", "Guntur", "Nellore"],
        "Arunachal Pradesh": ["Itanagar", "Tawang", "Ziro"],
        "Assam": ["Guwahati", "Dibrugarh", "Silchar", "Tezpur"],
        "Bihar": ["Patna", "Gaya", "Muzaffarpur", "Bhagalpur"],
        "Chhattisgarh": ["Raipur", "Bhilai", "Bilaspur"],
        "Goa": ["North Goa", "South Goa"],
        "Gujarat": ["Ahmedabad", "Surat", "Vadodara", "Rajkot"],
        "Haryana": ["Faridabad", "Gurugram", "Panipat", "Ambala"],
        "Himachal Pradesh": ["Shimla", "Dharamshala", "Manali"],
        "Jharkhand": ["Ranchi", "Jamshedpur", "Dhanbad"],
        "Karnataka": ["Bengaluru", "Mysuru", "Mangaluru", "Hubballi"],
        "Kerala": ["Thiruvananthapuram", "Kochi", "Kozhikode", "Thrissur"],
        "Madhya Pradesh": ["Indore", "Bhopal", "Jabalpur", "Gwalior"],
        "Maharashtra": ["Mumbai", "Pune", "Nagpur", "Nashik"],
        "Manipur": ["Imphal", "Thoubal", "Bishnupur"],
        "Meghalaya": ["Shillong", "Tura", "Jowai"],
        "Mizoram": ["Aizawl", "Lunglei", "Champhai"],
        "Nagaland": ["Kohima", "Dimapur", "Mokokchung"],
        "Odisha": ["Bhubaneswar", "Cuttack", "Rourkela", "Puri"],
        "Punjab": ["Ludhiana", "Amritsar", "Jalandhar", "Patiala"],
        "Rajasthan": ["Jaipur", "Jodhpur", "Udaipur", "Kota"],
        "Sikkim": ["Gangtok", "Namchi", "Pelling"],
        "Tamil Nadu": ["Chennai", "Coimbatore", "Madurai", "Tiruchirappalli"],
        "Telangana": ["Hyderabad", "Warangal", "Nizamabad", "Karimnagar"],
        "Tripura": ["Agartala", "Udaipur", "Dharmanagar"],
        "Uttar Pradesh": ["Lucknow", "Kanpur", "Varanasi", "Agra"],
        "Uttarakhand": ["Dehradun", "Haridwar", "Roorkee", "Nainital"],
        "West Bengal": ["Kolkata", "Asansol", "Siliguri", "Durgapur"]
    ]
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        animalInformationCard
                        ownerInformationCard
                        
                        actionButtons
                        
                        Spacer(minLength: 40)
                    }
                    .padding(24)
                    .padding(.top, -15)
                }
            }
        }
        .sheet(isPresented: $showDatePicker) {
            NavigationView {
                DatePicker(
                    "Select Date of Birth",
                    selection: $selectedDate,
                    in: ...Calendar.current.date(byAdding: .month, value: -18, to: Date())!,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                .navigationTitle("Date of Birth")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "dd/MM/yyyy"
                            dob = formatter.string(from: selectedDate)
                            showDatePicker = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
        .onChange(of: authManager.confirmedPrediction) { _, confirmed in
            if let prediction = confirmed, prediction.message == nil {
                // REQUIRED: Auto-fill from AI scan results AFTER user confirms
                if let detectedBreed = prediction.breed_name {
                    print("✅ Applying confirmed breed: \(detectedBreed)")
                    breed = detectedBreed
                    
                    // Also auto-suggest as animal name if empty/generic
                    if animalName.isEmpty || animalName == "Toda" {
                        animalName = detectedBreed
                    }
                }
                
                if let type = prediction.animal_type {
                    if type.lowercased() == "cow" {
                        species = "Cattle"
                    } else {
                        species = type
                    }
                }
                
                // Clear the confirmation so we don't re-apply it unnecessarily
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    authManager.confirmedPrediction = nil
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 15) {
            HStack(spacing: 20) {
                Button(action: {
                    if !path.isEmpty {
                        _ = path.removeLast()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.left")
                            .font(.title3.bold())
                        Text("Back to Dashboard")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Animal Registration")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text("Register new animal with AI assistance")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)   // reduced header height
            .padding(.bottom, 25)
        }
            .background(
                LinearGradient(
                    colors: [Color.primaryGreen, Color(hex: "008D43")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
    }
    
    private var animalInformationCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 0, green: 200/255, blue: 83/255).opacity(0.1))
                        .frame(width: 36, height: 36)
                    Image(systemName: "tag.fill")
                        .foregroundColor(Color(red: 0, green: 200/255, blue: 83/255))
                }
                Text("Animal Information")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            VStack(alignment: .leading, spacing: 15) {
                
                inputField(label: "Ear Tag Number *", placeholder: "ET-2024-XXXX", text: $earTagNumber)
                
                inputField(label: "Animal Name", placeholder: "Enter animal name or alias (Optional)", text: $animalName)
                
                HStack(spacing: 15) {
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Species *")
                            .font(.system(size: 14, weight: .semibold))
                        
                        Menu {
                            Button("Cattle") { species = "Cattle" }
                            Button("Buffalo") { species = "Buffalo" }
                        } label: {
                            HStack {
                                Text(species.isEmpty ? "Select" : species)
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sex *")
                            .font(.system(size: 14, weight: .semibold))
                        
                        Menu {
                            Button("Male") { sex = "Male" }
                            Button("Female") { sex = "Female" }
                        } label: {
                            HStack {
                                Text(sex.isEmpty ? "Select" : sex)
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text("Breed (AI or Manual)")
                        .font(.system(size: 14, weight: .semibold))
                    
                    HStack {
                        
                        TextField("Enter breed manually or use AI", text: $breed)
                            .font(.system(size: 15))
                        
                        Button(action: {
                            hideKeyboard()
                            path.append(.bpaCamera(earTag: earTagNumber))
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "camera.fill")
                                Text("AI Scan")
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(red: 0, green: 141/255, blue: 67/255))
                            .cornerRadius(10)
                        }
                    }
                    .padding(8)
                    .padding(.leading, 8)
                    .background(Color.primaryGreen.opacity(0.05))
                    .cornerRadius(12)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12))
                        Text("Use AI scan OR enter breed manually")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.purple)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date of Birth")
                        .font(.system(size: 14, weight: .semibold))
                    
                    Button(action: {
                        showDatePicker = true
                    }) {
                        HStack {
                            Text(dob.isEmpty ? "DD/MM/YYYY" : dob)
                                .foregroundColor(dob.isEmpty ? .secondary : .primary)
                            Spacer()
                            Image(systemName: "calendar")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    }
                    
                    Text("* Animal must be at least 1.5 years old")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
            }
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 15)
    }
    
    private var ownerInformationCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 36, height: 36)
                    Image(systemName: "person.fill")
                        .foregroundColor(.blue)
                }
                Text("Owner Information")
                    .font(.system(size: 18, weight: .bold))
            }
            
            VStack(alignment: .leading, spacing: 15) {
                
                inputField(label: "Owner Name *", placeholder: "Full name", text: $ownerName)
                
                inputField(label: "Address", placeholder: "Street address", text: $address)
                
                HStack(spacing: 15) {
                    inputField(label: "Village *", placeholder: "Village name", text: $village)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("District *")
                            .font(.system(size: 14, weight: .semibold))
                        
                        Menu {
                            if stateName.isEmpty {
                                Text("Select State First")
                            } else if let districts = indianStates[stateName] {
                                ForEach(districts, id: \.self) { dist in
                                    Button(action: { district = dist }) {
                                        Text(dist)
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(district.isEmpty ? "District" : district)
                                    .foregroundColor(district.isEmpty ? .secondary : .primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("State *")
                        .font(.system(size: 14, weight: .semibold))
                    
                    Menu {
                        ForEach(indianStates.keys.sorted(), id: \.self) { state in
                            Button(action: {
                                stateName = state
                                district = "" // reset district when state changes
                            }) {
                                Text(state)
                            }
                        }
                    } label: {
                        HStack {
                            Text(stateName.isEmpty ? "State name" : stateName)
                                .foregroundColor(stateName.isEmpty ? .secondary : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 15)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            
            Button(action: {
                let registrationData = AnimalRegistrationData(
                    ear_tag_number: earTagNumber,
                    animal_name: animalName.isEmpty ? nil : animalName,
                    species: species,
                    sex: sex,
                    breed: breed,
                    dob: dob.isEmpty ? nil : dob,
                    owner_name: ownerName,
                    address: address.isEmpty ? nil : address,
                    village: village,
                    district: district,
                    state: stateName,
                    last_image_path: nil
                )
                path.append(.bpaRegistrationReview(data: registrationData))
            }) {
                Text("Continue to Review")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 41/255, green: 98/255, blue: 255/255), Color(red: 21/255, green: 101/255, blue: 192/255)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
            }
            
            Button(action: {
                if !path.isEmpty {
                    path.removeLast()
                }
            }) {
                Text("Cancel")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 27/255, green: 94/255, blue: 32/255))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.cardBackground)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
            }
        }
    }
    
    private func inputField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Text(label)
                .font(.system(size: 14, weight: .semibold))
            
            TextField(placeholder, text: text)
                .font(.system(size: 15))
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
        }
    }
}

#Preview {
    BPAAnimalRegistrationView(path: .constant([]))
}
