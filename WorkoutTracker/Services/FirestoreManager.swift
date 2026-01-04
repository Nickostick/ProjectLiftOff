import Foundation
import FirebaseFirestore
import Combine

/// Manages all Firestore database operations
final class FirestoreManager {
    
    // MARK: - Properties
    private let db = Firestore.firestore()
    
    // MARK: - Program Operations
    
    /// Fetch all programs for a user
    func fetchPrograms(userId: String) -> AnyPublisher<[Program], Error> {
        let subject = PassthroughSubject<[Program], Error>()
        
        print("🔍 Fetching programs for userId: \(userId)")
        
        db.collection(Constants.Collections.programs)
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Firestore error fetching programs: \(error.localizedDescription)")
                    // Keep listener alive
                    subject.send([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("📭 No documents snapshot received")
                    subject.send([])
                    return
                }
                
                print("📦 Received \(documents.count) program documents from Firestore")
                
                let programs = documents.compactMap { doc -> Program? in
                    var data = doc.data()
                    // Convert Firestore Timestamps to Date
                    if let timestamp = data["createdAt"] as? Timestamp {
                        data["createdAt"] = timestamp.dateValue()
                    }
                    if let timestamp = data["updatedAt"] as? Timestamp {
                        data["updatedAt"] = timestamp.dateValue()
                    }
                    return Program(from: data)
                }.sorted { $0.updatedAt > $1.updatedAt } // Sort client-side
                
                print("✅ Parsed \(programs.count) programs successfully")
                subject.send(programs)
            }
        
        return subject.eraseToAnyPublisher()
    }
    
    /// Fetch a single program by ID
    func fetchProgram(id: String) async throws -> Program? {
        let document = try await db.collection(Constants.Collections.programs).document(id).getDocument()
        
        guard document.exists, var data = document.data() else {
            return nil
        }
        
        // Convert timestamps
        if let timestamp = data["createdAt"] as? Timestamp {
            data["createdAt"] = timestamp.dateValue()
        }
        if let timestamp = data["updatedAt"] as? Timestamp {
            data["updatedAt"] = timestamp.dateValue()
        }
        
        return Program(from: data)
    }
    
    /// Create or update a program
    func saveProgram(_ program: Program) async throws {
        var updatedProgram = program
        updatedProgram.updatedAt = Date()
        
        try await db.collection(Constants.Collections.programs)
            .document(program.id)
            .setData(updatedProgram.firestoreData)
        
        print("✅ Program saved: \(program.name)")
    }
    
    /// Delete a program
    func deleteProgram(id: String) async throws {
        try await db.collection(Constants.Collections.programs)
            .document(id)
            .delete()
        
        print("✅ Program deleted: \(id)")
    }
    
    // MARK: - Workout Log Operations
    
    /// Fetch all workout logs for a user
    func fetchWorkoutLogs(userId: String) -> AnyPublisher<[WorkoutLog], Error> {
        let subject = PassthroughSubject<[WorkoutLog], Error>()
        
        db.collection(Constants.Collections.workoutLogs)
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Firestore error fetching workout logs: \(error.localizedDescription)")
                    subject.send([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    subject.send([])
                    return
                }
                
                let logs = documents.compactMap { doc -> WorkoutLog? in
                    var data = doc.data()
                    // Convert timestamps
                    if let timestamp = data["startedAt"] as? Timestamp {
                        data["startedAt"] = timestamp.dateValue()
                    }
                    if let timestamp = data["completedAt"] as? Timestamp {
                        data["completedAt"] = timestamp.dateValue()
                    }
                    return WorkoutLog(from: data)
                }.sorted { $0.startedAt > $1.startedAt } // Sort client-side
                
                subject.send(logs)
            }
        
        return subject.eraseToAnyPublisher()
    }
    
    /// Fetch workout logs within a date range
    func fetchWorkoutLogs(userId: String, from startDate: Date, to endDate: Date) async throws -> [WorkoutLog] {
        let snapshot = try await db.collection(Constants.Collections.workoutLogs)
            .whereField("userId", isEqualTo: userId)
            .whereField("startedAt", isGreaterThanOrEqualTo: startDate)
            .whereField("startedAt", isLessThanOrEqualTo: endDate)
            .order(by: "startedAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc -> WorkoutLog? in
            var data = doc.data()
            if let timestamp = data["startedAt"] as? Timestamp {
                data["startedAt"] = timestamp.dateValue()
            }
            if let timestamp = data["completedAt"] as? Timestamp {
                data["completedAt"] = timestamp.dateValue()
            }
            return WorkoutLog(from: data)
        }
    }
    
    /// Save a workout log
    func saveWorkoutLog(_ log: WorkoutLog) async throws {
        try await db.collection(Constants.Collections.workoutLogs)
            .document(log.id)
            .setData(log.firestoreData)
        
        print("✅ Workout log saved: \(log.dayName)")
    }
    
    /// Delete a workout log
    func deleteWorkoutLog(id: String) async throws {
        try await db.collection(Constants.Collections.workoutLogs)
            .document(id)
            .delete()
        
        print("✅ Workout log deleted: \(id)")
    }
    
    // MARK: - Personal Records Operations
    
    /// Fetch all personal records for a user
    func fetchPersonalRecords(userId: String) -> AnyPublisher<[PersonalRecord], Error> {
        let subject = PassthroughSubject<[PersonalRecord], Error>()
        
        db.collection(Constants.Collections.personalRecords)
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Firestore error fetching personal records: \(error.localizedDescription)")
                    subject.send([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    subject.send([])
                    return
                }
                
                let records = documents.compactMap { doc -> PersonalRecord? in
                    var data = doc.data()
                    if let timestamp = data["achievedAt"] as? Timestamp {
                        data["achievedAt"] = timestamp.dateValue()
                    }
                    return PersonalRecord(from: data)
                }.sorted { $0.achievedAt > $1.achievedAt } // Sort client-side
                
                subject.send(records)
            }
        
        return subject.eraseToAnyPublisher()
    }
    
    /// Get personal record for a specific exercise
    func getPersonalRecord(userId: String, exerciseName: String) async throws -> PersonalRecord? {
        // Fetch all records for this exercise and sort in memory to find PR
        // This avoids needing a composite index for (userId + exerciseName + weight)
        let snapshot = try await db.collection(Constants.Collections.personalRecords)
            .whereField("userId", isEqualTo: userId)
            .whereField("exerciseName", isEqualTo: exerciseName)
            .getDocuments()
        
        let records = snapshot.documents.compactMap { doc -> PersonalRecord? in
            var data = doc.data()
            if let timestamp = data["achievedAt"] as? Timestamp {
                data["achievedAt"] = timestamp.dateValue()
            }
            return PersonalRecord(from: data)
        }
        
        // Sort by weight descending, then reps descending
        return records.sorted { 
            if $0.weight == $1.weight {
                return $0.reps > $1.reps
            }
            return $0.weight > $1.weight
        }.first
    }
    
    /// Save a personal record
    func savePersonalRecord(_ record: PersonalRecord) async throws {
        try await db.collection(Constants.Collections.personalRecords)
            .document(record.id)
            .setData(record.firestoreData)
        
        print("✅ Personal record saved: \(record.exerciseName) - \(record.formattedRecord)")
    }
    
    /// Check and update PR if new weight is higher
    func checkAndUpdatePR(userId: String, exerciseName: String, weight: Double, reps: Int, workoutLogId: String?) async throws -> Bool {
        let existingPR = try await getPersonalRecord(userId: userId, exerciseName: exerciseName)
        
        // Check if this is a new PR (higher weight or same weight with more reps)
        let isNewPR: Bool
        if let existing = existingPR {
            isNewPR = weight > existing.weight || (weight == existing.weight && reps > existing.reps)
        } else {
            isNewPR = true
        }
        
        if isNewPR {
            let newPR = PersonalRecord(
                userId: userId,
                exerciseName: exerciseName,
                weight: weight,
                reps: reps,
                workoutLogId: workoutLogId
            )
            try await savePersonalRecord(newPR)
        }
        
        return isNewPR
    }
    
    /// Get the last performance for a specific exercise
    /// Returns an array of strings representing each set (e.g. ["10x135", "10x135", "8x145"])
    func getLastPerformance(userId: String, exerciseName: String) async throws -> [String]? {
        // Fetch recent logs containing this exercise
        let snapshot = try await db.collection(Constants.Collections.workoutLogs)
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
            
        // Filter and sort client-side to find the most recent log with this exercise
        let lastLog = snapshot.documents.compactMap { doc -> WorkoutLog? in
            var data = doc.data()
            if let timestamp = data["startedAt"] as? Timestamp {
                data["startedAt"] = timestamp.dateValue()
            }
            return WorkoutLog(from: data)
        }
        .filter { log in
            log.exercises.contains { $0.name == exerciseName }
        }
        .sorted { $0.startedAt > $1.startedAt }
        .first
        
        guard let log = lastLog,
              let exerciseLog = log.exercises.first(where: { $0.name == exerciseName }) else {
            return nil
        }
        
        // Convert completed sets to formatted strings
        return exerciseLog.completedSets.filter { $0.isCompleted }.map { set in
            "\(set.actualReps)×\(Int(set.weight))"
        }
    }
    
    // MARK: - Statistics and Reporting
    
    /// Get total volume for a date range
    func getTotalVolume(userId: String, from startDate: Date, to endDate: Date) async throws -> Double {
        let logs = try await fetchWorkoutLogs(userId: userId, from: startDate, to: endDate)
        return logs.reduce(0) { $0 + $1.totalVolume }
    }
    
    /// Get workout count for a date range
    func getWorkoutCount(userId: String, from startDate: Date, to endDate: Date) async throws -> Int {
        let logs = try await fetchWorkoutLogs(userId: userId, from: startDate, to: endDate)
        return logs.count
    }
    
    /// Get exercise progress data points
    func getExerciseProgress(userId: String, exerciseName: String, limit: Int = 30) async throws -> [ProgressDataPoint] {
        // Fetch all logs and sort in memory
        // This avoids needing a composite index for (userId + startedAt)
        let snapshot = try await db.collection(Constants.Collections.workoutLogs)
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
            
        var logs = snapshot.documents.compactMap { doc -> WorkoutLog? in
            var data = doc.data()
            if let timestamp = data["startedAt"] as? Timestamp {
                data["startedAt"] = timestamp.dateValue()
            }
            return WorkoutLog(from: data)
        }
        
        // Sort by date ascending
        logs.sort { $0.startedAt < $1.startedAt }
        
        // Take the last (limit*10) to process, or all if fewer
        if logs.count > limit * 10 {
            logs = Array(logs.suffix(limit * 10))
        }
        
        var dataPoints: [ProgressDataPoint] = []
        
        for log in logs {
            
            // Find the exercise in this log
            for exerciseLog in log.exercises where exerciseLog.name == exerciseName {
                if let bestSet = exerciseLog.bestSet, bestSet.weight > 0 {
                    dataPoints.append(ProgressDataPoint(
                        date: log.startedAt,
                        weight: bestSet.weight,
                        reps: bestSet.actualReps,
                        volume: exerciseLog.totalVolume
                    ))
                }
            }
        }
        
        return Array(dataPoints.suffix(limit))
    }
}
