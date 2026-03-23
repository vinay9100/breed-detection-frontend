import SwiftUI

struct BPASearchView: View {
    @Binding var path: [AppRoute]
    @State private var searchText = ""
    @State private var appeared = false
    @State private var allAnimals: [AnimalRegistrationData] = []
    @State private var isLoading = false
    
    var filteredAnimals: [AnimalRegistrationData] {
        if searchText.isEmpty {
            return allAnimals
        } else {
            return allAnimals.filter { animal in
                animal.ear_tag_number.localizedCaseInsensitiveContains(searchText) ||
                (animal.animal_name ?? "").localizedCaseInsensitiveContains(searchText) ||
                animal.owner_name.localizedCaseInsensitiveContains(searchText) ||
                animal.village.localizedCaseInsensitiveContains(searchText) ||
                animal.breed.localizedCaseInsensitiveContains(searchText) ||
                animal.species.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                searchHeader
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 30) {
                        searchBarCard
                        
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if filteredAnimals.isEmpty && !searchText.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("No animals found matching \"\(searchText)\"")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                        } else {
                            if searchText.isEmpty {
                                quickFiltersSection
                                recentSearchesSection
                            }
                            
                            searchResultsSection
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, -15)
                }
            }
        }
        .onAppear {
            loadAnimals()
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }
    
    private func loadAnimals() {
        isLoading = true
        AuthManager.shared.fetchAnimals { result in
            isLoading = false
            if case .success(let animals) = result {
                allAnimals = animals
            }
        }
    }
    
    private var searchHeader: some View {
        VStack(spacing: 15) {
            HStack(alignment: .top) {
                Button(action: {
                    if !path.isEmpty {
                        _ = path.removeLast()
                    }
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Search Animal")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Text("Find by Ear Tag ID, Owner, or Location")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
            .padding(.bottom, 30)
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
    
    private var searchBarCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 15) {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                TextField("Enter Ear Tag ID, Owner Name, or Villa...", text: $searchText)
                    .font(.system(size: 16))
            }
            .padding(20)
            .background(Color.blue.opacity(0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.blue.opacity(0.15), lineWidth: 1)
            )
        }
        .padding(24)
        .background(Color.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 10)
        .padding(.horizontal, 24)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appeared)
    }
    
    private var quickFiltersSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Quick Filters")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
                .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterCapsule(label: "Cattle", action: { searchText = "Cattle" })
                    FilterCapsule(label: "Buffalo", action: { searchText = "Buffalo" })
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Featured Animals")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
                .padding(.horizontal, 24)
            
            if allAnimals.isEmpty {
                Text("No animals registered yet")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 24)
            } else {
                VStack(spacing: 12) {
                    ForEach(allAnimals.prefix(3), id: \.ear_tag_number) { animal in
                        SearchResultRow(id: animal.ear_tag_number, name: animal.animal_name, breed: animal.breed, owner: animal.owner_name) {
                            path.append(.bpaAnimalDetail(data: animal))
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(searchText.isEmpty ? "All Animals" : "Search Results")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
                .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
                ForEach(filteredAnimals, id: \.ear_tag_number) { animal in
                    SearchResultRow(id: animal.ear_tag_number, name: animal.animal_name, breed: animal.breed, owner: animal.owner_name) {
                        path.append(.bpaAnimalDetail(data: animal))
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

struct SearchResultRow: View {
    let id: String
    let name: String?
    let breed: String
    let owner: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "00C853").opacity(0.1))
                        .frame(width: 48, height: 48)
                    Image(systemName: "pawprint.fill")
                        .foregroundColor(Color(hex: "00C853"))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name ?? id)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    Text("\(id) • \(breed) • \(owner)")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray.opacity(0.4))
            }
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 2)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.gray.opacity(0.1), lineWidth: 1))
        }
    }
}

struct FilterCapsule: View {
    let label: String
    var action: () -> Void = {}
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.cardBackground)
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.15), lineWidth: 1))
                .foregroundColor(.primary)
        }
    }
}

struct RecentSearchRow: View {
    let label: String
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(.primary.opacity(0.8))
            Spacer()
        }
        .padding(18)
        .background(Color.cardBackground)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 2)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.1), lineWidth: 1))
    }
}

#Preview {
    BPASearchView(path: .constant([]))
}
