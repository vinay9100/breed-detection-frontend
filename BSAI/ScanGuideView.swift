import SwiftUI

struct ScanGuideView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    headerSection
                    stepsList
                    proTipsSection
                    startScanningButton
                }
                .padding(.horizontal)
            }
        }
        .background(Color(uiColor: .systemBackground))
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
                HStack(spacing: 10) {
                    Image(systemName: "arrow.left")
                    Text("Back")
                }
                .foregroundColor(.secondary)
                .font(.body)
            }
            Spacer()
        }
        .padding()
    }
    
    private var headerSection: some View {
        VStack(spacing: 25) {
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.green)
                    .frame(width: 100, height: 100)
                Image(systemName: "sparkles")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.top, 20)
            .scaleEffect(appeared ? 1 : 0.8)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: appeared)
            
            VStack(spacing: 10) {
                Text("Scan Guide")
                    .font(.title.bold())
                Text("Follow these steps for optimal AI detection")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)
        }
    }
    
    private var stepsList: some View {
        VStack(spacing: 15) {
            GuideStepCard(number: "1", title: "Front View", description: "Capture a clear front view of the animal's face", delay: 0.2, appeared: appeared)
            GuideStepCard(number: "2", title: "Side Profile", description: "Take a side profile shot showing body structure", delay: 0.3, appeared: appeared)
            GuideStepCard(number: "3", title: "Full Body", description: "Get a complete body shot for best results", delay: 0.4, appeared: appeared)
        }
    }
    
    private var proTipsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("💡 Pro Tips")
                    .font(.headline)
                    .foregroundColor(Color.blue)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 10) {
                ProTipRow(text: "Ensure good lighting conditions")
                ProTipRow(text: "Keep the animal calm and steady")
                ProTipRow(text: "Avoid shadows on the animal")
                ProTipRow(text: "Use landscape orientation")
            }
        }
        .padding(25)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(25)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.5), value: appeared)
    }
    
    private var startScanningButton: some View {
        Button(action: {
            path.append(.camera)
        }) {
            Text("Start Scanning")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(15)
        }
        .padding(.top, 10)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.6), value: appeared)
    }
}

struct GuideStepCard: View {
    let number: String
    let title: String
    let description: String
    let delay: Double
    let appeared: Bool
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 45, height: 45)
                Text(number)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : -20)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay), value: appeared)
    }
}

struct ProTipRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("•")
                .foregroundColor(.blue)
                .font(.headline)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.blue.opacity(0.8))
        }
    }
}

#Preview {
    ScanGuideView(path: .constant([]))
}
