import Foundation

/// Represents a personal record for a specific exercise
struct PersonalRecord: Identifiable, Codable, Hashable {
    var id: String
    var userId: String
    var exerciseName: String
    var weight: Double
    var reps: Int
    var weightUnit: WeightUnit
    var achievedAt: Date
    var workoutLogId: String?
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        exerciseName: String,
        weight: Double,
        reps: Int,
        weightUnit: WeightUnit = .pounds,
        achievedAt: Date = Date(),
        workoutLogId: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.exerciseName = exerciseName
        self.weight = weight
        self.reps = reps
        self.weightUnit = weightUnit
        self.achievedAt = achievedAt
        self.workoutLogId = workoutLogId
    }
    
    /// Formatted display string
    var formattedRecord: String {
        "\(Int(weight)) \(weightUnit.abbreviation) × \(reps)"
    }
    
    /// One-rep max estimate using Epley formula
    var estimated1RM: Double {
        if reps == 1 {
            return weight
        }
        return weight * (1 + Double(reps) / 30)
    }
}

// MARK: - Firestore Dictionary Conversion
extension PersonalRecord {
    var firestoreData: [String: Any] {
        var data: [String: Any] = [
            "id": id,
            "userId": userId,
            "exerciseName": exerciseName,
            "weight": weight,
            "reps": reps,
            "weightUnit": weightUnit.rawValue,
            "achievedAt": achievedAt
        ]
        if let workoutLogId = workoutLogId {
            data["workoutLogId"] = workoutLogId
        }
        return data
    }
    
    init?(from data: [String: Any]) {
        guard let id = data["id"] as? String,
              let userId = data["userId"] as? String,
              let exerciseName = data["exerciseName"] as? String,
              let weight = data["weight"] as? Double,
              let reps = data["reps"] as? Int else {
            return nil
        }
        
        self.id = id
        self.userId = userId
        self.exerciseName = exerciseName
        self.weight = weight
        self.reps = reps
        self.workoutLogId = data["workoutLogId"] as? String
        
        if let unitString = data["weightUnit"] as? String,
           let unit = WeightUnit(rawValue: unitString) {
            self.weightUnit = unit
        } else {
            self.weightUnit = .pounds
        }
        
        if let timestamp = data["achievedAt"] as? Date {
            self.achievedAt = timestamp
        } else {
            self.achievedAt = Date()
        }
    }
}

/// Helper struct for tracking progress over time
struct ExerciseProgress: Identifiable {
    let id = UUID()
    let exerciseName: String
    let dataPoints: [ProgressDataPoint]
    
    var maxWeight: Double {
        dataPoints.map { $0.weight }.max() ?? 0
    }
    
    var latestWeight: Double {
        dataPoints.last?.weight ?? 0
    }
    
    var progressPercentage: Double {
        guard let first = dataPoints.first?.weight,
              let last = dataPoints.last?.weight,
              first > 0 else {
            return 0
        }
        return ((last - first) / first) * 100
    }
}

/// Single data point for progress tracking
struct ProgressDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
    let reps: Int
    let volume: Double
    
    var estimated1RM: Double {
        if reps == 1 {
            return weight
        }
        return weight * (1 + Double(reps) / 30)
    }
}
