import SwiftUI

// MARK: - App Entry Point
// Single NavigationStack with path-based navigation.
// Every screen is pushed onto `path`; resetting `path = []` returns to root (SplashView/LoginView).

@main
struct BreedSureAIApp: App {
    @AppStorage("app_language") private var appLanguage: String = "en"
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(\.locale, .init(identifier: appLanguage))
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

import Foundation
import Combine

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var pendingImage: UIImage?
    @Published var currentPrediction: PredictResponse?
    @Published var confirmedPrediction: PredictResponse? // For capturing user-confirmed results
    @Published var authToken: String? {
        didSet {
            // Save token to UserDefaults
            if let token = authToken {
                UserDefaults.standard.set(token, forKey: "authToken")
                isAuthenticated = true
            } else {
                UserDefaults.standard.removeObject(forKey: "authToken")
                isAuthenticated = false
            }
        }
    }
    
    // IMPORTANT: If using a real device, change this to your Mac's Local IP (e.g. "http://192.168.1.10:8000")
    public let baseURL = "http://127.0.0.1:8000"
    
    init() {
        self.authToken = UserDefaults.standard.string(forKey: "authToken")
        if self.authToken != nil {
            self.fetchMe { _ in }
        }
    }
    
    // MARK: - API Calls
    
    func register(user: RegisterRequest, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let cleanedEmail = user.email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedName = user.full_name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedUser = RegisterRequest(
            email: cleanedEmail,
            password: user.password,
            full_name: cleanedName,
            phone_number: user.phone_number
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(cleanedUser)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))) }
                return
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async { completion(.success("Success")) }
            } else {
                // Try to parse error message
                var errorMsg = "Registration failed"
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let detail = json["detail"] as? String {
                    errorMsg = detail
                }
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg]))) }
            }
        }.resume()
    }
    
    func registerBPA(user: BPARegisterRequest, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/bpa-register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let cleanedEmail = user.email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedName = user.full_name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedUser = BPARegisterRequest(
            email: cleanedEmail,
            password: user.password,
            full_name: cleanedName,
            phone_number: user.phone_number
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(cleanedUser)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }    
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))) }
                return
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async { completion(.success("Success")) }
            } else {
                // Try to parse error message
                var errorMsg = "BPA Registration failed"
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let detail = json["detail"] as? String {
                    errorMsg = detail
                }
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg]))) }
            }
        }.resume()
    }
    
    func verifyOTP(email: String, otp: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/verify-otp")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let cleanedEmail = email.uppercased().hasPrefix("BPA-") ? 
            email.replacingOccurrences(of: "BPA-", with: "") : email
        let body = ["email": cleanedEmail, "otp_code": otp]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))) }
                return
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let t = json["token"] as? String {
                    DispatchQueue.main.async { completion(.success(t)) }
                } else {
                    DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token missing in verification response"]))) }
                }
            } else {
                var errorMsg = "Verification failed"
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let detail = json["detail"] as? String {
                    errorMsg = detail
                }
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg]))) }
            }
        }.resume()
    }
    
    func login(credentials: LoginRequest, completion: @escaping (Result<String, Error>) -> Void) {
        let trimmedEmail = credentials.email.trimmingCharacters(in: .whitespacesAndNewlines)
        let isBPA = trimmedEmail.uppercased().hasPrefix("BPA-")
        let endpoint = isBPA ? "/bpa-login" : "/login"
        
        let url = URL(string: "\(baseURL)\(endpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let cleanedEmail = credentials.email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedReq = LoginRequest(email: cleanedEmail, password: credentials.password)
        
        do {
            request.httpBody = try JSONEncoder().encode(cleanedReq)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))) }
                return
            }
            
            if (200...299).contains(httpResponse.statusCode), let data = data {
                do {
                    let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.authToken = tokenResponse.access_token
                        self.fetchMe { _ in
                            completion(.success("Success"))
                        }
                    }
                } catch {
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            } else {
                var errorMsg = "Login failed"
                if httpResponse.statusCode == 404 {
                    errorMsg = "Email not registered"
                } else if httpResponse.statusCode == 401 {
                    errorMsg = "Invalid password"
                } else if httpResponse.statusCode == 403 {
                    errorMsg = "Please verify your OTP"
                } else if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let detail = json["detail"] as? String {
                    errorMsg = detail
                } else if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let detailArray = json["detail"] as? [[String: Any]], let firstMsg = detailArray.first?["msg"] as? String {
                    errorMsg = firstMsg
                }
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg]))) }
            }
        }.resume()
    }
    
    func logout() {
        self.authToken = nil
        self.currentUser = nil
    }

    func sendOTP(email: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/resend-otp")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let cleanedEmail = email.uppercased().hasPrefix("BPA-") ? 
            email.replacingOccurrences(of: "BPA-", with: "") : email
        let body = ["email": cleanedEmail]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))) }
                return
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async { completion(.success("OTP sent")) }
            } else {
                var errorMsg = "Failed to send OTP"
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let detail = json["detail"] as? String {
                    errorMsg = detail
                }
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg]))) }
            }
        }.resume()
    }

    func resendOTP(email: String, completion: @escaping (Result<String, Error>) -> Void) {
        sendOTP(email: email, completion: completion)
    }

    func forgotPassword(email: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/forgot-password")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let body = ["email": cleanedEmail]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))) }
                return
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async { completion(.success("Check email")) }
            } else {
                var errorMsg = "Forgot password request failed"
                if httpResponse.statusCode == 404 {
                    errorMsg = "Email not registered"
                } else if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let detail = json["detail"] as? String {
                    errorMsg = detail
                } else if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let detailArray = json["detail"] as? [[String: Any]], let firstMsg = detailArray.first?["msg"] as? String {
                    errorMsg = firstMsg
                }
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg]))) }
            }
        }.resume()
    }

    func bpaForgotPassword(email: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/bpa-forgot-password")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let body = ["email": cleanedEmail]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))) }
                return
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async { completion(.success("Check email")) }
            } else {
                var errorMsg = "Forgot password request failed"
                if httpResponse.statusCode == 404 {
                    errorMsg = "Email not registered"
                } else if httpResponse.statusCode == 400 {
                    errorMsg = "Please enter BPA- prefix"
                } else if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let detail = json["detail"] as? String {
                    errorMsg = detail
                } else if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let detailArray = json["detail"] as? [[String: Any]], let firstMsg = detailArray.first?["msg"] as? String {
                    errorMsg = firstMsg
                }
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg]))) }
            }
        }.resume()
    }

    func resetPassword(token: String, newPassword: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/reset-password")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["token": token, "new_password": newPassword]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))) }
                return
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async { completion(.success("Password reset success")) }
            } else {
                var errorMsg = "Reset password failed"
                if httpResponse.statusCode == 400 {
                    errorMsg = "Invalid or expired reset token"
                } else if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let detail = json["detail"] as? String {
                    errorMsg = detail
                } else if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let detailArray = json["detail"] as? [[String: Any]], let firstMsg = detailArray.first?["msg"] as? String {
                    errorMsg = firstMsg
                }
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg]))) }
            }
        }.resume()
    }

    func deleteAccount(completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = authToken else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])))
            return
        }

        let url = URL(string: "\(baseURL)/account")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))) }
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    self.logout()
                    completion(.success("Account deleted successfully"))
                }
            } else {
                var errorMsg = "Failed to delete account"
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let detail = json["detail"] as? String {
                    errorMsg = detail
                }
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg]))) }
            }
        }.resume()
    }
    
    func fetchMe(completion: @escaping (Result<User, Error>) -> Void) {
        guard let token = authToken else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])))
            return
        }

        let url = URL(string: "\(baseURL)/me")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"]))) }
                return
            }

            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    self.currentUser = user
                    completion(.success(user))
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
    
    // MARK: - Analytics & Reports
    
    func saveDetection(breedName: String, confidenceScore: Double, yieldEstimate: Double?, milkYieldRange: String? = nil, animalType: String? = nil, fatContent: String? = nil, imagePath: String? = nil, animalEarTag: String? = nil, completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = authToken else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])))
            return
        }

        let url = URL(string: "\(baseURL)/detections")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body: [String: Any] = [
            "breed_name": breedName,
            "confidence_score": confidenceScore
        ]
        
        if let ye = yieldEstimate { body["yield_estimate"] = ye }
        if let myr = milkYieldRange { body["milk_yield_range"] = myr }
        if let at = animalType { body["animal_type"] = at }
        if let fc = fatContent { body["fat_content"] = fc }
        if let ip = imagePath { body["image_path"] = ip }
        if let tag = animalEarTag { body["animal_ear_tag"] = tag }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to save detection"]))) }
                return
            }

            DispatchQueue.main.async { completion(.success("Success")) }
        }.resume()
    }
    func registerAnimalDetails(animal: AnimalRegistrationData, completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = authToken else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])))
            return
        }

        let url = URL(string: "\(baseURL)/register-animal")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(animal)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No response"]))) }
                return
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                var msg = "Failed to register animal"
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let detail = json["detail"] as? String {
                    msg = detail
                }
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: msg]))) }
                return
            }

            DispatchQueue.main.async { completion(.success("Animal registered successfully")) }
        }.resume()
    }

    func fetchAnimals(completion: @escaping (Result<[AnimalRegistrationData], Error>) -> Void) {
        guard let token = authToken else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])))
            return
        }

        let url = URL(string: "\(baseURL)/animals")! 
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"]))) }
                return
            }

            do {
                let animals = try JSONDecoder().decode([AnimalRegistrationData].self, from: data)
                DispatchQueue.main.async { completion(.success(animals)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }

    func fetchAnalytics(timeFilter: String, completion: @escaping (Result<AnalyticsSummaryResponse, Error>) -> Void) {
        guard let token = authToken else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])))
            return
        }
        
        guard var components = URLComponents(string: "\(baseURL)/analytics") else { return }
        components.queryItems = [URLQueryItem(name: "time_filter", value: timeFilter)]
        guard let url = components.url else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch analytics"]))) }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(AnalyticsSummaryResponse.self, from: data)
                DispatchQueue.main.async { completion(.success(decoded)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }

    func updateProfile(fullName: String, phoneNumber: String, profilePhoto: String? = nil, completion: @escaping (Result<User, Error>) -> Void) {
        guard let token = authToken else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])))
            return
        }
        
        guard let url = URL(string: "\(baseURL)/users/me") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body: [String: Any] = [
            "full_name": fullName,
            "phone_number": phoneNumber
        ]
        if let photo = profilePhoto {
            body["profile_photo"] = photo
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to update profile"]))) }
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async { 
                    self.currentUser = decoded
                    completion(.success(decoded))
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }

    func uploadProfilePhoto(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = authToken else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])))
            return
        }
        
        guard let url = URL(string: "\(baseURL)/users/me/photo") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Upload failed"]))) }
                return
            }
            
            do {
                // Backend now returns the full updated User object
                let updatedUser = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    self.currentUser = updatedUser  // 🔄 Instantly updates profile photo everywhere
                    completion(.success(updatedUser.profilePhoto ?? ""))
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }

    func fetchMyDetections(completion: @escaping (Result<[DetectionRecord], Error>) -> Void) {
        guard let token = authToken else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])))
            return
        }
        
        guard let url = URL(string: "\(baseURL)/detections/me") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch scan history"]))) }
                return
            }

            do {
                let decoded = try JSONDecoder().decode([DetectionRecord].self, from: data)
                DispatchQueue.main.async { completion(.success(decoded)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }

    // MARK: - AI Prediction
    
    func uploadImageForPrediction(image: UIImage, earTag: String? = nil, completion: @escaping (Result<PredictResponse, Error>) -> Void) {
        guard let token = authToken else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])))
            return
        }
        
        let url = URL(string: "\(baseURL)/predict-animal")!
        
        // Use background thread for heavy image processing
        DispatchQueue.global(qos: .userInitiated).async {
            print("📸 Starting image processing (id: \(UUID().uuidString.prefix(4)))")
            
            // Resize logic with logging
            let finalImage: UIImage
            if image.size.width > 1200 || image.size.height > 1200 {
                print("📏 Resizing heavy image from \(image.size)")
                finalImage = image.resized(to: CGSize(width: 1024, height: 1024)) ?? image
            } else {
                finalImage = image
            }

            guard let imageData = finalImage.jpegData(compressionQuality: 0.7) else {
                print("❌ JPEG encoding failed")
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Image processing failed"])))
                }
                return
            }
            
            print("📤 Creating request for /predict-animal (size: \(imageData.count / 1024) KB)")
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var body = Data()
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
            
            if let tag = earTag, !tag.isEmpty {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"ear_tag\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(tag)\r\n".data(using: .utf8)!)
            }
            
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            request.httpBody = body
            
            print("⚡️ Resuming data task...")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    DispatchQueue.main.async { completion(.failure(error)) }
                    return
                }
                
                guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                    print("❌ No response from server")
                    DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No response from server"]))) }
                    return
                }
                
                print("📋 Server returned status code: \(httpResponse.statusCode)")
                
                if !(200...299).contains(httpResponse.statusCode) {
                    var errorMsg = "Failed to analyze image"
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], 
                       let detail = json["detail"] as? String {
                        errorMsg = detail
                    }
                    print("❌ API Error: \(errorMsg)")
                    DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg]))) }
                    return
                }
                
                do {
                    print("✅ Decoding response...")
                    let decoded = try JSONDecoder().decode(PredictResponse.self, from: data)
                    print("🎉 Success! Breed: \(decoded.breed_name ?? "nil")")
                    DispatchQueue.main.async { completion(.success(decoded)) }
                } catch {
                    print("❌ Decoding Failure: \(error)")
                    // Log raw data for debugging
                    if let rawStr = String(data: data, encoding: .utf8) {
                        print("📄 Raw Response: \(rawStr)")
                    }
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
            task.resume()
        }
    }
    
    func fetchBPAStats(completion: @escaping (Result<BPAStats, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/bpa-stats") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data = data else { return }
            
            do {
                let stats = try JSONDecoder().decode(BPAStats.self, from: data)
                DispatchQueue.main.async { completion(.success(stats)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
    
    func fetchAnimalHistory(earTag: String, completion: @escaping (Result<[RecentActivity], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/animals/\(earTag)/history") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data = data else { return }
            
            do {
                // Map DetectionResponse to RecentActivity for UI compatibility
                let detections = try JSONDecoder().decode([DetectionRecord].self, from: data)
                let activities = detections.map { det in
                    RecentActivity(
                        id: "scan_\(det.id)",
                        title: det.breed_name,
                        subtitle: "Breed Detection - \(Int(det.confidence_score * 100))%",
                        time: det.detected_at,
                        type: "scan"
                    )
                }
                DispatchQueue.main.async { completion(.success(activities)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
    
    func fetchReportSummary(completion: @escaping (Result<AnalyticsSummaryResponse, Error>) -> Void) {
        guard let token = authToken else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])))
            return
        }
        
        let url = URL(string: "\(baseURL)/analytics")! // Simplified matching
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"]))) }
                return
            }
            
            do {
                let summary = try JSONDecoder().decode(AnalyticsSummaryResponse.self, from: data)
                DispatchQueue.main.async { completion(.success(summary)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }

    func fetchRecentActivity(completion: @escaping (Result<[RecentActivity], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/activity/recent") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data = data else { return }
            
            do {
                let activity = try JSONDecoder().decode([RecentActivity].self, from: data)
                DispatchQueue.main.async { completion(.success(activity)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }

    func fetchVaccinations(completion: @escaping (Result<[VaccinationRecord], Error>) -> Void) {
        guard let token = authToken else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])))
            return
        }
        let url = URL(string: "\(baseURL)/vaccinations")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"]))) }
                return
            }
            do {
                let decoded = try JSONDecoder().decode([VaccinationRecord].self, from: data)
                DispatchQueue.main.async { completion(.success(decoded)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
    
    func fetchAlerts(lat: Double?, lon: Double?, completion: @escaping (Result<[DiseaseAlert], Error>) -> Void) {
        var urlString = "\(baseURL)/alerts"
        if let lat = lat, let lon = lon {
            urlString += "?lat=\(lat)&lon=\(lon)"
        }
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"]))) }
                return
            }
            do {
                let decoded = try JSONDecoder().decode([DiseaseAlert].self, from: data)
                DispatchQueue.main.async { completion(.success(decoded)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }

    func addVaccination(vaccine: VaccinationCreate, completion: @escaping (Result<VaccinationRecord, Error>) -> Void) {
        guard let token = authToken else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])))
            return
        }
        let url = URL(string: "\(baseURL)/vaccinations")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Use a date formatter that matches ISO8601 for the backend
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            request.httpBody = try encoder.encode(vaccine)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data, let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to add vaccination"]))) }
                return
            }
            do {
                let decoded = try JSONDecoder().decode(VaccinationRecord.self, from: data)
                DispatchQueue.main.async { completion(.success(decoded)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }

    func completeVaccination(id: Int, completion: @escaping (Result<VaccinationRecord, Error>) -> Void) {
        guard let token = authToken else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])))
            return
        }
        let url = URL(string: "\(baseURL)/vaccinations/\(id)/complete")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data, let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to complete vaccination"]))) }
                return
            }
            do {
                let decoded = try JSONDecoder().decode(VaccinationRecord.self, from: data)
                DispatchQueue.main.async { completion(.success(decoded)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}

// MARK: - Models
struct RecentActivity: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let time: String
    let type: String
}

struct DiseaseAlert: Codable, Identifiable {
    let id: Int
    let disease_name: String
    let message: String
    let location: String
    let severity: String
    let created_at: String
}

struct AnimalRegistrationData: Codable, Hashable {
    let ear_tag_number: String
    let animal_name: String?
    let species: String
    let sex: String
    let breed: String
    let dob: String?
    let owner_name: String
    let address: String?
    let village: String
    let district: String
    let state: String
    let last_image_path: String?
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let full_name: String
    let phone_number: String?
}

struct BPARegisterRequest: Codable {
    let email: String
    let password: String
    let full_name: String
    let phone_number: String?
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct User: Codable {
    let id: Int
    let email: String
    let fullName: String
    let phoneNumber: String?
    let profilePhoto: String?

    enum CodingKeys: String, CodingKey {
        case id, email
        case fullName = "full_name"
        case phoneNumber = "phone_number"
        case profilePhoto = "profile_photo"
    }
}

struct TokenResponse: Codable {
    let access_token: String
    let token_type: String
}

struct VaccinationRecord: Codable, Identifiable {
    let id: Int
    let user_id: Int
    let animal_id: Int?
    let vaccine_name: String
    let type: String?
    let planned_date: String
    let completion_date: String?
    let status: String
}

struct VaccinationCreate: Codable {
    let vaccine_name: String
    let type: String?
    let planned_date: String
    var animal_id: Int?
}

// MARK: - Analytics Models

struct APIPieChartData: Codable {
    let name: String
    let count: Int
}

struct APIBarChartData: Codable {
    let date: String
    let value: Int
    let avg_yield: Double?
}

struct AnalyticsSummaryResponse: Codable {
    let total_animals: Int
    let average_accuracy: Double
    let average_yield: Double?
    let pie_chart: [APIPieChartData]
    let bar_chart: [APIBarChartData]
}

struct BPAStats: Codable {
    let total_animals: Int
    let total_owners: Int
    let pending_verifications: Int
    let ai_detections: Int
}

struct PredictResponse: Codable, Equatable, Hashable {
    let breed_name: String?
    let confidence_score: Double?
    let yield_estimate: Double?
    let milk_yield_range: String?
    let animal_type: String?
    let fat_content: String?
    let image_url: String?
    let message: String?
}

struct DetectionRecord: Codable, Identifiable {
    let id: Int
    let user_id: Int
    let breed_name: String
    let confidence_score: Double
    let yield_estimate: Double?
    let milk_yield_range: String?
    let animal_type: String?
    let fat_content: String?
    let image_path: String?
    let detected_at: String
}

// MARK: - Greeting Helper
struct GreetingHelper {
    static func getGreeting(for name: String) -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "Good Morning, \(name)"
        } else if hour < 17 {
            return "Good Afternoon, \(name)"
        } else {
            return "Good Evening, \(name)"
        }
    }
}

// MARK: - Localization
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @AppStorage("app_language") var appLanguage: String = "en"
    
    private let translations: [String: [String: String]] = [
        "en": [
            "home_tab": "Home",
            "analytics_tab": "Analytics",
            "reports_tab": "Reports",
            "home_greeting_morning": "Good Morning",
            "home_greeting_afternoon": "Good Afternoon",
            "home_greeting_evening": "Good Evening",
            "home_ready_to_scan": "Ready to scan your livestock?",
            "home_scan_animal": "Scan Animal",
            "home_ai_detection": "AI-powered breed detection",
            "home_recent_activity": "Recent Activity",
            "home_see_all": "See All",
            "home_no_activity": "No recent activity found",
            "home_total_scans": "Total Scans",
            "home_avg_confidence": "Avg. Confidence",
            "home_herd_size": "Herd Size",
            "home_compare_breeds": "Compare Breeds",
            "home_predict_yield": "Predict Yield",
            "home_vaccination_reminders": "Vaccination Reminders",
            "home_due_today": "Due Today",
            
            "analytics_hub_title": "Analytics Hub",
            "analytics_performance_overview": "Performance Overview",
            "analytics_last_30_days": "Last 30 days",
            "analytics_total_animals": "Total Animals",
            "analytics_avg_accuracy": "Avg. Accuracy",
            "analytics_herd_size": "Herd Size",
            "analytics_categories": "Analytics Categories",
            "analytics_perf_trends": "Performance Trends",
            "analytics_perf_trends_desc": "Track yield and productivity over time",
            "analytics_productivity": "Productivity Analytics",
            "analytics_productivity_desc": "Detailed herd productivity metrics",
            "analytics_herd_summary": "Herd Summary",
            "analytics_herd_summary_desc": "Complete overview of your livestock",
            "analytics_breed_dist": "Breed Distribution",
            "analytics_breed_dist_desc": "Analyze breed composition",
            "analytics_scan_history": "Scan History",
            "analytics_scan_history_desc": "Review all past scans",
            "analytics_yield_forecast": "Yield Forecast",
            "analytics_yield_forecast_desc": "AI-powered production predictions",
            "analytics_sync_note": "Analytics data syncs automatically across all your devices",
            
            "reports_title": "Reports",
            "reports_latest_analysis": "Latest Analysis",
            "reports_past_reports": "Past Reports",
            "reports_filter_title": "Filter Reports",
            "reports_no_scans": "No Scans Yet",
            
            "common_farmer": "Farmer",
            "common_all_caught_up": "All caught up!",
            "common_delete_title": "Delete Account",
            "common_delete_message": "Are you sure? All your animal records, scans, and personal data will be permanently removed. This action cannot be undone.",
            "common_delete_confirm": "Confirm & Delete",
            "common_cancel": "Cancel",
            "common_ok": "OK",
            
            "profile_title": "Profile",
            "profile_edit": "Edit Profile",
            "profile_settings": "Settings",
            "profile_notifications": "Notifications",
            "profile_help": "Help & Support",
            "profile_logout": "Log Out",
            "profile_delete": "Delete Account",
            "profile_animals": "Animals",
            "profile_scans": "Scans",
            "profile_health": "Health",
            "profile_member_since": "Member Since",
            "profile_health_score": "Health Score",
            "profile_delete_title": "Delete Account",
            "profile_delete_message": "Are you sure you want to delete your account? This action cannot be undone.",
            "profile_delete_confirm": "Delete",
            "profile_cancel": "Cancel",
            
            "edit_profile_title": "Edit Profile",
            "edit_profile_name": "Full Name",
            "edit_profile_email": "Email",
            "edit_profile_phone": "Phone Number",
            "edit_profile_location": "Location",
            "edit_profile_save": "Save Changes",
            "edit_profile_tap_photo": "Tap to change photo",
            
            "breed_profile_title": "Breed Profile",
            "breed_profile_about": "About the Breed",
            "breed_profile_analysis": "Detailed Analysis",
            "breed_profile_care": "Care Recommendations",
            "breed_profile_seasonal": "Seasonal Care",
            "breed_profile_economic": "Economic Potential",
            "breed_profile_milk_yield": "Milk Yield Analysis",
            "breed_profile_productivity": "Productivity Score",
            "breed_profile_fat": "Fat Content",
            "breed_profile_yield_est": "Yield Est.",
            "breed_profile_disease": "Disease Risk Profile",
            "breed_profile_climate": "Climate Suitability",
            "breed_profile_origin": "Origin",
            "breed_profile_purpose": "Purpose",
            "breed_profile_confidence": "Confidence",
            
            "scan_history_title": "Scan History",
            "scan_history_recent": "Recent Scans",
            "scan_history_total": "total scans",
            "scan_history_analytics": "View Analytics",
            
            "settings_title": "Settings",
            "settings_app_language": "App Language",
            "settings_selected": "Selected",
            "settings_select_language": "Select Language",
            "settings_system": "System & Security",
            "settings_dark_mode": "Dark Mode",
            "settings_push_notifications": "Push Notifications",
            "settings_biometric": "Biometric Lock",
            "settings_haptic": "Haptic Feedback",
            "settings_data": "Data Management",
            "settings_auto_sync": "Auto-Sync Records",
            "settings_location": "Location Services",
            "settings_about": "About Application",
            "settings_version": "App Version",
            "settings_privacy": "Privacy Policy"
        ],
        "te": [
            "home_tab": "మొదటి పేజీ",
            "analytics_tab": "విశ్లేషణలు",
            "reports_tab": "నివేదికలు",
            "home_greeting_morning": "శుభోదయం",
            "home_greeting_afternoon": "శుభ మధ్యాహ్నం",
            "home_greeting_evening": "శుభ సాయంత్రం",
            "home_ready_to_scan": "మీ పశువులను స్కాన్ చేయడానికి సిద్ధంగా ఉన్నారా?",
            "home_scan_animal": "జంతువును స్కాన్ చేయండి",
            "home_ai_detection": "AI-ఆధారిత జాతి గుర్తింపు",
            "home_recent_activity": "ఇటీవలి కార్యకలాపాలు",
            "home_see_all": "అన్నీ చూడండి",
            "home_no_activity": "ఇటీవలి కార్యకలాపాలు ఏవీ లేవు",
            "home_total_scans": "మొత్తం స్కాన్‌లు",
            "home_avg_confidence": "సగటు విశ్వాసం",
            "home_herd_size": "మంద పరిమాణం",
            "home_compare_breeds": "జాతులను పోల్చండి",
            "home_predict_yield": "దిగుబడిని ఊహించండి",
            "home_vaccination_reminders": "టీకా రిమైండర్‌లు",
            "home_due_today": "ఈరోజు గడువు",
            
            "analytics_hub_title": "విశ్లేషణ కేంద్రం",
            "analytics_performance_overview": "పనితీరు అవలోకనం",
            "analytics_last_30_days": "గత 30 రోజులు",
            "analytics_total_animals": "మొత్తం జంతువులు",
            "analytics_avg_accuracy": "సగటు ఖచ్చితత్వం",
            "analytics_herd_size": "మంద పరిమాణం",
            "analytics_categories": "విశ్లేషణ వర్గాలు",
            "analytics_perf_trends": "పనితీరు పోకడలు",
            "analytics_perf_trends_desc": "దిగుబడి మరియు ఉత్పాదకతను ట్రాక్ చేయండి",
            "analytics_productivity": "ఉత్పాదకత విశ్లేషణ",
            "analytics_productivity_desc": "వివరణాత్మక మంద ఉత్పాదకత కొలమానాలు",
            "analytics_herd_summary": "మంద సారాంశం",
            "analytics_herd_summary_desc": "మీ పశువుల పూర్తి అవలోకనం",
            "analytics_breed_dist": "జాతి పంపిణీ",
            "analytics_breed_dist_desc": "జాతి కూర్పును విశ్లేషించండి",
            "analytics_scan_history": "స్కాన్ చరిత్ర",
            "analytics_scan_history_desc": "అన్ని గత స్కాన్‌లను సమీక్షించండి",
            "analytics_yield_forecast": "దిగుబడి అంచనా",
            "analytics_yield_forecast_desc": "AI-ఆధారిత ఉత్పత్తి అంచనాలు",
            "analytics_sync_note": "విశ్లేషణ డేటా మీ అన్ని పరికరాల్లో ఆటోమేటిక్‌గా సింక్ అవుతుంది",
            
            "reports_title": "నివేదికలు",
            "reports_latest_analysis": "ఇటీవలి విశ్లేషణ",
            "reports_past_reports": "గత నివేదికలు",
            "reports_filter_title": "నివేదికలను ఫిల్టర్ చేయండి",
            "reports_no_scans": "ఇంకా స్కాన్‌లు లేవు",
            
            "common_farmer": "రైతు",
            "common_all_caught_up": "అన్నీ పూర్తయ్యాయి!",
            "common_delete_title": "ఖాతాను తొలగించండి",
            "common_delete_message": "మీరు ఖచ్చితంగా మీ ఖాతాను తొలగించాలనుకుంటున్నారా? మీ జంతువుల రికార్డులు, స్కాన్‌లు మరియు వ్యక్తిగత డేటా మొత్తం శాశ్వతంగా తొలగించబడుతుంది.",
            "common_delete_confirm": "నిర్ధారించండి & తొలగించండి",
            "common_cancel": "రద్దు",
            "common_ok": "సరే",
            
            "profile_title": "ప్రొఫైల్",
            "profile_edit": "ప్రొఫైల్ సవరించండి",
            "profile_settings": "సెట్టింగ్‌లు",
            "profile_notifications": "నోటిఫికేషన్‌లు",
            "profile_help": "సహాయం & మద్దతు",
            "profile_logout": "లాగ్ అవుట్",
            "profile_delete": "ఖాతాను తొలగించండి",
            "profile_animals": "జంతువులు",
            "profile_scans": "స్కాన్‌లు",
            "profile_health": "ఆరోగ్యం",
            "profile_member_since": "సభ్యత్వం ప్రారంభం",
            "profile_health_score": "ఆరోగ్య స్కోరు",
            "profile_delete_title": "ఖాతాను తొలగించండి",
            "profile_delete_message": "మీరు ఖచ్చితంగా మీ ఖాతాను తొలగించాలనుకుంటున్నారా? మీ జంతువుల రికార్డులు, స్కాన్‌లు మరియు వ్యక్తిగత డేటా మొత్తం శాశ్వతంగా తొలగించబడుతుంది.",
            "profile_delete_confirm": "నిర్ధారించండి & తొలగించండి",
            "profile_cancel": "రద్దు",
            
            "edit_profile_title": "ప్రొఫైల్ సవరించండి",
            "edit_profile_name": "పూర్తి పేరు",
            "edit_profile_email": "ఈమెయిల్",
            "edit_profile_phone": "ఫోన్ నంబర్",
            "edit_profile_location": "ప్రాంతం",
            "edit_profile_save": "మార్పులను సేవ్ చేయండి",
            "edit_profile_tap_photo": "ఫోటో మార్చడానికి నొక్కండి",
            
            "breed_profile_title": "జాతి ప్రొఫైల్",
            "breed_profile_about": "జాతి గురించి",
            "breed_profile_analysis": "వివరణాత్మక విశ్లేషణ",
            "breed_profile_care": "సంరక్షణ సిఫార్సులు",
            "breed_profile_seasonal": "కాలానుగుణ సంరక్షణ",
            "breed_profile_economic": "ఆర్థిక సామర్థ్యం",
            "breed_profile_milk_yield": "పాల దిగుబడి విశ్లేషణ",
            "breed_profile_productivity": "ఉత్పాదకత స్కోరు",
            "breed_profile_fat": "కొవ్వు శాతం",
            "breed_profile_yield_est": "దిగుబడి అంచనా",
            "breed_profile_disease": "వ్యాధి ప్రమాద ప్రొఫైల్",
            "breed_profile_climate": "వాతావరణ అనుకూలత",
            "breed_profile_origin": "మూలం",
            "breed_profile_purpose": "ఉద్దేశ్యం",
            "breed_profile_confidence": "విశ్వాసం",
            
            "scan_history_title": "స్కాన్ చరిత్ర",
            "scan_history_recent": "ఇటీవలి స్కాన్‌లు",
            "scan_history_total": "మొత్తం స్కాన్‌లు",
            "scan_history_analytics": "విశ్లేషణలను చూడండి",
            
            "settings_title": "సెట్టింగ్‌లు",
            "settings_app_language": "యాప్ భాష",
            "settings_selected": "ఎంచుకున్నది",
            "settings_select_language": "భాషను ఎంచుకోండి",
            "settings_system": "సిస్టమ్ & భద్రత",
            "settings_dark_mode": "డార్క్ మోడ్",
            "settings_push_notifications": "పుష్ నోటిఫికేషన్‌లు",
            "settings_biometric": "బయోమెట్రిక్ లాక్",
            "settings_haptic": "హాప్టిక్ ఫీడ్‌బ్యాక్",
            "settings_data": "డేటా నిర్వహణ",
            "settings_auto_sync": "ఆటో-సింక్ రికార్డులు",
            "settings_location": "లొకేషన్ సేవలు",
            "settings_about": "యాప్ గురించి",
            "settings_version": "యాప్ వెర్షన్",
            "settings_privacy": "గోప్యతా విధానం"
        ],
        "hi": [
            "home_tab": "होम",
            "analytics_tab": "विश्लेषण",
            "reports_tab": "रिपोर्ट",
            "home_greeting_morning": "शुभ प्रभात",
            "home_greeting_afternoon": "शुभ दोपहर",
            "home_greeting_evening": "शुभ संध्या",
            "home_ready_to_scan": "अपने पशुओं को स्कैन करने के लिए तैयार हैं?",
            "home_scan_animal": "जानवर स्कैन करें",
            "home_ai_detection": "AI-आधारित नस्ल पहचान",
            "home_recent_activity": "हाल की गतिविधि",
            "home_see_all": "सभी देखें",
            "home_no_activity": "कोई हालिया गतिविधि नहीं मिली",
            "home_total_scans": "कुल स्कैन",
            "home_avg_confidence": "औसत आत्मविश्वास",
            "home_herd_size": "झुंड का आकार",
            "home_compare_breeds": "नस्लों की तुलना करें",
            "home_predict_yield": "उपज का अनुमान",
            "home_vaccination_reminders": "टीकाकरण अनुस्मारक",
            "home_due_today": "आज देय",
            
            "analytics_hub_title": "विश्लेषण केंद्र",
            "analytics_performance_overview": "प्रदर्शन अवलोकन",
            "analytics_last_30_days": "पिछले 30 दिन",
            "analytics_total_animals": "कुल जानवर",
            "analytics_avg_accuracy": "औसत शुद्धता",
            "analytics_herd_size": "झुंड का आकार",
            "analytics_categories": "विश्लेषण श्रेणियां",
            "analytics_perf_trends": "प्रदर्शन रुझान",
            "analytics_perf_trends_desc": "समय के साथ उपज और उत्पादकता ट्रैक करें",
            "analytics_productivity": "उत्पादकता विश्लेषण",
            "analytics_productivity_desc": "विस्तृत झुंड उत्पादकता मेट्रिक्स",
            "analytics_herd_summary": "झुंड सारांश",
            "analytics_herd_summary_desc": "आपके पशुधन का पूर्ण विवरण",
            "analytics_breed_dist": "नस्ल वितरण",
            "analytics_breed_dist_desc": "नस्ल संरचना का विश्लेषण करें",
            "analytics_scan_history": "स्कैन इतिहास",
            "analytics_scan_history_desc": "पिछले सभी स्कैन की समीक्षा करें",
            "analytics_yield_forecast": "उपज पूर्वानुमान",
            "analytics_yield_forecast_desc": "AI-संचालित उत्पादन भविष्यवाणियां",
            "analytics_sync_note": "विश्लेषण डेटा आपके सभी उपकरणों पर अपने आप सिंक हो जाता है",
            
            "reports_title": "रिपोर्ट",
            "reports_latest_analysis": "नवीनतम विश्लेषण",
            "reports_past_reports": "पिछली रिपोर्ट",
            "reports_filter_title": "रिपोर्ट फ़िल्टर करें",
            "reports_no_scans": "अभी तक कोई स्कैन नहीं",
            
            "common_farmer": "किसान",
            "common_all_caught_up": "सब कुछ तैयार है!",
            "common_delete_title": "खाता हटाएं",
            "common_delete_message": "क्या आप वाकई अपना खाता हटाना चाहते हैं? आपके सभी जानवरों के रिकॉर्ड, स्कैन और व्यक्तिगत डेटा स्थायी रूप से हटा दिए जाएंगे।",
            "common_delete_confirm": "पुष्टि करें और हटाएं",
            "common_cancel": "रद्द करें",
            "common_ok": "ठीक है",
            
            "profile_title": "प्रोफ़ाइल",
            "profile_edit": "प्रोफ़ाइल संपादित करें",
            "profile_settings": "सेटिंग्स",
            "profile_notifications": "सूचनाएं",
            "profile_help": "सहायता और समर्थन",
            "profile_logout": "लॉग आउट",
            "profile_delete": "खाता हटाएं",
            "profile_animals": "जानवर",
            "profile_scans": "स्कैन",
            "profile_health": "स्वास्थ्य",
            "profile_member_since": "सदस्यता",
            "profile_delete_title": "खाता हटाएं",
            "profile_delete_message": "क्या आप वाकई अपना खाता हटाना चाहते हैं? आपके सभी जानवरों के रिकॉर्ड, स्कैन और व्यक्तिगत डेटा स्थायी रूप से हटा दिए जाएंगे।",
            "profile_delete_confirm": "पुष्टि करें और हटाएं",
            "profile_cancel": "रद्द करें",
            
            "edit_profile_title": "प्रोफ़ाइल संपादित करें",
            "edit_profile_name": "पूरा नाम",
            "edit_profile_email": "ईमेल",
            "edit_profile_phone": "फ़ोन नंबर",
            "edit_profile_location": "स्थान",
            "edit_profile_save": "परिवर्तन सहेजें",
            "edit_profile_tap_photo": "फोटो बदलने के लिए टैप करें",
            
            "breed_profile_title": "नस्ल प्रोफ़ाइल",
            "breed_profile_about": "नस्ल के बारे में",
            "breed_profile_analysis": "विस्तृत विश्लेषण",
            "breed_profile_care": "देखभाल की सिफारिशें",
            "breed_profile_seasonal": "मौसमी देखभाल",
            "breed_profile_economic": "आर्थिक क्षमता",
            "breed_profile_milk_yield": "दूध उत्पादन विश्लेषण",
            "breed_profile_productivity": "उत्पादकता स्कोर",
            "breed_profile_fat": "वसा सामग्री",
            "breed_profile_yield_est": "उपज अनुमान",
            "breed_profile_disease": "रोग जोखिम प्रोफ़ाइल",
            "breed_profile_climate": "जलवायु अनुकूलता",
            "breed_profile_origin": "उत्पत्ति",
            "breed_profile_purpose": "उद्देश्य",
            "breed_profile_confidence": "विश्वास",
            
            "scan_history_title": "स्कैन इतिहास",
            "scan_history_recent": "हालिया स्कैन",
            "scan_history_total": "कुल स्कैन",
            "scan_history_analytics": "विश्लेषण देखें",
            
            "settings_title": "सेटिंग्स",
            "settings_app_language": "ऐप भाषा",
            "settings_selected": "चुनी हुई",
            "settings_select_language": "भाषा चुनें",
            "settings_system": "सिस्टम और सुरक्षा",
            "settings_dark_mode": "डार्क मोड",
            "settings_push_notifications": "पुश सूचनाएं",
            "settings_biometric": "बायोमेट्रिक लॉक",
            "settings_haptic": "हैप्टिक फीडबैक",
            "settings_data": "डेटा प्रबंधन",
            "settings_auto_sync": "ऑटो-सिंक रिकॉर्ड",
            "settings_location": "स्थान सेवाएं",
            "settings_about": "ऐप के बारे में",
            "settings_version": "ऐप संस्करण",
            "settings_privacy": "गोपनीयता नीति"
        ],
        "ta": [
            "home_tab": "முகப்பு",
            "analytics_tab": "பகுப்பாய்வு",
            "reports_tab": "அறிக்கைகள்",
            "home_greeting_morning": "காலை வணக்கம்",
            "home_greeting_afternoon": "மதிய வணக்கம்",
            "home_greeting_evening": "மாலை வணக்கம்",
            "home_ready_to_scan": "உங்கள் விலங்குகளை ஸ்கேன் செய்ய தயாரா?",
            "home_scan_animal": "விலங்கை ஸ்கேன் செய்",
            "home_ai_detection": "AI-அடிப்படையிலான இனம் கண்டறிதல்",
            "home_recent_activity": "சமீபத்திய செயல்பாடு",
            "home_see_all": "அனைத்தையும் காண்க",
            "home_no_activity": "சமீபத்திய செயல்பாடு எதுவும் இல்லை",
            "home_total_scans": "மொத்த ஸ்கேன்கள்",
            "home_avg_confidence": "சராசரி நம்பிக்கை",
            "home_herd_size": "மந்தை அளவு",
            "home_compare_breeds": "இனங்களை ஒப்பிடுக",
            "home_predict_yield": "மகசூலை கணிப்போம்",
            "home_vaccination_reminders": "தடுப்பூசி நினைவூட்டல்கள்",
            "home_due_today": "இன்று செலுத்த வேண்டியவை",
            "analytics_hub_title": "பகுப்பாய்வு மையம்",
            "analytics_performance_overview": "செயல்திறன் கண்ணோட்டம்",
            "analytics_last_30_days": "கடந்த 30 நாட்கள்",
            "analytics_total_animals": "மொத்த விலங்குகள்",
            "analytics_avg_accuracy": "சராசரி துல்லியம்",
            "analytics_herd_size": "மந்தை அளவு",
            "analytics_categories": "பகுப்பாய்வு பிரிவுகள்",
            "analytics_perf_trends": "செயல்திறன் போக்குகள்",
            "analytics_perf_trends_desc": "மகசூல் மற்றும் உற்பத்தித் திறனைப் பின்தொடரவும்",
            "analytics_productivity": "உற்பத்தித்திறன் பகுப்பாய்வு",
            "analytics_productivity_desc": "விரிவான மந்தை உற்பத்தித்திறன் அளவீடுகள்",
            "analytics_herd_summary": "மந்தை சுருக்கம்",
            "analytics_herd_summary_desc": "உங்கள் கால்நடைகளின் முழு கண்ணோட்டம்",
            "analytics_breed_dist": "இனம் விநியோகம்",
            "analytics_breed_dist_desc": "இனம் கலவையை பகுப்பாய்வு செய்யுங்கள்",
            "analytics_scan_history": "ஸ்கேன் வரலாறு",
            "analytics_scan_history_desc": "கடந்தகால ஸ்கேன்களை மதிப்பாய்வு செய்யவும்",
            "analytics_yield_forecast": "மகசூல் கணிப்பு",
            "analytics_yield_forecast_desc": "AI-இயங்கும் உற்பத்தி கணிப்புகள்",
            "analytics_sync_note": "பகுப்பாய்வு தரவு உங்கள் எல்லா சாதனங்களிலும் தானாகவே ஒத்திசைக்கப்படும்",
            "reports_title": "அறிக்கைகள்",
            "reports_latest_analysis": "சமீபத்திய பகுப்பாய்வு",
            "reports_past_reports": "கடந்தகால அறிக்கைகள்",
            "reports_filter_title": "அறிக்கைகளை வடிகட்டவும்",
            "reports_no_scans": "இன்னும் ஸ்கேன்கள் இல்லை",
            "common_farmer": "விவசாயி",
            "common_all_caught_up": "எல்லாம் முடிந்தது!",
            "common_delete_title": "கணக்கை நீக்கு",
            "common_delete_message": "உங்கள் கணக்கை நீக்க விரும்புகிறீர்களா? உங்கள் அனைத்து விலங்கு பதிவுகள், ஸ்கேன்கள் மற்றும் தனிப்பட்ட தரவு நிரந்தரமாக நீக்கப்படும்.",
            "common_delete_confirm": "உறுதிப்படுத்தி நீக்கு",
            "common_cancel": "ரத்துசெய்",
            "common_ok": "சரி",
            "profile_title": "சுயவிவரம்",
            "profile_edit": "சுயவிவரத்தைத் திருத்து",
            "profile_settings": "அமைப்புகள்",
            "profile_notifications": "அறிவிப்புகள்",
            "profile_help": "உதவி மற்றும் ஆதரவு",
            "profile_logout": "வெளியேறு",
            "profile_delete": "கணக்கை நீக்கு",
            "profile_animals": "விலங்குகள்",
            "profile_scans": "ஸ்கேன்கள்",
            "profile_health": "ஆரோக்கியம்",
            "profile_member_since": "உறுப்பினர் காலம்",
            "edit_profile_title": "சுயவிவரத்தைத் திருத்து",
            "edit_profile_name": "முழு பெயர்",
            "edit_profile_email": "மின்னஞ்சல்",
            "edit_profile_phone": "தொலைபேசி எண்",
            "edit_profile_location": "இடம்",
            "edit_profile_save": "மாற்றங்களைச் சேமி",
            "edit_profile_tap_photo": "புகைப்படத்தை மாற்ற தட்டவும்",
            "settings_title": "அமைப்புகள்",
            "settings_app_language": "பயன்பாட்டு மொழி",
            "settings_selected": "தேர்ந்தெடுக்கப்பட்டது",
            "settings_select_language": "மொழியைத் தேர்ந்தெடுக்கவும்",
            "settings_system": "முறைமை மற்றும் பாதுகாப்பு",
            "settings_dark_mode": "இருண்ட பயன்முறை",
            "settings_push_notifications": "புஷ் அறிவிப்புகள்",
            "settings_biometric": "பயோமெட்ரிக் பூட்டு",
            "settings_haptic": "தொடு உணர்வு பதில்",
            "settings_data": "தரவு மேலாண்மை",
            "settings_auto_sync": "தானியங்கி ஒத்திசைவு",
            "settings_location": "இடத் சேவைகள்",
            "settings_about": "பயன்பாட்டைப் பற்றி",
            "settings_version": "பதிப்பு",
            "settings_privacy": "தனியுரிமைக் கொள்கை"
        ],
        "kn": [
            "home_tab": "ಮುಖಪುಟ",
            "analytics_tab": "ವಿಶ್ಲೇಷಣೆ",
            "reports_tab": "ವರದಿಗಳು",
            "home_greeting_morning": "ಶುಭೋದಯ",
            "home_greeting_afternoon": "ಶುಭ ಮಧ್ಯಾಹ್ನ",
            "home_greeting_evening": "ಶುಭ ಸಂಜೆ",
            "home_ready_to_scan": "ನಿಮ್ಮ ಪ್ರಾಣಿಗಳನ್ನು ಸ್ಕ್ಯಾನ್ ಮಾಡಲು ಸಿದ್ಧರಿದ್ದೀರಾ?",
            "home_scan_animal": "ಪ್ರಾಣಿ ಸ್ಕ್ಯಾನ್ ಮಾಡಿ",
            "home_ai_detection": "AI-ಆಧಾರಿತ ತಳಿ ಪತ್ತೆ",
            "home_recent_activity": "ಸಮೀಪದ ಚಟುವಟಿಕೆ",
            "home_see_all": "ಎಲ್ಲವನ್ನೂ ನೋಡಿ",
            "home_no_activity": "ಯಾವುದೇ ಸಮೀಪದ ಚಟುವಟಿಕೆ ಇಲ್ಲ",
            "home_total_scans": "ಒಟ್ಟು ಸ್ಕ್ಯಾನ್‌ಗಳು",
            "home_avg_confidence": "ಸರಾಸರಿ ವಿಶ್ವಾಸ",
            "home_herd_size": "ಮಂದೆಯ ಗಾತ್ರ",
            "home_compare_breeds": "ತಳಿಗಳನ್ನು ಹೋಲಿಕೆ ಮಾಡಿ",
            "home_predict_yield": "ಇಳುವರಿ ಮುನ್ಸೂಚನೆ",
            "home_vaccination_reminders": "ಲಸಿಕೆ ಜ್ಞಾಪನೆಗಳು",
            "home_due_today": "ಇಂದು ಬಾಕಿ ಇರುವುದು",
            "analytics_hub_title": "ವಿಶ್ಲೇಷಣಾ ಕೇಂದ್ರ",
            "analytics_performance_overview": "ಕಾರ್ಯಕ್ಷಮತೆಯ ಅವಲೋಕನ",
            "analytics_last_30_days": "ಕಳೆದ 30 ದಿನಗಳು",
            "analytics_total_animals": "ಒಟ್ಟು ಪ್ರಾಣಿಗಳು",
            "analytics_avg_accuracy": "ಸರಾಸರಿ ನಿಖರತೆ",
            "analytics_herd_size": "ಮಂದೆಯ ಗಾತ್ರ",
            "analytics_categories": "ವಿಶ್ಲೇಷಣಾ ವಿಭಾಗಗಳು",
            "analytics_perf_trends": "ಕಾರ್ಯಕ್ಷಮತೆಯ ಪ್ರವೃತ್ತಿಗಳು",
            "analytics_perf_trends_desc": "ಇಳುವರಿ ಮತ್ತು ಉತ್ಪಾದಕತೆಯನ್ನು ಟ್ರ್ಯಾಕ್ ಮಾಡಿ",
            "analytics_productivity": "ಉತ್ಪಾದಕತೆಯ ವಿಶ್ಲೇಷಣೆ",
            "analytics_productivity_desc": "ವಿವರವಾದ ಮಂದೆ ಉತ್ಪಾದಕತೆಯ ಮೆಟ್ರಿಕ್‌ಗಳು",
            "analytics_herd_summary": "ಮಂದೆಯ ಸಾರಾಂಶ",
            "analytics_herd_summary_desc": "ನಿಮ್ಮ ಜಾನುವಾರುಗಳ ಸಂಪೂರ್ಣ ಅವಲೋಕನ",
            "analytics_breed_dist": "ತಳಿ ವಿತರಣೆ",
            "analytics_breed_dist_desc": "ತಳಿ ಸಂಯೋಜನೆಯನ್ನು ವಿಶ್ಲೇಷಿಸಿ",
            "analytics_scan_history": "ಸ್ಕ್ಯಾನ್ ಇತಿಹಾಸ",
            "analytics_scan_history_desc": "ಕಳೆದ ಸ್ಕ್ಯಾನ್‌ಗಳನ್ನು ಪರಿಶೀಲಿಸಿ",
            "analytics_yield_forecast": "ಇಳುವರಿ ಮುನ್ಸೂಚನೆ",
            "analytics_yield_forecast_desc": "AI-ಚಾಲಿತ ಉತ್ಪಾದನಾ ಮುನ್ಸೂಚನೆಗಳು",
            "analytics_sync_note": "ವಿಶ್ಲೇಷಣಾ ಡೇಟಾ ನಿಮ್ಮೆಲ್ಲಾ ಸಾಧನಗಳಲ್ಲಿ ಸ್ವಯಂಚಾಲಿತವಾಗಿ ಸಿಂಕ್ ಆಗುತ್ತದೆ",
            "reports_title": "ವರದಿಗಳು",
            "reports_latest_analysis": "ಇತ್ತೀಚಿನ ವಿಶ್ಲೇಷಣೆ",
            "reports_past_reports": "ಹಿಂದಿನ ವರದಿಗಳು",
            "reports_filter_title": "ವರದಿಗಳನ್ನು ಫಿಲ್ಟರ್ ಮಾಡಿ",
            "reports_no_scans": "ಇನ್ನೂ ಯಾವುದೇ ಸ್ಕ್ಯಾನ್‌ಗಳಿಲ್ಲ",
            "common_farmer": "ರೈತ",
            "common_all_caught_up": "ಎಲ್ಲವೂ ಮುಗಿದಿದೆ!",
            "common_delete_title": "ಖಾತೆಯನ್ನು ಅಳಿಸಿ",
            "common_delete_message": "ನಿಮ್ಮ ಖಾತೆಯನ್ನು ಅಳಿಸಲು ನೀವು ಖಚಿತವಾಗಿ ಬಯಸುವಿರಾ? ಈ ಕ್ರಿಯೆಯನ್ನು ಹಿಂತಿರುಗಿಸಲು ಸಾಧ್ಯವಿಲ್ಲ.",
            "common_delete_confirm": "ಅಳಿಸಿ",
            "common_cancel": "ರದ್ದುಮಾಡು",
            "common_ok": "ಸರಿ",
            "profile_title": "ಪ್ರೊಫೈಲ್",
            "profile_edit": "ಪ್ರೊಫೈಲ್ ಸಂಪಾದಿಸಿ",
            "profile_settings": "ಸೆಟ್ಟಿಂಗ್‌ಗಳು",
            "profile_notifications": "ಅಧಿಸೂಚನೆಗಳು",
            "profile_help": "ಸಹಾಯ ಮತ್ತು ಬೆಂಬಲ",
            "profile_logout": "ಲಾಗ್ ಔಟ್",
            "profile_delete": "ಖಾತೆಯನ್ನು ಅಳಿಸಿ",
            "profile_animals": "ಪ್ರಾಣಿಗಳು",
            "profile_scans": "ಸ್ಕ್ಯಾನ್‌ಗಳು",
            "profile_health": "ಆರೋಗ್ಯ",
            "profile_member_since": "ಸದಸ್ಯತ್ವದ ಅವಧಿ",
            "edit_profile_title": "ಪ್ರೊಫೈಲ್ ಸಂಪಾದಿಸಿ",
            "edit_profile_name": "ಪೂರ್ಣ ಹೆಸರು",
            "edit_profile_email": "ಇಮೇಲ್",
            "edit_profile_phone": "ಫೋನ್ ಸಂಖ್ಯೆ",
            "edit_profile_location": "ಸ್ಥಳ",
            "edit_profile_save": "ಬದಲಾವಣೆಗಳನ್ನು ಉಳಿಸಿ",
            "edit_profile_tap_photo": "ಫೋಟೋ ಬದಲಾಯಿಸಲು ಟ್ಯಾಪ್ ಮಾಡಿ",
            "settings_title": "ಸೆಟ್ಟಿಂಗ್‌ಗಳು",
            "settings_app_language": "ಅಪ್ಲಿಕೇಶನ್ ಭಾಷೆ",
            "settings_selected": "ಆಯ್ಕೆಮಾಡಲಾಗಿದೆ",
            "settings_select_language": "ಭಾಷೆಯನ್ನು ಆರಿಸಿ",
            "settings_system": "ಸಿಸ್ಟಮ್ ಮತ್ತು ಭದ್ರತೆ",
            "settings_dark_mode": "ಡಾರ್ಕ್ ಮೋಡ್",
            "settings_push_notifications": "ಅಧಿಸೂಚನೆಗಳು",
            "settings_biometric": "ಬಯೋಮೆಟ್ರಿಕ್ ಲಾಕ್",
            "settings_haptic": "ಸ್ಪರ್ಶ ಪ್ರತಿಕ್ರಿಯೆ",
            "settings_data": "ಡೇಟಾ ನಿರ್ವಹಣೆ",
            "settings_auto_sync": "ಸ್ವಯಂಚಾಲಿತ ಸಿಂಕ್",
            "settings_location": "ಸ್ಥಳ ಸೇವೆಗಳು",
            "settings_about": "ಅಪ್ಲಿಕೇಶನ್ ಬಗ್ಗೆ",
            "settings_version": "ಆವೃತ್ತಿ",
            "settings_privacy": "ಗೌಪ್ಯತಾ ನೀತಿ"
        ]
    ]
    
    func t(_ key: String) -> String {
        return translations[appLanguage]?[key] ?? translations["en"]?[key] ?? key
    }
}

// MARK: - Extensions
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

