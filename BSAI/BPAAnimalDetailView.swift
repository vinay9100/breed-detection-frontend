import SwiftUI

struct BPAAnimalDetailView: View {
    @Binding var path: [AppRoute]
    let animal: AnimalRegistrationData
    @State private var appeared = false
    
    @State private var detectionHistory: [RecentActivity] = []
    @State private var isLoadingHistory = false
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        animalHeroCard
                        
                        ownerInfoSection
                        
                        breedHistoryTimeline
                        
                        Spacer(minLength: 40)
                    }
                    .padding(24)
                    .padding(.top, -30)
                }
            }
        }
        .onAppear {
            loadHistory()
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }
    
    private func loadHistory() {
        isLoadingHistory = true
        AuthManager.shared.fetchAnimalHistory(earTag: animal.ear_tag_number) { result in
            isLoadingHistory = false
            if case .success(let data) = result {
                self.detectionHistory = data
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 15) {
            HStack {
                Button(action: {
                    if !path.isEmpty {
                        _ = path.removeLast()
                    }
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Circle())
                }
                
                Text("Animal Profile")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.leading, 10)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 25)
        }
        .background(
            LinearGradient(
                colors: [Color(red: 0, green: 200/255, blue: 83/255), Color(red: 0, green: 141/255, blue: 67/255)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
    
    private var animalHeroCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 100, height: 100)
                    
                    if let path = animal.last_image_path, let url = URL(string: "\(AuthManager.shared.baseURL)/\(path)") {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        } placeholder: {
                            ProgressView()
                                .frame(width: 100, height: 100)
                        }
                    } else {
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color(red: 0, green: 200/255, blue: 83/255))
                    }
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(animal.animal_name ?? animal.breed)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                    
                    if animal.animal_name != nil {
                        Text(animal.breed)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 8) {
                        Text(animal.ear_tag_number)
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(red: 0, green: 200/255, blue: 83/255).opacity(0.1))
                            .foregroundColor(Color(red: 0, green: 200/255, blue: 83/255))
                            .cornerRadius(8)
                        
                        Text("Verified")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.blue)
                    }
                }
                Spacer()
            }
            
            Divider()
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ProfileStat(label: "Species", value: animal.species)
                ProfileStat(label: "Sex", value: animal.sex)
                ProfileStat(label: "DOB", value: animal.dob ?? "N/A")
                ProfileStat(label: "Health", value: "Excellent")
                ProfileStat(label: "Status", value: "Registered")
                ProfileStat(label: "Region", value: animal.village)
            }
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.shadowColor, radius: 15, x: 0, y: 10)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }
    
    private var ownerInfoSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.blue)
                Text("Owner Information")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 15) {
                HStack(spacing: 15) {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 44, height: 44)
                        .overlay(Text(String(animal.owner_name.prefix(2)).uppercased()).font(.system(size: 16, weight: .bold)).foregroundColor(.blue))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(animal.owner_name)
                            .font(.system(size: 16, weight: .bold))
                        Text("\(animal.village), \(animal.district), \(animal.state)")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                
                if let addr = animal.address {
                    Divider()
                    Text(addr)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.shadowColor, radius: 15, x: 0, y: 10)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring().delay(0.1), value: appeared)
    }
    
    private var breedHistoryTimeline: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "history")
                    .foregroundColor(.purple)
                Text("Breed Detection History")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                if isLoadingHistory {
                    ProgressView()
                        .padding()
                } else if detectionHistory.isEmpty {
                    TimelineItem(date: "Registration", title: "Official BPA Record", subtitle: "Registered by BPA Officer", icon: "sparkles", color: .purple, isFirst: true, isLast: true)
                } else {
                    ForEach(Array(detectionHistory.enumerated()), id: \.element.id) { index, det in
                        TimelineItem(
                            date: det.time,
                            title: det.title,
                            subtitle: det.subtitle,
                            icon: "waveform.path.ecg",
                            color: .green,
                            isFirst: index == 0,
                            isLast: index == detectionHistory.count - 1
                        )
                    }
                    
                    // Always show the base registration at the bottom if we have history
                    TimelineItem(
                        date: "Registration",
                        title: "Official BPA Record",
                        subtitle: "Registration process completed",
                        icon: "checkmark.seal",
                        color: .purple,
                        isFirst: false,
                        isLast: true
                    )
                }
            }
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.shadowColor, radius: 15, x: 0, y: 10)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring().delay(0.2), value: appeared)
    }
}

struct ProfileStat: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.primary)
        }
    }
}

struct OwnerDetailItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 14, weight: .bold))
        }
    }
}

struct TimelineItem: View {
    let date: String
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    var isFirst: Bool = false
    var isLast: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(spacing: 0) {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
                    .background(Circle().stroke(color.opacity(0.2), lineWidth: 4))
                
                if !isLast {
                    Rectangle()
                        .fill(color.opacity(0.2))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(date)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
                
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .padding(.bottom, isLast ? 0 : 25)
            }
            
            Spacer()
        }
    }
}

#Preview {
    BPAAnimalDetailView(
        path: .constant([]),
        animal: AnimalRegistrationData(
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
