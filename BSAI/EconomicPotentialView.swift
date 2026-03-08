import SwiftUI

struct EconomicPotentialView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    heroCard
                    statsGrid
                    costBreakdown
                    profitOptimization
                    
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
            Text("Economic Potential")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 10)
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var heroCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.green.opacity(0.1))
                        .frame(width: 60, height: 60)
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.title)
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("High ROI")
                        .font(.title2.bold())
                    Text("Return on Investment")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            VStack(spacing: 10) {
                Text("$1,200 - $1,500")
                    .font(.system(size: 34, weight: .black))
                    .foregroundColor(.primary)
                
                Text("Estimated monthly revenue per animal")
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green.opacity(0.08))
                    .cornerRadius(12)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.gray.opacity(0.02))
            .cornerRadius(20)
        }
        .padding(25)
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 10)
        .scaleEffect(appeared ? 1 : 0.9)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)
    }
    
    private var statsGrid: some View {
        HStack(spacing: 15) {
            EconomicStatCard(title: "Revenue", value: "$1,350", subtitle: "Milk sales/month", icon: "chart.line.uptrend.xyaxis", color: .green)
            EconomicStatCard(title: "Costs", value: "$520", subtitle: "Total expenses/month", icon: "chart.line.downtrend.xyaxis", color: .orange)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appeared)
    }
    
    private var costBreakdown: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Cost Breakdown")
                .font(.headline)
            
            VStack(spacing: 15) {
                CostRow(label: "Feed & Nutrition", amount: "$150")
                CostRow(label: "Healthcare & Vaccines", amount: "$80")
                CostRow(label: "Housing & Utilities", amount: "$120")
                CostRow(label: "Labor & Management", amount: "$100")
                CostRow(label: "Miscellaneous", amount: "$70")
            }
        }
        .padding(25)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 10)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: appeared)
    }
    
    private var profitOptimization: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.orange)
                Text("Profit Optimization")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
            Text("Net profit potential: **$830/month** per animal")
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Text("Increase profitability through better feed management and health optimization.")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding(25)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.green.opacity(0.05))
        .cornerRadius(25)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: appeared)
    }
}

struct EconomicStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title2.bold())
            
            Text(subtitle)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
    }
}

struct CostRow: View {
    let label: String
    let amount: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(amount)
                .font(.headline)
        }
    }
}

#Preview {
    EconomicPotentialView(path: .constant([]))
}
