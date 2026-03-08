import SwiftUI

struct BreedComparisonView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    
    // Default to Holstein as "Detected" if coming from scan
    @State private var detectedBreed: BreedInfo = BreedRepository.allBreeds[0]
    @State private var comparisonBreed: BreedInfo = BreedRepository.allBreeds[1]
    
    @State private var showBreedPicker = false
    @State private var pickingForDetected = false
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    headerText
                    
                    VStack(spacing: 16) {
                        // Detected Breed Card
                        ComparisonBreedCard(
                            breed: detectedBreed,
                            label: "Detected Breed",
                            isDetected: true,
                            delay: 0.1,
                            appeared: appeared
                        ) {
                            pickingForDetected = true
                            showBreedPicker = true
                        }
                        
                        // VS Badge
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 40, height: 40)
                                .shadow(color: .black.opacity(0.1), radius: 5)
                            Text("VS")
                                .font(.system(size: 14, weight: .black))
                                .foregroundColor(.green)
                        }
                        .zIndex(1)
                        .padding(.vertical, -25)
                        
                        // Comparison Breed Card
                        ComparisonBreedCard(
                            breed: comparisonBreed,
                            label: "Compare Against",
                            isDetected: false,
                            delay: 0.2,
                            appeared: appeared
                        ) {
                            pickingForDetected = false
                            showBreedPicker = true
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    featureComparisonTable
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .background(Color(hex: "F8FBF9").ignoresSafeArea())
        .sheet(isPresented: $showBreedPicker) {
            BreedPickerView(selectedBreed: pickingForDetected ? $detectedBreed : $comparisonBreed)
        }
        .onAppear {
            appeared = true
        }
    }
    
    // MARK: - Subviews
    
    private var navigationBar: some View {
        HStack {
            Button(action: {
                _ = path.removeLast()
            }) {
                Image(systemName: "arrow.left")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            Text("Breed Comparison")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 10)
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var headerText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Benchmark Analysis")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.green)
            Text("Compare Performance")
                .font(.system(size: 24, weight: .bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 10)
    }
    
    private var featureComparisonTable: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Feature Comparison")
                .font(.headline)
            
            VStack(spacing: 20) {
                ComparisonTableRow(label: "Milk Production", v1: detectedBreed.productivity, v2: comparisonBreed.productivity)
                ComparisonTableRow(label: "Fat Content", v1: detectedBreed.fatContent, v2: comparisonBreed.fatContent)
                ComparisonTableRow(label: "Climate Tolerance", v1: detectedBreed.climateTolerance, v2: comparisonBreed.climateTolerance)
                ComparisonTableRow(label: "Feed Efficiency", v1: detectedBreed.feedCost == "Low" ? "High" : "Medium", v2: comparisonBreed.feedCost == "Low" ? "High" : "Medium")
            }
        }
        .padding(25)
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 10)
        .padding(.horizontal, 24)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: appeared)
    }
}

struct ComparisonBreedCard: View {
    let breed: BreedInfo
    let label: String
    let isDetected: Bool
    let delay: Double
    let appeared: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 15) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(label.uppercased())
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(isDetected ? .green : .secondary)
                        Text(breed.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray.opacity(0.5))
                }
                
                VStack(spacing: 12) {
                    MetricItem(label: "Milk/Day", value: breed.milkYield)
                    MetricItem(label: "Avg. Cost", value: breed.cost)
                    MetricItem(label: "Climate", value: breed.climate)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(24)

            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay), value: appeared)
    }
}

struct MetricItem: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.primary)
        }
    }
}

struct BreedPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedBreed: BreedInfo
    
    var body: some View {
        NavigationView {
            List(BreedRepository.allBreeds) { breed in
                Button {
                    selectedBreed = breed
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(breed.name).font(.headline).foregroundColor(.primary)
                            Text(breed.category).font(.subheadline).foregroundColor(.secondary)
                        }
                        Spacer()
                        if selectedBreed.id == breed.id {
                            Image(systemName: "checkmark").foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationTitle("Select Breed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct ComparisonTableRow: View {
    let label: String
    let v1: String
    let v2: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                Text(v1).frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.green)
                    .font(.system(size: 15, weight: .bold))
                
                Text(v2).frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundColor(.secondary)
                    .font(.system(size: 15))
            }
            
            Divider().background(Color.gray.opacity(0.1))
        }
    }
}


#Preview {
    BreedComparisonView(path: .constant([]))
}
