import SwiftUI

/// Detail view for a single program showing its workout days
struct ProgramDetailView: View {
    let program: Program
    @ObservedObject var viewModel: ProgramViewModel
    
    @State private var showAddDay = false
    @State private var dayToEdit: WorkoutDay?
    @State private var showEditProgram = false
    
    var body: some View {
        List {
            // Program info section
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    if !program.description.isEmpty {
                        Text(program.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("\(program.days.count) days", systemImage: "calendar")
                        Spacer()
                        let totalExercises = program.days.reduce(0) { $0 + $1.exercises.count }
                        Label("\(totalExercises) exercises", systemImage: "dumbbell")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            
            // Days section
            Section("Workout Days") {
                if program.days.isEmpty {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                            Text("No days yet")
                                .foregroundStyle(.secondary)
                            Button("Add Day") { showAddDay = true }
                                .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical)
                        Spacer()
                    }
                } else {
                    ForEach(program.days.sorted(by: { $0.order < $1.order })) { day in
                        NavigationLink {
                            WorkoutDayView(program: program, day: day, viewModel: viewModel)
                        } label: {
                            DayRow(day: day)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                Task { await viewModel.deleteDay(from: program, day: day) }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                dayToEdit = day
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                    .onMove { source, destination in
                        Task { await viewModel.moveDays(in: program, from: source, to: destination) }
                    }
                }
            }
        }
        .navigationTitle(program.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: { showAddDay = true }) {
                        Label("Add Day", systemImage: "plus")
                    }
                    
                    Button(action: { showEditProgram = true }) {
                        Label("Edit Program", systemImage: "pencil")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showAddDay) {
            WorkoutDayFormView(viewModel: viewModel, program: program, day: nil)
        }
        .sheet(item: $dayToEdit) { day in
            WorkoutDayFormView(viewModel: viewModel, program: program, day: day)
        }
        .sheet(isPresented: $showEditProgram) {
            ProgramFormView(viewModel: viewModel, program: program)
        }
    }
}

// MARK: - Day Row

struct DayRow: View {
    let day: WorkoutDay
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(day.name)
                    .font(.headline)
                
                Spacer()
                
                Text("\(day.exercises.count) exercises")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if !day.exercises.isEmpty {
                Text(day.exercises.map { $0.name }.prefix(3).joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            if !day.notes.isEmpty {
                Label(day.notes, systemImage: "note.text")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        ProgramDetailView(
            program: Program(
                userId: "preview",
                name: "Winter Workout",
                description: "My winter bulking program",
                days: [
                    WorkoutDay(name: "Arm Day", exercises: [
                        Exercise(name: "Bicep Curl", targetSets: 3, targetReps: 10, targetWeight: 20),
                        Exercise(name: "Tricep Pushdown", targetSets: 3, targetReps: 12, targetWeight: 30)
                    ], order: 0),
                    WorkoutDay(name: "Chest Day", exercises: [], order: 1)
                ]
            ),
            viewModel: ProgramViewModel(userId: "preview")
        )
    }
}
