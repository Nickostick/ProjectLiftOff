import SwiftUI

/// Premium 2026 ProgramListView - Bold gradient cards with energetic design
struct ProgramListView_Premium: View {
    @ObservedObject var viewModel: ProgramViewModel

    @State private var showAddProgram = false
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var programToEdit: Program?
    @State private var programToDelete: Program?
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background with subtle orbs
                backgroundLayer

                Group {
                    if viewModel.programs.isEmpty && !viewModel.isLoading {
                        emptyStateView
                    } else {
                        programsScrollView
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddProgram = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(AppTheme.primaryGradient)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search programs")
            .sheet(isPresented: $showAddProgram) {
                ProgramFormView(viewModel: viewModel, program: nil)
            }
            .sheet(item: $programToEdit) { program in
                ProgramFormView(viewModel: viewModel, program: program)
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: shareItems)
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(AppTheme.vibrantPurple)
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .alert("Delete Program?", isPresented: $showDeleteConfirmation, presenting: programToDelete) { program in
                Button("Cancel", role: .cancel) {
                    programToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    Task {
                        await viewModel.deleteProgram(program)
                        programToDelete = nil
                    }
                }
            } message: { program in
                Text("This will permanently delete \"\(program.name)\" and all \(program.days.count) days inside it. This action cannot be undone.")
            }
        }
    }

    // MARK: - Background Layer

    private var backgroundLayer: some View {
        AppTheme.darkBackground.ignoresSafeArea()
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon
            Image(systemName: "doc.text.fill")
                .font(.system(size: 60, weight: .light))
                .foregroundStyle(AppTheme.textSecondary)

            VStack(spacing: 12) {
                Text("No Programs Yet")
                    .font(AppTheme.Typography.title1)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.textPrimary)

                Text("Create your first workout program to get started")
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Button(action: { showAddProgram = true }) {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .medium))

                    Text("Create Program")
                        .font(AppTheme.Typography.headline)
                }
                .foregroundStyle(AppTheme.darkBackground)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(AppTheme.neonGreen)
                .cornerRadius(AppTheme.Layout.buttonCornerRadius)
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Programs ScrollView

    private var programsScrollView: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.filteredPrograms) { program in
                    NavigationLink {
                        ProgramDetailView_Premium(program: program, viewModel: viewModel)
                    } label: {
                        PremiumProgramCard(
                            program: program,
                            gradient: determineGradient(for: program)
                        )
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(action: {
                            programToEdit = program
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }

                        Button(action: {
                            Task { await viewModel.copyProgram(program) }
                        }) {
                            Label("Copy", systemImage: "doc.on.doc")
                        }

                        Button(action: {
                            shareItems = viewModel.getShareItems(for: program)
                            showShareSheet = true
                        }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }

                        Divider()

                        Button(role: .destructive, action: {
                            programToDelete = program
                            showDeleteConfirmation = true
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(AppTheme.Layout.screenPadding)
            .padding(.bottom, 80) // Space for tab bar
        }
    }

    // MARK: - Gradient Logic

    private func determineGradient(for program: Program) -> LinearGradient {
        // Rotate through gradients based on program index
        let index = viewModel.filteredPrograms.firstIndex(where: { $0.id == program.id }) ?? 0
        let gradients = [
            AppTheme.primaryGradient,
            AppTheme.secondaryGradient,
            AppTheme.accentGradient,
            AppTheme.energyGradient,
            AppTheme.volumeGradient,
            AppTheme.streakGradient
        ]
        return gradients[index % gradients.count]
    }
}

// MARK: - Premium Program Detail View

struct ProgramDetailView_Premium: View {
    let program: Program
    @ObservedObject var viewModel: ProgramViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showAddDay = false
    @State private var dayToEdit: WorkoutDay?
    @State private var showEditProgram = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        ZStack {
            // Background
            AppTheme.darkBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Hero header
                    programHeader

                    // Sessions section
                    daysSection
                }
                .padding(AppTheme.Layout.screenPadding)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: { showAddDay = true }) {
                        Label("Add Day", systemImage: "plus")
                    }

                    Button(action: { showEditProgram = true }) {
                        Label("Edit Program", systemImage: "pencil")
                    }

                    Divider()

                    Button(role: .destructive, action: {
                        showDeleteConfirmation = true
                    }) {
                        Label("Delete Program", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(AppTheme.neonGreen)
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
        .alert("Delete Program?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteProgram(program)
                    dismiss()
                }
            }
        } message: {
            Text("This will permanently delete \"\(program.name)\" and all \(program.days.count) sessions inside it. This action cannot be undone.")
        }
    }

    // MARK: - Program Header

    private var programHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !program.description.isEmpty {
                Text(program.description)
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            HStack(spacing: 12) {
                // Sessions stat
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(program.days.count)")
                        .font(.system(size: 32, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                    Label("Days", systemImage: "calendar")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.Layout.cardCornerRadius)

                // Exercises stat
                VStack(alignment: .leading, spacing: 4) {
                    let totalExercises = program.days.reduce(0) { $0 + $1.exercises.count }
                    Text("\(totalExercises)")
                        .font(.system(size: 32, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                    Label("Exercises", systemImage: "dumbbell.fill")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.Layout.cardCornerRadius)
            }
        }
    }

    // MARK: - Sessions Section

    private var daysSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Workout Days")
                    .font(AppTheme.Typography.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                Button(action: { showAddDay = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(AppTheme.neonGreen)
                }
            }

            if program.days.isEmpty {
                emptyDaysView
            } else {
                ForEach(program.days.sorted(by: { $0.order < $1.order })) { day in
                    NavigationLink {
                        WorkoutDayView(program: program, day: day, viewModel: viewModel)
                    } label: {
                        PremiumDayCard(day: day)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(action: {
                            dayToEdit = day
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }

                        Button(role: .destructive, action: {
                            Task { await viewModel.deleteDay(from: program, day: day) }
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }

    private var emptyDaysView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(AppTheme.textSecondary)

            Text("No days yet")
                .font(AppTheme.Typography.headline)
                .foregroundStyle(AppTheme.textPrimary)

            Button("Add Day") {
                showAddDay = true
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.neonGreen)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.Layout.cardCornerRadius)
    }
}

// MARK: - Preview

#Preview("Program List") {
    ProgramListView_Premium(viewModel: ProgramViewModel(userId: "preview"))
}

#Preview("Program Detail") {
    NavigationStack {
        ProgramDetailView_Premium(
            program: Program(
                userId: "preview",
                name: "Power Building 12-Week",
                description: "Strength and hypertrophy focused program for serious lifters",
                days: [
                    WorkoutDay(name: "Push Day A", exercises: [
                        Exercise(name: "Bench Press", targetSets: 4, targetReps: 8, targetWeight: 185),
                        Exercise(name: "Incline Dumbbell Press", targetSets: 3, targetReps: 10)
                    ], order: 0),
                    WorkoutDay(name: "Pull Day", exercises: [
                        Exercise(name: "Deadlift", targetSets: 5, targetReps: 5, targetWeight: 315)
                    ], order: 1),
                    WorkoutDay(name: "Leg Day", exercises: [], order: 2)
                ]
            ),
            viewModel: ProgramViewModel(userId: "preview")
        )
    }
}
