import SwiftUI

/// Row view for a single set in an active workout
struct SetRowView: View {
    @Binding var set: SetLog
    let setNumber: Int
    let onComplete: () -> Void
    
    @State private var repsText: String = ""
    @State private var weightText: String = ""
    
    var body: some View {
        HStack(spacing: 12) {
            // Set number
            Text("\(setNumber)")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(width: 24)
            
            // Previous/Target
            VStack(alignment: .leading, spacing: 2) {
                Text("Target")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Text("\(set.targetReps) × \(Int(set.targetWeight))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 60)
            
            // Weight input
            VStack(alignment: .leading, spacing: 2) {
                Text("Weight")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                TextField("0", text: $weightText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 70)
                    .onChange(of: weightText) { _, newValue in
                        if let weight = Double(newValue) {
                            set.weight = weight
                        }
                    }
            }
            
            // Reps input
            VStack(alignment: .leading, spacing: 2) {
                Text("Reps")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                TextField("0", text: $repsText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 50)
                    .onChange(of: repsText) { _, newValue in
                        if let reps = Int(newValue) {
                            set.actualReps = reps
                        }
                    }
            }
            
            Spacer()
            
            // Complete button
            Button(action: {
                set.isCompleted.toggle()
                if set.isCompleted {
                    onComplete()
                }
            }) {
                Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(set.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(set.isCompleted ? Color.green.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .onAppear {
            weightText = set.weight > 0 ? String(format: "%.0f", set.weight) : ""
            repsText = set.actualReps > 0 ? "\(set.actualReps)" : ""
        }
    }
}

/// Compact set row for log display
struct CompactSetRowView: View {
    let set: SetLog
    
    var body: some View {
        HStack(spacing: 16) {
            Text("Set \(set.setNumber)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(set.formattedSet)
                .font(.subheadline)
            
            if set.isPR {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
            }
            
            if set.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    VStack {
        SetRowView(
            set: .constant(SetLog(
                setNumber: 1,
                targetReps: 10,
                targetWeight: 135,
                actualReps: 10,
                weight: 135,
                isCompleted: true
            )),
            setNumber: 1,
            onComplete: {}
        )
        
        SetRowView(
            set: .constant(SetLog(
                setNumber: 2,
                targetReps: 10,
                targetWeight: 135
            )),
            setNumber: 2,
            onComplete: {}
        )
        
        Divider()
        
        CompactSetRowView(set: SetLog(
            setNumber: 1,
            targetReps: 10,
            targetWeight: 135,
            actualReps: 10,
            weight: 145,
            isCompleted: true,
            isPR: true
        ))
    }
    .padding()
}
