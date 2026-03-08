import SwiftUI

// MARK: - App Entry Point
// Single NavigationStack with path-based navigation.
// Every screen is pushed onto `path`; resetting `path = []` returns to root (SplashView/LoginView).

@main
struct BreedSureAIApp: App {
    @AppStorage("app_language") private var appLanguage: String = "en"
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(\.locale, .init(identifier: appLanguage))
        }
    }
}

import Foundation
import Combine

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var currentPrediction: PredictResponse?
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
    
    // Change this to your Mac's IP address if testing on a real device
    private let baseURL = "http://127.0.0.1:8000"
    
    init() {
        self.authToken = UserDefaults.standard.string(forKey: "authToken")
    }
    
    // MARK: - API Calls
    
    func register(user: RegisterRequest, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(user)
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
        
        do {
            request.httpBody = try JSONEncoder().encode(user)
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
        
        let body = ["email": email, "otp_code": otp]
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
                DispatchQueue.main.async { completion(.success("Success")) }
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
        let url = URL(string: "\(baseURL)/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(credentials)
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
                        completion(.success("Success"))
                    }
                } catch {
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            } else {
                var errorMsg = "Login failed"
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let detail = json["detail"] as? String {
                    errorMsg = detail
                }
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg]))) }
            }
        }.resume()
    }
    
    func logout() {
        self.authToken = nil
        self.currentUser = nil
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
    
    // MARK: - Analytics & Reports
    
    func saveDetection(breedName: String, confidenceScore: Double, yieldEstimate: Double?, completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = authToken else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])))
            return
        }

        let url = URL(string: "\(baseURL)/detections")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "breed_name": breedName,
            "confidence_score": confidenceScore,
            "yield_estimate": yieldEstimate as Any
        ]
        
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
    
    func uploadImageForPrediction(image: UIImage, completion: @escaping (Result<PredictResponse, Error>) -> Void) {
        guard let token = authToken else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])))
            return
        }
        
        guard let url = URL(string: "\(baseURL)/predict") else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Image processing failed"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No response"]))) }
                return
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                var errorMsg = "Failed to analyze image"
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let detail = json["detail"] as? String {
                    errorMsg = detail
                }
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg]))) }
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(PredictResponse.self, from: data)
                DispatchQueue.main.async { completion(.success(decoded)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
    
    func fetchBPAStats(completion: @escaping (Result<BPAStats, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/bpa/dashboard-stats") else { return }
        
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
    
    func fetchReportSummary(completion: @escaping (Result<AnalyticsSummaryResponse, Error>) -> Void) {
        guard let token = authToken else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])))
            return
        }
        
        let url = URL(string: "\(baseURL)/reports/summary")!
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
}

// MARK: - Models
struct RecentActivity: Codable, Identifiable {
    var id: String { title + time + subtitle }
    let title: String
    let subtitle: String
    let time: String
    let type: String
}

struct AnimalRegistrationData: Codable, Hashable {
    let ear_tag_number: String
    let species: String
    let sex: String
    let breed: String
    let dob: String?
    let owner_name: String
    let address: String?
    let village: String
    let district: String
    let state: String
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

    enum CodingKeys: String, CodingKey {
        case id, email
        case fullName = "full_name"
        case phoneNumber = "phone_number"
    }
}

struct TokenResponse: Codable {
    let access_token: String
    let token_type: String
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
    let pie_chart: [APIPieChartData]
    let bar_chart: [APIBarChartData]
}

struct BPAStats: Codable {
    let total_animals: Int
    let total_owners: Int
    let pending_verifications: Int
    let ai_detections: Int
}

struct PredictResponse: Codable {
    let breed_name: String
    let confidence_score: Double
    let yield_estimate: Double?
    let animal_type: String
    let fat_content: String
}

struct DetectionRecord: Codable, Identifiable {
    let id: Int
    let user_id: Int
    let breed_name: String
    let confidence_score: Double
    let yield_estimate: Double?
    let animal_type: String
    let fat_content: String
    let detected_at: String
}
