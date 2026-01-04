import SwiftUI

/// Form for creating or editing a workout day
struct WorkoutDayFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ProgramViewModel
    
    let program: Program
    let day: WorkoutDay?
    
    @State private var name: String = ""
    @State private var notes: String = ""
    
    var isEditing: Bool { day != nil }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Day Details") {
                    TextField("Day Name (e.g., Arm Day)", text: $name)
                    
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Text("Common day names: Push Day, Pull Day, Leg Day, Arm Day, Chest Day, Back Day, etc.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(isEditing ? "Edit Day" : "New Day")
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
                if let day = day {
                    name = day.name
                    notes = day.notes
                }
            }
        }
    }
    
    private func save() {
        Task {
            if var existingDay = day {
                existingDay.name = name.trimmed
                existingDay.notes = notes.trimmed
                await viewModel.updateDay(in: program, day: existingDay)
            } else {
                await viewModel.addDay(to: program, name: name.trimmed, notes: notes.trimmed)
            }
            dismiss()
        }
    }
}

#Preview {
    WorkoutDayFormView(
        viewModel: ProgramViewModel(userId: "preview"),
        program: Program(userId: "preview", name: "Test"),
        day: nil
    )
}
