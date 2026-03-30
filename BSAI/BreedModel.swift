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
        ),
        BreedInfo(
            name: "Murrah",
            category: "Buffalo",
            origin: "India (Haryana)",
            milkYield: "13.5L",
            cost: "Medium",
            climate: "Excellent",
            fatContent: "7.5-8%",
            climateTolerance: "Excellent",
            feedCost: "Low",
            productivity: "Excellent"
        ),
        BreedInfo(
            name: "Jaffrabadi",
            category: "Buffalo",
            origin: "India (Gujarat)",
            milkYield: "17.5L",
            cost: "Medium",
            climate: "Excellent",
            fatContent: "8-9%",
            climateTolerance: "Excellent",
            feedCost: "Low",
            productivity: "Excellent"
        ),
        BreedInfo(
            name: "Pandharpuri",
            category: "Buffalo",
            origin: "India (Maharashtra)",
            milkYield: "8L",
            cost: "Low",
            climate: "Excellent",
            fatContent: "7-8%",
            climateTolerance: "Excellent",
            feedCost: "Low",
            productivity: "Good"
        ),
        BreedInfo(
            name: "Toda",
            category: "Buffalo",
            origin: "India (Tamil Nadu)",
            milkYield: "5L",
            cost: "Low",
            climate: "Moderate",
            fatContent: "8%",
            climateTolerance: "High",
            feedCost: "Low",
            productivity: "Moderate"
        ),
        BreedInfo(
            name: "Deoni",
            category: "Dairy Cattle",
            origin: "India (Maharashtra)",
            milkYield: "4L",
            cost: "Low",
            climate: "Excellent",
            fatContent: "4.3%",
            climateTolerance: "High",
            feedCost: "Low",
            productivity: "Moderate"
        ),
        BreedInfo(
            name: "Khillari",
            category: "Draught Cattle",
            origin: "India (Maharashtra)",
            milkYield: "2L",
            cost: "Low",
            climate: "Excellent",
            fatContent: "4.2%",
            climateTolerance: "Very High",
            feedCost: "Low",
            productivity: "Low (Work-focused)"
        ),
        BreedInfo(
            name: "Kankrej",
            category: "Dairy Cattle",
            origin: "India (Gujarat)",
            milkYield: "12.5L",
            cost: "Medium",
            climate: "Excellent",
            fatContent: "4.8%",
            climateTolerance: "Excellent",
            feedCost: "Low",
            productivity: "Moderate"
        ),
        BreedInfo(
            name: "Kangayam",
            category: "Draught Cattle",
            origin: "India (Tamil Nadu)",
            milkYield: "3L",
            cost: "Low",
            climate: "Excellent",
            fatContent: "4.5%",
            climateTolerance: "Excellent",
            feedCost: "Low",
            productivity: "Moderate"
        )
    ]
    
    static func getBreed(named name: String) -> BreedInfo? {
        allBreeds.first { $0.name.lowercased() == name.lowercased() }
    }
}
