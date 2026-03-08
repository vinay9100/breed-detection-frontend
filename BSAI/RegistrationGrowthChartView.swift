import SwiftUI

struct ChartData: Identifiable {
    let id = UUID()
    let day: String
    let value: Double
    let date: String
}

struct RegistrationGrowthChartView: View {
    let rawData: [APIBarChartData]
    
    private var data: [ChartData] {
        if rawData.isEmpty {
            return (0..<7).map { i in
                ChartData(day: "\(i)", value: 0, date: "No data")
            }
        }
        
        return rawData.map { item in
            let dateStr = item.date
            // Basic extraction: "2024-03-06" -> "Mar 06"
            let dayPart = String(dateStr.suffix(5)) // "03-06"
            return ChartData(day: dayPart, value: Double(item.value), date: dateStr)
        }
    }
    
    @State private var selectedPoint: ChartData? = nil
    @State private var touchLocation: CGPoint = .zero
    @State private var showTooltip = false
    @State private var lineAnimationProgress: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Registration Growth")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "1B5E20"))
                    Text("Total 138 registrations")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                HStack(spacing: 8) {
                    Text("+12%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "00A661"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "00A661").opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            // Chart Area
            GeometryReader { geometry in
                let height = geometry.size.height
                let width = geometry.size.width
                let maxVal = data.map { $0.value }.max() ?? 100
                let stepX = width / CGFloat(data.count - 1)
                
                ZStack {
                    // Grid Lines (Horizontal)
                    VStack(spacing: 0) {
                        ForEach(0..<4) { i in
                            Divider()
                                .background(Color.gray.opacity(0.1))
                            if i < 3 { Spacer() }
                        }
                    }
                    
                    // Area Gradient
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: height))
                        for i in 0..<data.count {
                            let x = stepX * CGFloat(i)
                            let y = height - (CGFloat(data[i].value) / CGFloat(maxVal * 1.2)) * height
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                        path.addLine(to: CGPoint(x: width, y: height))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "00A661").opacity(0.2), Color(hex: "00A661").opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(lineAnimationProgress)

                    // Line Chart
                    Path { path in
                        for i in 0..<data.count {
                            let x = stepX * CGFloat(i)
                            let y = height - (CGFloat(data[i].value) / CGFloat(maxVal * 1.2)) * height
                            if i == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .trim(from: 0, to: lineAnimationProgress)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "00A661"), Color(hex: "008D43")],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )
                    
                    // Selected Point Highlight
                    if let selected = selectedPoint {
                        let index = data.firstIndex(where: { $0.id == selected.id }) ?? 0
                        let x = stepX * CGFloat(index)
                        let y = height - (CGFloat(selected.value) / CGFloat(maxVal * 1.2)) * height
                        
                        // Vertical dashed line
                        Path { path in
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: x, y: height))
                        }
                        .stroke(Color(hex: "00A661").opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [5]))
                        
                        // Point outer glow with pulsing aura
                        Circle()
                            .fill(Color(hex: "00A661").opacity(0.15))
                            .frame(width: 32, height: 32)
                            .position(x: x, y: y)
                            .scaleEffect(showTooltip ? 1.3 : 0.5)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6).repeatForever(autoreverses: true), value: showTooltip)
                        
                        Circle()
                            .fill(Color(hex: "00A661").opacity(0.25))
                            .frame(width: 22, height: 22)
                            .position(x: x, y: y)
                            .scaleEffect(showTooltip ? 1.1 : 0.8)
                        
                        // Point inner circle
                        Circle()
                            .fill(Color.white)
                            .frame(width: 12, height: 12)
                            .overlay(Circle().stroke(Color(hex: "1B5E20"), lineWidth: 3))
                            .position(x: x, y: y)
                            .shadow(color: Color(hex: "00A661").opacity(0.4), radius: 8)
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            touchLocation = value.location
                            let index = Int(round(touchLocation.x / stepX))
                            if index >= 0 && index < data.count {
                                if selectedPoint?.id != data[index].id {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedPoint = data[index]
                                        showTooltip = true
                                    }
                                }
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                selectedPoint = nil
                                showTooltip = false
                            }
                        }
                )
            }
            .frame(height: 180)
            .padding(.horizontal, 24)

            // X-Axis Labels
            HStack {
                ForEach(data) { item in
                    Text(item.day)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(selectedPoint?.id == item.id ? Color(hex: "1B5E20") : .secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.04), radius: 20, x: 0, y: 10)
        .overlay(
            Group {
                if let selected = selectedPoint, showTooltip {
                    GeometryReader { proxy in
                        let stepX = (proxy.size.width - 48) / CGFloat(data.count - 1)
                        let index = data.firstIndex(where: { $0.id == selected.id }) ?? 0
                        let x = 24 + stepX * CGFloat(index)
                        let maxVal = data.map { $0.value }.max() ?? 100
                        let y = 180 + 44 - (CGFloat(selected.value) / CGFloat(maxVal * 1.2)) * 180 - 60
                        
                        TooltipView(title: selected.date, value: "\(Int(selected.value)) Regs")
                            .position(x: x, y: y)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.5, anchor: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                }
            }
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2)) {
                lineAnimationProgress = 1.0
            }
        }
    }
}

struct TooltipView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.8))
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "1B5E20"))
                
                // Triangle pointer
                Image(systemName: "triangle.fill")
                    .resizable()
                    .frame(width: 12, height: 6)
                    .rotationEffect(.degrees(180))
                    .foregroundColor(Color(hex: "1B5E20"))
                    .offset(y: 16)
            }
        )
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    ZStack {
        Color(hex: "F8FBF9").ignoresSafeArea()
        RegistrationGrowthChartView(rawData: [
            APIBarChartData(date: "2024-03-01", value: 10, avg_yield: 25.0),
            APIBarChartData(date: "2024-03-02", value: 15, avg_yield: 24.5),
            APIBarChartData(date: "2024-03-03", value: 12, avg_yield: 26.2),
            APIBarChartData(date: "2024-03-04", value: 20, avg_yield: 25.8),
            APIBarChartData(date: "2024-03-05", value: 18, avg_yield: 27.1),
            APIBarChartData(date: "2024-03-06", value: 25, avg_yield: 26.5),
            APIBarChartData(date: "2024-03-07", value: 22, avg_yield: 25.9)
        ])
        .padding()
    }
}
