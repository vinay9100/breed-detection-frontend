import SwiftUI

struct EditProfileView: View {
    @Binding var path: [AppRoute]
    @State private var appeared = false
    
    @State private var fullName = "John Farmer"
    @State private var email = "john.farmer@email.com"
    @State private var phoneNumber = "+1 234 567 8900"
    @State private var location = "California, USA"
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    profileImageSection
                    
                    VStack(spacing: 20) {
                        EditInfoField(label: "Full Name", icon: "person", text: $fullName)
                        EditInfoField(label: "Email", icon: "envelope", text: $email)
                        EditInfoField(label: "Phone Number", icon: "phone", text: $phoneNumber)
                        EditInfoField(label: "Location", icon: "mappin.circle", text: $location)
                    }
                    .padding(.horizontal, 24)
                    
                    saveButton
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
            }
        }
        .background(Color(hex: "F8FBF9").ignoresSafeArea())
        .onAppear {
            appeared = true
        }
    }
    
    private var navigationBar: some View {
        HStack {
            Button(action: { 
                if !path.isEmpty {
                    _ = path.removeLast()
                }
            }) {
                Image(systemName: "arrow.left")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            
            Text("Edit Profile")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 10)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var profileImageSection: some View {
        VStack(spacing: 15) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color(hex: "00C853"))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Button(action: {}) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                .padding(2)
            }
            
            Text("Tap to change photo")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.95)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)
    }
    
    private var saveButton: some View {
        Button(action: { path.removeLast() }) {
            Text("Save Changes")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.green)
                .cornerRadius(18)
                .shadow(color: Color.green.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: appeared)
    }
}

struct EditInfoField: View {
    let label: String
    let icon: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Text(label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            
            TextField(label, text: $text)
                .font(.system(size: 16, weight: .medium))
                .padding()
                .background(Color.gray.opacity(0.04))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
        }
    }
}

#Preview {
    EditProfileView(path: .constant([]))
}
