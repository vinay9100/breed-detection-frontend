import SwiftUI

struct VaccinationPlannerView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    summaryCard
                    
                    Text("Vaccination Schedule")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 5)
                    
                    vaccineScheduleList
                    
                    Spacer(minLength: 30)
                }
                .padding()
            }
        }
        .background(Color(hex: "F8FBF9").ignoresSafeArea())
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
            Text("Vaccination Planner")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 10)
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 20) {
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
                    Text("3 Upcoming")
                        .font(.title3.bold())
                    Text("Vaccinations scheduled")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Image(systemName: "clock.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
                Text("Next due: **FMD Vaccine on Feb 15**")
                    .font(.subheadline)
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.orange.opacity(0.08))
            .cornerRadius(12)
        }
        .padding(25)
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 10)
        .scaleEffect(appeared ? 1 : 0.95)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.1), value: appeared)
    }
    
    private var vaccineScheduleList: some View {
        VStack(spacing: 16) {
            VaccineRow(name: "FMD Vaccine", type: "Every 6 months", date: "Feb 15, 2026", status: "Due Soon", statusColor: .orange, delay: 0.2, appeared: appeared)
            VaccineRow(name: "Brucellosis", type: "Annual", date: "Completed", status: "Done", statusColor: .green, isDone: true, delay: 0.3, appeared: appeared)
            VaccineRow(name: "Black Quarter", type: "Annual", date: "Mar 10, 2026", status: "Upcoming", statusColor: .blue, delay: 0.4, appeared: appeared)
            VaccineRow(name: "Anthrax", type: "Annual", date: "Completed", status: "Done", statusColor: .green, isDone: true, delay: 0.5, appeared: appeared)
            VaccineRow(name: "Hemorrhagic Septicemia", type: "Bi-annual", date: "Apr 22, 2026", status: "Scheduled", statusColor: .cyan, delay: 0.6, appeared: appeared)
        }
    }
}

struct VaccineRow: View {
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
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay), value: appeared)
    }
}

#Preview {
    VaccinationPlannerView(path: .constant([]))
}
