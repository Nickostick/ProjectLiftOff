import SwiftUI

/// Detail view for a completed workout log
struct LogDetailView: View {
    let log: WorkoutLog
    
    var body: some View {
        List {
            // Summary Section
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(log.dayName)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            if !log.programName.isEmpty {
                                Text(log.programName)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if let rating = log.rating {
                            HStack(spacing: 2) {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= rating ? "star.fill" : "star")
                                        .foregroundStyle(.yellow)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Stats
                    HStack(spacing: 20) {
                        StatItem(
                            icon: "calendar",
                            title: "Date",
                            value: log.startedAt.formattedMedium
                        )
                        
                        StatItem(
                            icon: "clock",
                            title: "Duration",
                            value: log.formattedDuration
                        )
                        
                        StatItem(
                            icon: "scalemass",
                            title: "Volume",
                            value: log.totalVolume.formattedVolume + " lbs"
                        )
                    }
                }
            }
            
            // Exercises Section
            Section("Exercises") {
                ForEach(log.exercises) { exercise in
                    ExerciseLogRow(exercise: exercise)
                }
            }
            
            // Notes Section
            if !log.notes.isEmpty {
                Section("Notes") {
                    Text(log.notes)
                        .font(.body)
                }
            }
        }
        .navigationTitle("Workout Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Stat Item

private struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Exercise Log Row

struct ExerciseLogRow: View {
    let exercise: ExerciseLog
    
    @State private var isExpanded = false
    
    var hasPR: Bool {
        exercise.completedSets.contains { $0.isPR }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(exercise.name)
                                .font(.headline)
                            
                            if hasPR {
                                Image(systemName: "trophy.fill")
                                    .font(.caption)
                                    .foregroundStyle(.yellow)
                            }
                        }
                        
                        let completedSets = exercise.completedSets.filter { $0.isCompleted }
                        if let bestSet = exercise.bestSet {
                            Text("Best: \(bestSet.formattedSet) • \(completedSets.count) sets")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Text(exercise.totalVolume.formattedVolume + " lbs")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(spacing: 4) {
                    ForEach(exercise.completedSets.filter { $0.isCompleted }) { set in
                        HStack {
                            Text("Set \(set.setNumber)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 50, alignment: .leading)
                            
                            Text(set.formattedSet)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            if set.isPR {
                                Text("PR")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.yellow)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.yellow.opacity(0.2))
                                    .cornerRadius(4)
                            }
                            
                            if let rpe = set.rpe {
                                Text("RPE \(rpe)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
                .padding(.leading)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        LogDetailView(log: WorkoutLog(
            userId: "preview",
            programName: "Winter Workout",
            dayName: "Arm Day",
            exercises: [
                ExerciseLog(
                    name: "Bicep Curl",
                    completedSets: [
                        SetLog(setNumber: 1, actualReps: 10, weight: 25, isCompleted: true),
                        SetLog(setNumber: 2, actualReps: 10, weight: 25, isCompleted: true),
                        SetLog(setNumber: 3, actualReps: 8, weight: 25, isCompleted: true, isPR: true)
                    ]
                )
            ],
            duration: 3600
        ))
    }
}
