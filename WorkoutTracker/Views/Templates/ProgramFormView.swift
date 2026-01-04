import SwiftUI

/// Form for creating or editing a program
struct ProgramFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ProgramViewModel
    
    let program: Program?
    
    @State private var name: String = ""
    @State private var description: String = ""
    
    var isEditing: Bool { program != nil }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Program Details") {
                    TextField("Program Name", text: $name)
                    
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                if !isEditing {
                    Section {
                        Text("You can add workout days after creating the program.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Program" : "New Program")
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
                if let program = program {
                    name = program.name
                    description = program.description
                }
            }
        }
    }
    
    private func save() {
        Task {
            if var existingProgram = program {
                existingProgram.name = name.trimmed
                existingProgram.description = description.trimmed
                await viewModel.saveProgram(existingProgram)
            } else {
                await viewModel.createProgram(name: name.trimmed, description: description.trimmed)
            }
            dismiss()
        }
    }
}

#Preview {
    ProgramFormView(viewModel: ProgramViewModel(userId: "preview"), program: nil)
}
