import Foundation

/// Represents a single workout day within a program
/// Example: "Arm Day", "Chest Day", "Leg Day"
struct WorkoutDay: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var exercises: [Exercise]
    var order: Int
    var notes: String
    
    init(
        id: String = UUID().uuidString,
        name: String,
        exercises: [Exercise] = [],
        order: Int = 0,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.exercises = exercises
        self.order = order
        self.notes = notes
    }
    
    /// Total number of sets in this day
    var totalSets: Int {
        exercises.reduce(0) { $0 + $1.targetSets }
    }
    
    /// Total number of exercises
    var exerciseCount: Int {
        exercises.count
    }
}

// MARK: - Firestore Dictionary Conversion
extension WorkoutDay {
    var firestoreData: [String: Any] {
        [
            "id": id,
            "name": name,
            "exercises": exercises.map { $0.firestoreData },
            "order": order,
            "notes": notes
        ]
    }
    
    init?(from data: [String: Any]) {
        guard let id = data["id"] as? String,
              let name = data["name"] as? String else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.order = data["order"] as? Int ?? 0
        self.notes = data["notes"] as? String ?? ""
        
        if let exercisesData = data["exercises"] as? [[String: Any]] {
            self.exercises = exercisesData.compactMap { Exercise(from: $0) }
        } else {
            self.exercises = []
        }
    }
}
