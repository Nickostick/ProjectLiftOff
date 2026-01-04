import SwiftUI

/// Row view for displaying an exercise in a list
struct ExerciseRowView: View {
    let exercise: Exercise
    var showDetails: Bool = true
    
    var body: some View {
        HStack(spacing: 12) {
            // Exercise icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "dumbbell.fill")
                    .font(.body)
                    .foregroundStyle(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                if showDetails {
                    Text(exercise.formattedTarget)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if showDetails && !exercise.notes.isEmpty {
                Image(systemName: "note.text")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

/// Compact exercise row for active workout
struct CompactExerciseRowView: View {
    let exerciseLog: ExerciseLog
    var isPR: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(exerciseLog.name)
                        .font(.headline)
                    
                    if isPR {
                        Text("PR")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.yellow.gradient)
                            .cornerRadius(4)
                    }
                }
                
                let completedCount = exerciseLog.completedSets.filter { $0.isCompleted }.count
                Text("\(completedCount)/\(exerciseLog.completedSets.count) sets completed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if let bestSet = exerciseLog.bestSet, bestSet.isCompleted {
                Text(bestSet.formattedSet)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        ExerciseRowView(
            exercise: Exercise(
                name: "Bench Press",
                targetSets: 4,
                targetReps: 8,
                targetWeight: 185,
                notes: "Focus on form"
            )
        )
        
        ExerciseRowView(
            exercise: Exercise(
                name: "Bicep Curl",
                targetSets: 3,
                targetReps: 12,
                targetWeight: 30
            )
        )
    }
}
