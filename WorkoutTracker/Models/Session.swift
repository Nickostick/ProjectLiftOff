import Foundation

/// Training session within a program (formerly "Day")
struct Session: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var description: String
    var exercises: [SessionExercise]
    var order: Int
    var recommendedFrequencyPerWeek: Int?

    init(
        id: String = UUID().uuidString,
        name: String,
        description: String = "",
        exercises: [SessionExercise] = [],
        order: Int = 0,
        recommendedFrequencyPerWeek: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.exercises = exercises
        self.order = order
        self.recommendedFrequencyPerWeek = recommendedFrequencyPerWeek
    }

    var frequencyText: String? {
        guard let freq = recommendedFrequencyPerWeek else { return nil }
        return "Recommended \(freq)×/week"
    }

    // MARK: - Firestore

    var firestoreData: [String: Any] {
        var data: [String: Any] = [
            "id": id,
            "name": name,
            "description": description,
            "exercises": exercises.map { $0.firestoreData },
            "order": order
        ]

        if let freq = recommendedFrequencyPerWeek {
            data["recommendedFrequencyPerWeek"] = freq
        }

        return data
    }

    init?(from data: [String: Any]) {
        guard let id = data["id"] as? String,
              let name = data["name"] as? String else {
            return nil
        }

        let description = data["description"] as? String ?? ""
        let order = data["order"] as? Int ?? 0
        let recommendedFrequencyPerWeek = data["recommendedFrequencyPerWeek"] as? Int

        let exercisesData = data["exercises"] as? [[String: Any]] ?? []
        let exercises = exercisesData.compactMap { SessionExercise(from: $0) }

        self.init(
            id: id,
            name: name,
            description: description,
            exercises: exercises,
            order: order,
            recommendedFrequencyPerWeek: recommendedFrequencyPerWeek
        )
    }
}
