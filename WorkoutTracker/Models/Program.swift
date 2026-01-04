import Foundation

/// Represents a workout program template (highest level container)
/// Example: "Winter Workout", "Strength Building", "Cut Phase"
struct Program: Identifiable, Codable, Hashable {
    var id: String
    var userId: String
    var name: String
    var description: String
    var days: [WorkoutDay]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        userId: String,
        name: String,
        description: String = "",
        days: [WorkoutDay] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.description = description
        self.days = days
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Creates a copy of the program with a new ID
    func copy(withNewId newId: String = UUID().uuidString, forUser userId: String) -> Program {
        var copied = self
        copied.id = newId
        copied.userId = userId
        copied.createdAt = Date()
        copied.updatedAt = Date()
        // Also regenerate IDs for all nested items
        copied.days = days.map { day in
            var newDay = day
            newDay.id = UUID().uuidString
            newDay.exercises = day.exercises.map { exercise in
                var newExercise = exercise
                newExercise.id = UUID().uuidString
                return newExercise
            }
            return newDay
        }
        return copied
    }

    /// Generates a shareable URL for this program
    var shareURL: URL? {
        // In production, this would be a deep link or Firebase Dynamic Link
        URL(string: "workouttracker://program/\(id)")
    }
}

// MARK: - Firestore Dictionary Conversion
extension Program {
    /// Convert to Firestore-compatible dictionary
    var firestoreData: [String: Any] {
        [
            "id": id,
            "userId": userId,
            "name": name,
            "description": description,
            "days": days.map { $0.firestoreData },
            "createdAt": createdAt,
            "updatedAt": updatedAt
        ]
    }

    /// Initialize from Firestore document data
    init?(from data: [String: Any]) {
        guard let id = data["id"] as? String,
              let userId = data["userId"] as? String,
              let name = data["name"] as? String else {
            return nil
        }

        self.id = id
        self.userId = userId
        self.name = name
        self.description = data["description"] as? String ?? ""

        // Parse days array
        if let daysData = data["days"] as? [[String: Any]] {
            self.days = daysData.compactMap { WorkoutDay(from: $0) }
        } else {
            self.days = []
        }

        // Parse dates
        if let timestamp = data["createdAt"] as? Date {
            self.createdAt = timestamp
        } else {
            self.createdAt = Date()
        }

        if let timestamp = data["updatedAt"] as? Date {
            self.updatedAt = timestamp
        } else {
            self.updatedAt = Date()
        }
    }
}
