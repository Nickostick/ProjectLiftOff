import Foundation

/// Exercise reference within a session (links to global library)
struct SessionExercise: Identifiable, Codable, Hashable {
    let id: String
    let libraryExerciseId: String
    let libraryExerciseName: String // Cached for display
    var targetSets: Int
    var targetReps: Int
    var targetWeight: Double?
    var restTime: TimeInterval?
    var notes: String
    var order: Int

    init(
        id: String = UUID().uuidString,
        libraryExerciseId: String,
        libraryExerciseName: String,
        targetSets: Int = 3,
        targetReps: Int = 10,
        targetWeight: Double? = nil,
        restTime: TimeInterval? = nil,
        notes: String = "",
        order: Int = 0
    ) {
        self.id = id
        self.libraryExerciseId = libraryExerciseId
        self.libraryExerciseName = libraryExerciseName
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.targetWeight = targetWeight
        self.restTime = restTime
        self.notes = notes
        self.order = order
    }

    // MARK: - Firestore

    var firestoreData: [String: Any] {
        var data: [String: Any] = [
            "id": id,
            "libraryExerciseId": libraryExerciseId,
            "libraryExerciseName": libraryExerciseName,
            "targetSets": targetSets,
            "targetReps": targetReps,
            "notes": notes,
            "order": order
        ]

        if let targetWeight = targetWeight {
            data["targetWeight"] = targetWeight
        }
        if let restTime = restTime {
            data["restTime"] = restTime
        }

        return data
    }

    init?(from data: [String: Any]) {
        guard let id = data["id"] as? String,
              let libraryExerciseId = data["libraryExerciseId"] as? String,
              let libraryExerciseName = data["libraryExerciseName"] as? String,
              let targetSets = data["targetSets"] as? Int,
              let targetReps = data["targetReps"] as? Int else {
            return nil
        }

        self.init(
            id: id,
            libraryExerciseId: libraryExerciseId,
            libraryExerciseName: libraryExerciseName,
            targetSets: targetSets,
            targetReps: targetReps,
            targetWeight: data["targetWeight"] as? Double,
            restTime: data["restTime"] as? TimeInterval,
            notes: data["notes"] as? String ?? "",
            order: data["order"] as? Int ?? 0
        )
    }
}
