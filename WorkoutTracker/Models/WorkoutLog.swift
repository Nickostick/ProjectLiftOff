import Foundation

/// Represents a completed workout session (log entry)
/// This is separate from templates - logs contain actual performed data
struct WorkoutLog: Identifiable, Codable, Hashable {
    var id: String
    var userId: String
    var programId: String?
    var programName: String
    var dayId: String?
    var dayName: String
    var exercises: [ExerciseLog]
    var startedAt: Date
    var completedAt: Date?
    var duration: TimeInterval
    var notes: String
    var rating: Int? // 1-5 workout rating
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        programId: String? = nil,
        programName: String = "",
        dayId: String? = nil,
        dayName: String,
        exercises: [ExerciseLog] = [],
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        duration: TimeInterval = 0,
        notes: String = "",
        rating: Int? = nil
    ) {
        self.id = id
        self.userId = userId
        self.programId = programId
        self.programName = programName
        self.dayId = dayId
        self.dayName = dayName
        self.exercises = exercises
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.duration = duration
        self.notes = notes
        self.rating = rating
    }
    
    /// Total volume lifted in this workout (sum of all set volumes)
    var totalVolume: Double {
        exercises.reduce(0) { $0 + $1.totalVolume }
    }
    
    /// Total number of sets completed
    var totalSetsCompleted: Int {
        exercises.reduce(0) { $0 + $1.completedSets.count }
    }
    
    /// Formatted duration string
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
    
    /// Create a log from a workout day template
    static func from(day: WorkoutDay, program: Program?, userId: String) -> WorkoutLog {
        WorkoutLog(
            userId: userId,
            programId: program?.id,
            programName: program?.name ?? "",
            dayId: day.id,
            dayName: day.name,
            exercises: day.exercises.map { ExerciseLog.from(exercise: $0) }
        )
    }
}

/// Represents logged data for a single exercise in a workout
struct ExerciseLog: Identifiable, Codable, Hashable {
    var id: String
    var exerciseId: String?
    var name: String
    var completedSets: [SetLog]
    var notes: String
    var order: Int
    
    init(
        id: String = UUID().uuidString,
        exerciseId: String? = nil,
        name: String,
        completedSets: [SetLog] = [],
        notes: String = "",
        order: Int = 0
    ) {
        self.id = id
        self.exerciseId = exerciseId
        self.name = name
        self.completedSets = completedSets
        self.notes = notes
        self.order = order
    }
    
    /// Total volume for this exercise
    var totalVolume: Double {
        completedSets.reduce(0) { $0 + $1.volume }
    }
    
    /// Best set by weight
    var bestSet: SetLog? {
        completedSets.max(by: { $0.weight < $1.weight })
    }
    
    /// Create from exercise template
    static func from(exercise: Exercise) -> ExerciseLog {
        let sets = (0..<exercise.targetSets).map { index in
            SetLog(
                setNumber: index + 1,
                targetReps: exercise.targetReps,
                targetWeight: exercise.targetWeight,
                weightUnit: exercise.weightUnit
            )
        }
        return ExerciseLog(
            exerciseId: exercise.id,
            name: exercise.name,
            completedSets: sets,
            order: exercise.order
        )
    }
}

/// Represents a single set within an exercise log
struct SetLog: Identifiable, Codable, Hashable {
    var id: String
    var setNumber: Int
    var targetReps: Int
    var targetWeight: Double
    var actualReps: Int
    var weight: Double
    var weightUnit: WeightUnit
    var isCompleted: Bool
    var isPR: Bool
    var rpe: Int? // Rate of Perceived Exertion (1-10)
    var previousPerformance: String? // e.g. "10x150" from last session
    
    init(
        id: String = UUID().uuidString,
        setNumber: Int,
        targetReps: Int = 10,
        targetWeight: Double = 0,
        actualReps: Int = 0,
        weight: Double = 0,
        weightUnit: WeightUnit = .pounds,
        isCompleted: Bool = false,
        isPR: Bool = false,
        rpe: Int? = nil,
        previousPerformance: String? = nil
    ) {
        self.id = id
        self.setNumber = setNumber
        self.targetReps = targetReps
        self.targetWeight = targetWeight
        self.actualReps = actualReps
        self.weight = weight > 0 ? weight : targetWeight
        self.weightUnit = weightUnit
        self.isCompleted = isCompleted
        self.isPR = isPR
        self.rpe = rpe
        self.previousPerformance = previousPerformance
    }
    
    /// Volume for this set (reps * weight)
    var volume: Double {
        Double(actualReps) * weight
    }
    
    /// Formatted display string
    var formattedSet: String {
        if weight > 0 {
            return "\(actualReps) × \(Int(weight)) \(weightUnit.abbreviation)"
        }
        return "\(actualReps) reps"
    }
}

// MARK: - Firestore Dictionary Conversion
extension WorkoutLog {
    var firestoreData: [String: Any] {
        var data: [String: Any] = [
            "id": id,
            "userId": userId,
            "programName": programName,
            "dayName": dayName,
            "exercises": exercises.map { $0.firestoreData },
            "startedAt": startedAt,
            "duration": duration,
            "notes": notes
        ]
        
        if let programId = programId {
            data["programId"] = programId
        }
        if let dayId = dayId {
            data["dayId"] = dayId
        }
        if let completedAt = completedAt {
            data["completedAt"] = completedAt
        }
        if let rating = rating {
            data["rating"] = rating
        }
        
        return data
    }
    
    init?(from data: [String: Any]) {
        guard let id = data["id"] as? String,
              let userId = data["userId"] as? String,
              let dayName = data["dayName"] as? String else {
            return nil
        }
        
        self.id = id
        self.userId = userId
        self.programId = data["programId"] as? String
        self.programName = data["programName"] as? String ?? ""
        self.dayId = data["dayId"] as? String
        self.dayName = dayName
        self.notes = data["notes"] as? String ?? ""
        self.duration = data["duration"] as? TimeInterval ?? 0
        self.rating = data["rating"] as? Int
        
        if let timestamp = data["startedAt"] as? Date {
            self.startedAt = timestamp
        } else {
            self.startedAt = Date()
        }
        
        self.completedAt = data["completedAt"] as? Date
        
        if let exercisesData = data["exercises"] as? [[String: Any]] {
            self.exercises = exercisesData.compactMap { ExerciseLog(from: $0) }
        } else {
            self.exercises = []
        }
    }
}

extension ExerciseLog {
    var firestoreData: [String: Any] {
        var data: [String: Any] = [
            "id": id,
            "name": name,
            "completedSets": completedSets.map { $0.firestoreData },
            "notes": notes,
            "order": order
        ]
        if let exerciseId = exerciseId {
            data["exerciseId"] = exerciseId
        }
        return data
    }
    
    init?(from data: [String: Any]) {
        guard let id = data["id"] as? String,
              let name = data["name"] as? String else {
            return nil
        }
        
        self.id = id
        self.exerciseId = data["exerciseId"] as? String
        self.name = name
        self.notes = data["notes"] as? String ?? ""
        self.order = data["order"] as? Int ?? 0
        
        if let setsData = data["completedSets"] as? [[String: Any]] {
            self.completedSets = setsData.compactMap { SetLog(from: $0) }
        } else {
            self.completedSets = []
        }
    }
}

extension SetLog {
    var firestoreData: [String: Any] {
        var data: [String: Any] = [
            "id": id,
            "setNumber": setNumber,
            "targetReps": targetReps,
            "targetWeight": targetWeight,
            "actualReps": actualReps,
            "weight": weight,
            "weightUnit": weightUnit.rawValue,
            "isCompleted": isCompleted,
            "isPR": isPR
        ]
        if let rpe = rpe {
            data["rpe"] = rpe
        }
        if let previousPerformance = previousPerformance {
            data["previousPerformance"] = previousPerformance
        }
        return data
    }
    
    init?(from data: [String: Any]) {
        guard let id = data["id"] as? String,
              let setNumber = data["setNumber"] as? Int else {
            return nil
        }
        
        self.id = id
        self.setNumber = setNumber
        self.targetReps = data["targetReps"] as? Int ?? 10
        self.targetWeight = data["targetWeight"] as? Double ?? 0
        self.actualReps = data["actualReps"] as? Int ?? 0
        self.weight = data["weight"] as? Double ?? 0
        self.isCompleted = data["isCompleted"] as? Bool ?? false
        self.isPR = data["isPR"] as? Bool ?? false
        self.rpe = data["rpe"] as? Int
        self.previousPerformance = data["previousPerformance"] as? String
        
        if let unitString = data["weightUnit"] as? String,
           let unit = WeightUnit(rawValue: unitString) {
            self.weightUnit = unit
        } else {
            self.weightUnit = .pounds
        }
    }
}
