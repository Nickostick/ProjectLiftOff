import SwiftUI

/// Detail view for a workout day showing its exercises
struct WorkoutDayView: View {
    let program: Program
    let day: WorkoutDay
    @ObservedObject var viewModel: ProgramViewModel
    
    @State private var showAddExercise = false
    @State private var exerciseToEdit: Exercise?
    
    // Get current day from program to ensure we have latest data
    private var currentDay: WorkoutDay {
        program.days.first { $0.id == day.id } ?? day
    }
    
    var body: some View {
        List {
            // Day info
            if !currentDay.notes.isEmpty {
                Section {
                    Text(currentDay.notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Exercises
            Section("Exercises") {
                if currentDay.exercises.isEmpty {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "dumbbell.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                            Text("No exercises yet")
                                .foregroundStyle(.secondary)
                            Button("Add Exercise") { showAddExercise = true }
                                .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical)
                        Spacer()
                    }
                } else {
                    ForEach(currentDay.exercises.sorted(by: { $0.order < $1.order })) { exercise in
                        ExerciseRowView(exercise: exercise)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                exerciseToEdit = exercise
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    Task {
                                        await viewModel.deleteExercise(from: program, dayId: day.id, exercise: exercise)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {
                                    exerciseToEdit = exercise
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                    }
                    .onMove { source, destination in
                        Task {
                            await viewModel.moveExercises(in: program, dayId: day.id, from: source, to: destination)
                        }
                    }
                }
            }
            
            // Summary
            if !currentDay.exercises.isEmpty {
                Section("Summary") {
                    HStack {
                        Text("Total Sets")
                        Spacer()
                        Text("\(currentDay.totalSets)")
                            .foregroundStyle(.secondary)
                    }
                    
                    let totalVolume = currentDay.exercises.reduce(0.0) { $0 + $1.estimatedVolume }
                    HStack {
                        Text("Estimated Volume")
                        Spacer()
                        Text(totalVolume.formattedVolume + " lbs")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(currentDay.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showAddExercise = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddExercise) {
            ExerciseFormView(viewModel: viewModel, program: program, dayId: day.id, exercise: nil)
        }
        .sheet(item: $exerciseToEdit) { exercise in
            ExerciseFormView(viewModel: viewModel, program: program, dayId: day.id, exercise: exercise)
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutDayView(
            program: Program(
                userId: "preview",
                name: "Test Program",
                days: [
                    WorkoutDay(
                        name: "Arm Day",
                        exercises: [
                            Exercise(name: "Bicep Curl", targetSets: 3, targetReps: 10, targetWeight: 20),
                            Exercise(name: "Tricep Pushdown", targetSets: 3, targetReps: 12, targetWeight: 30),
                            Exercise(name: "Hammer Curl", targetSets: 3, targetReps: 10, targetWeight: 25)
                        ],
                        order: 0
                    )
                ]
            ),
            day: WorkoutDay(name: "Arm Day", order: 0),
            viewModel: ProgramViewModel(userId: "preview")
        )
    }
}
