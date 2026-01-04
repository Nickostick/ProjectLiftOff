import SwiftUI

/// Form for creating or editing an exercise
struct ExerciseFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ProgramViewModel
    
    let program: Program
    let dayId: String
    let exercise: Exercise?
    
    @State private var name: String = ""
    @State private var targetSets: Int = 3
    @State private var targetReps: Int = 10
    @State private var targetWeight: Double = 0
    @State private var weightUnit: WeightUnit = .pounds
    @State private var restSeconds: Int = 60
    @State private var notes: String = ""
    
    @State private var showExerciseSuggestions = false
    
    var isEditing: Bool { exercise != nil }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise") {
                    HStack {
                        TextField("Exercise Name", text: $name)
                        
                        Button(action: { showExerciseSuggestions = true }) {
                            Image(systemName: "list.bullet")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                
                Section("Target") {
                    Stepper("Sets: \(targetSets)", value: $targetSets, in: 1...20)
                    
                    Stepper("Reps: \(targetReps)", value: $targetReps, in: 1...100)
                    
                    HStack {
                        Text("Weight")
                        Spacer()
                        TextField("0", value: $targetWeight, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                        
                        Picker("Unit", selection: $weightUnit) {
                            ForEach(WeightUnit.allCases, id: \.self) { unit in
                                Text(unit.abbreviation).tag(unit)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 100)
                    }
                }
                
                Section("Settings") {
                    Picker("Rest Time", selection: $restSeconds) {
                        Text("30 sec").tag(30)
                        Text("45 sec").tag(45)
                        Text("60 sec").tag(60)
                        Text("90 sec").tag(90)
                        Text("2 min").tag(120)
                        Text("3 min").tag(180)
                    }
                }
                
                Section("Notes") {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // Preview
                Section("Preview") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(name.isEmpty ? "Exercise Name" : name)
                            .font(.headline)
                        Text("\(targetSets) × \(targetReps)\(targetWeight > 0 ? " @ \(Int(targetWeight)) \(weightUnit.abbreviation)" : "")")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Exercise" : "New Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(name.trimmed.isEmpty)
                }
            }
            .onAppear {
                if let exercise = exercise {
                    name = exercise.name
                    targetSets = exercise.targetSets
                    targetReps = exercise.targetReps
                    targetWeight = exercise.targetWeight
                    weightUnit = exercise.weightUnit
                    restSeconds = exercise.restSeconds
                    notes = exercise.notes
                }
            }
            .sheet(isPresented: $showExerciseSuggestions) {
                ExerciseSuggestionsSheet(selectedName: $name)
            }
        }
    }
    
    private func save() {
        let newExercise = Exercise(
            id: exercise?.id ?? UUID().uuidString,
            name: name.trimmed,
            targetSets: targetSets,
            targetReps: targetReps,
            targetWeight: targetWeight,
            weightUnit: weightUnit,
            notes: notes.trimmed,
            order: exercise?.order ?? 0,
            restSeconds: restSeconds
        )
        
        Task {
            if exercise != nil {
                await viewModel.updateExercise(in: program, dayId: dayId, exercise: newExercise)
            } else {
                await viewModel.addExercise(to: program, dayId: dayId, exercise: newExercise)
            }
            dismiss()
        }
    }
}

// MARK: - Exercise Suggestions Sheet

struct ExerciseSuggestionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedName: String
    
    @State private var searchText = ""
    
    var filteredExercises: [String] {
        if searchText.isEmpty {
            return CommonExercises.all
        }
        return CommonExercises.all.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Chest") {
                    ForEach(CommonExercises.chest, id: \.self) { exercise in
                        exerciseButton(exercise)
                    }
                }
                
                Section("Back") {
                    ForEach(CommonExercises.back, id: \.self) { exercise in
                        exerciseButton(exercise)
                    }
                }
                
                Section("Shoulders") {
                    ForEach(CommonExercises.shoulders, id: \.self) { exercise in
                        exerciseButton(exercise)
                    }
                }
                
                Section("Arms") {
                    ForEach(CommonExercises.arms, id: \.self) { exercise in
                        exerciseButton(exercise)
                    }
                }
                
                Section("Legs") {
                    ForEach(CommonExercises.legs, id: \.self) { exercise in
                        exerciseButton(exercise)
                    }
                }
                
                Section("Core") {
                    ForEach(CommonExercises.core, id: \.self) { exercise in
                        exerciseButton(exercise)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationTitle("Common Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func exerciseButton(_ name: String) -> some View {
        Button(action: {
            selectedName = name
            dismiss()
        }) {
            HStack {
                Text(name)
                Spacer()
                if selectedName == name {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.blue)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ExerciseFormView(
        viewModel: ProgramViewModel(userId: "preview"),
        program: Program(userId: "preview", name: "Test"),
        dayId: "day1",
        exercise: nil
    )
}
