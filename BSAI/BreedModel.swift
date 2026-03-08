import SwiftUI

struct BreedInfo: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: String
    let origin: String
    let milkYield: String // e.g. "28L"
    let cost: String      // e.g. "High"
    let climate: String   // e.g. "Moderate"
    let fatContent: String
    let climateTolerance: String
    let feedCost: String
    let productivity: String
}

struct BreedRepository {
    static let allBreeds: [BreedInfo] = [
        BreedInfo(
            name: "Holstein Friesian",
            category: "Dairy Cattle",
            origin: "Netherlands",
            milkYield: "28L",
            cost: "High",
            climate: "Moderate",
            fatContent: "3.5-4%",
            climateTolerance: "Moderate",
            feedCost: "High",
            productivity: "Excellent"
        ),
        BreedInfo(
            name: "Jersey",
            category: "Dairy Cattle",
            origin: "UK",
            milkYield: "20L",
            cost: "Medium",
            climate: "High",
            fatContent: "5-6%",
            climateTolerance: "Good",
            feedCost: "Medium",
            productivity: "Good"
        ),
        BreedInfo(
            name: "Gir",
            category: "Dairy Cattle",
            origin: "India",
            milkYield: "12L",
            cost: "Low",
            climate: "Excellent",
            fatContent: "4.5-5%",
            climateTolerance: "Excellent",
            feedCost: "Low",
            productivity: "Moderate"
        ),
        BreedInfo(
            name: "Sahiwal",
            category: "Dairy Cattle",
            origin: "Pakistan",
            milkYield: "15L",
            cost: "Low",
            climate: "Excellent",
            fatContent: "4.5-5%",
            climateTolerance: "Excellent",
            feedCost: "Low",
            productivity: "Moderate"
        ),
        BreedInfo(
            name: "Brown Swiss",
            category: "Dual Purpose",
            origin: "Switzerland",
            milkYield: "22L",
            cost: "Medium",
            climate: "High",
            fatContent: "4-4.5%",
            climateTolerance: "Good",
            feedCost: "Medium",
            productivity: "Good"
        )
    ]
    
    static func getBreed(named name: String) -> BreedInfo? {
        allBreeds.first { $0.name.lowercased() == name.lowercased() }
    }
}
