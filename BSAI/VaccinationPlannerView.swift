import SwiftUI

struct VaccinationPlannerView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    @State private var vaccinations: [VaccinationRecord] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    summaryCard
                    
                    HStack {
                        Text("Vaccination Schedule")
                            .font(.headline)
                        Spacer()
                        Button(action: { path.append(.addVaccination) }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color(hex: "00A661"))
                        }
                    }
                    .padding(.top, 5)
                    
                    if isLoading {
                        ProgressView()
                            .padding()
                    } else if vaccinations.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary.opacity(0.3))
                            Text("No vaccinations scheduled yet.")
                                .foregroundColor(.secondary)
                            Button("Add First One") {
                                path.append(.addVaccination)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(hex: "00A661"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.top, 40)
                    } else {
                        vaccineScheduleList
                    }
                    
                    Spacer(minLength: 30)
                }
                .padding()
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .onAppear {
            loadVaccinations()
            appeared = true
        }
        .alert("Error", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) { }
        } message: {
            if let msg = errorMessage {
                Text(msg)
            }
        }
    }
    
    private func loadVaccinations() {
        isLoading = true
        errorMessage = nil
        AuthManager.shared.fetchVaccinations { result in
            isLoading = false
            switch result {
            case .success(let data):
                self.vaccinations = data
            case .failure(let error):
                print("DEBUG: Fetch Vaccinations failed: \(error)")
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func toggleCompletion(for vax: VaccinationRecord) {
        if vax.status == "completed" { return } // Already done
        
        AuthManager.shared.completeVaccination(id: vax.id) { result in
            if case .success = result {
                loadVaccinations()
            }
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
                    .background(Color.secondaryAppBackground)
                    .clipShape(Circle())
                    .shadow(color: Color.shadowColor, radius: 5, x: 0, y: 2)
            }
            Text("Vaccination Planner")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 10)
            Spacer()
        }
        .padding()
        .background(Color.secondaryAppBackground)
    }
    
    private var summaryCard: some View {
        let upcoming = vaccinations.filter { $0.status != "completed" }.count
        let nextVax = vaccinations.filter { $0.status != "completed" }.first
        
        return VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.blue.opacity(0.08))
                        .frame(width: 56, height: 56)
                    Image(systemName: "calendar.badge.clock")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(upcoming) Upcoming")
                        .font(.title3.bold())
                    Text("Vaccinations scheduled")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            if let next = nextVax {
                HStack {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("Next due: **\(next.vaccine_name) on \(formatDate(next.planned_date))**")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.08))
                .cornerRadius(12)
            }
        }
        .padding(25)
        .background(Color.cardBackground)
        .cornerRadius(30)
        .shadow(color: Color.shadowColor, radius: 15, x: 0, y: 10)
        .scaleEffect(appeared ? 1 : 0.95)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.1), value: appeared)
    }
    
    private var vaccineScheduleList: some View {
        VStack(spacing: 16) {
            ForEach(Array(vaccinations.enumerated()), id: \.element.id) { index, vax in
                VaccineRow(
                    name: vax.vaccine_name,
                    type: vax.type ?? "General",
                    date: formatDate(vax.planned_date),
                    status: vax.status.capitalized,
                    statusColor: statusColor(vax.status),
                    isDone: vax.status == "completed",
                    delay: 0.1 * Double(index),
                    appeared: appeared
                )
                .onTapGesture {
                    if vax.status != "completed" {
                        toggleCompletion(for: vax)
                    }
                }
            }
        }
    }
    
    private func formatDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var date = formatter.date(from: isoString)
        if date == nil {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: isoString)
        }
        
        guard let d = date else { return isoString }
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        return displayFormatter.string(from: d)
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "completed": return .green
        case "scheduled": return .blue
        case "overdue": return .red
        default: return .orange
        }
    }
}

struct VaccineRow: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    let name: String
    let type: String
    let date: String
    let status: String
    let statusColor: Color
    var isDone: Bool = false
    let delay: Double
    let appeared: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(name)
                        .font(.headline)
                    Spacer()
                    HStack(spacing: 4) {
                        if isDone {
                            Image(systemName: "checkmark.circle.fill")
                        }
                        Text(status)
                    }
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.1))
                    .foregroundColor(statusColor)
                    .cornerRadius(6)
                }
                
                Text(type)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(isDone ? "Completed" : "Due: \(date)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isDone ? .secondary : .primary)
            }
        }
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(22)
        .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 5)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay), value: appeared)
    }
}

#Preview {
    VaccinationPlannerView(path: .constant([]))
}

