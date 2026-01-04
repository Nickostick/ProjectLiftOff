import Foundation

/// Represents an exercise within a workout day template
/// Example: "Bicep Curl" with 3 sets x 10 reps @ 20lbs
struct Exercise: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var targetSets: Int
    var targetReps: Int
    var targetWeight: Double
    var weightUnit: WeightUnit
    var notes: String
    var order: Int
    var restSeconds: Int
    
    init(
        id: String = UUID().uuidString,
        name: String,
        targetSets: Int = 3,
        targetReps: Int = 10,
        targetWeight: Double = 0,
        weightUnit: WeightUnit = .pounds,
        notes: String = "",
        order: Int = 0,
        restSeconds: Int = 60
    ) {
        self.id = id
        self.name = name
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.targetWeight = targetWeight
        self.weightUnit = weightUnit
        self.notes = notes
        self.order = order
        self.restSeconds = restSeconds
    }
    
    /// Formatted string for display (e.g., "3 x 10 @ 20 lbs")
    var formattedTarget: String {
        if targetWeight > 0 {
            return "\(targetSets) × \(targetReps) @ \(Int(targetWeight)) \(weightUnit.abbreviation)"
        } else {
            return "\(targetSets) × \(targetReps)"
        }
    }
    
    /// Calculate estimated volume (sets * reps * weight)
    var estimatedVolume: Double {
        Double(targetSets * targetReps) * targetWeight
    }
}

/// Weight unit options
enum WeightUnit: String, Codable, CaseIterable {
    case pounds = "lbs"
    case kilograms = "kg"
    
    var abbreviation: String {
        rawValue
    }
    
    var fullName: String {
        switch self {
        case .pounds: return "Pounds"
        case .kilograms: return "Kilograms"
        }
    }
}

// MARK: - Firestore Dictionary Conversion
extension Exercise {
    var firestoreData: [String: Any] {
        [
            "id": id,
            "name": name,
            "targetSets": targetSets,
            "targetReps": targetReps,
            "targetWeight": targetWeight,
            "weightUnit": weightUnit.rawValue,
            "notes": notes,
            "order": order,
            "restSeconds": restSeconds
        ]
    }
    
    init?(from data: [String: Any]) {
        guard let id = data["id"] as? String,
              let name = data["name"] as? String else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.targetSets = data["targetSets"] as? Int ?? 3
        self.targetReps = data["targetReps"] as? Int ?? 10
        self.targetWeight = data["targetWeight"] as? Double ?? 0
        self.notes = data["notes"] as? String ?? ""
        self.order = data["order"] as? Int ?? 0
        self.restSeconds = data["restSeconds"] as? Int ?? 60
        
        if let unitString = data["weightUnit"] as? String,
           let unit = WeightUnit(rawValue: unitString) {
            self.weightUnit = unit
        } else {
            self.weightUnit = .pounds
        }
    }
}
