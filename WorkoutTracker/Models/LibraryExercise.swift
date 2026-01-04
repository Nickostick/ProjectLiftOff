import Foundation
import FirebaseFirestore

/// Global exercise definition in the library
struct LibraryExercise: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let muscleGroup: MuscleGroup
    let isCustom: Bool
    let createdAt: Date

    enum MuscleGroup: String, Codable, CaseIterable {
        case chest = "Chest"
        case back = "Back"
        case legs = "Legs"
        case shoulders = "Shoulders"
        case arms = "Arms"
        case core = "Core"
        case cardio = "Cardio"
        case other = "Other"
    }

    init(id: String = UUID().uuidString, name: String, muscleGroup: MuscleGroup, isCustom: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.muscleGroup = muscleGroup
        self.isCustom = isCustom
        self.createdAt = createdAt
    }

    // MARK: - Firestore

    var firestoreData: [String: Any] {
        return [
            "id": id,
            "name": name,
            "muscleGroup": muscleGroup.rawValue,
            "isCustom": isCustom,
            "createdAt": Timestamp(date: createdAt)
        ]
    }

    init?(from data: [String: Any]) {
        guard let id = data["id"] as? String,
              let name = data["name"] as? String,
              let muscleGroupRaw = data["muscleGroup"] as? String,
              let muscleGroup = MuscleGroup(rawValue: muscleGroupRaw),
              let isCustom = data["isCustom"] as? Bool else {
            return nil
        }

        let createdAt = (data["createdAt"] as? Date) ?? Date()

        self.init(id: id, name: name, muscleGroup: muscleGroup, isCustom: isCustom, createdAt: createdAt)
    }
}
