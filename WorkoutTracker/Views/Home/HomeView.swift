import SwiftUI

/// Dashboard home view showing workout summary and quick actions
struct HomeView: View {
    @ObservedObject var logViewModel: WorkoutLogViewModel
    @ObservedObject var programViewModel: ProgramViewModel
    
    @State private var showStartWorkout = false
    @State private var selectedProgram: Program?
    @State private var selectedDay: WorkoutDay?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Section
                    welcomeSection
                    
                    // Quick Stats
                    statsSection
                    
                    // Quick Start Section
                    quickStartSection
                    
                    // Recent Workouts
                    recentWorkoutsSection
                    
                    // Personal Records
                    if !logViewModel.personalRecords.isEmpty {
                        prSection
                    }
                }
                .padding()
            }
            .navigationTitle("Home")
            .refreshable {
                // Triggers data refresh via listeners
            }
            .sheet(isPresented: $showStartWorkout) {
                StartWorkoutSheet(
                    programViewModel: programViewModel,
                    onSelect: { program, day in
                        logViewModel.startWorkout(from: day, program: program)
                        showStartWorkout = false
                    },
                    onQuickStart: {
                        logViewModel.startBlankWorkout()
                        showStartWorkout = false
                    }
                )
            }
            .fullScreenCover(isPresented: $logViewModel.isWorkoutActive) {
                ActiveWorkoutView(viewModel: logViewModel)
            }
        }
    }
    
    // MARK: - Sections
    
    private var welcomeSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(Date().formatted(.dateTime.weekday(.wide).month().day()))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Profile placeholder
            Circle()
                .fill(Color.blue.gradient)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundStyle(.white)
                )
        }
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good Morning!"
        case 12..<17:
            return "Good Afternoon!"
        default:
            return "Good Evening!"
        }
    }
    
    private var statsSection: some View {
        VStack(spacing: 12) {
            LargeStatCardView(
                title: "Volume This Week",
                value: logViewModel.totalVolumeThisWeek.formattedVolume + " lbs",
                icon: "scalemass.fill",
                color: .purple
            )
            
            HStack(spacing: 12) {
                StatCardView(
                    title: "Workouts",
                    value: "\(logViewModel.workoutsThisWeek)",
                    icon: "figure.strengthtraining.traditional",
                    color: .blue,
                    subtitle: "This week"
                )
                
                StatCardView(
                    title: "Personal Records",
                    value: "\(logViewModel.personalRecords.count)",
                    icon: "trophy.fill",
                    color: .yellow
                )
            }
        }
    }
    
    private var quickStartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Start")
                .font(.headline)
            
            Button(action: { showStartWorkout = true }) {
                HStack {
                    Image(systemName: "play.fill")
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Start Workout")
                            .font(.headline)
                        Text("Choose a template or start fresh")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundStyle(.white)
                .cornerRadius(Constants.UI.cornerRadius)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var recentWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Workouts")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink("See All") {
                    LogListView(viewModel: logViewModel)
                }
                .font(.subheadline)
            }
            
            if logViewModel.recentLogs.isEmpty {
                EmptyStateView(
                    icon: "dumbbell",
                    title: "No Workouts Yet",
                    message: "Start your first workout to see it here."
                )
                .frame(height: 150)
            } else {
                ForEach(logViewModel.recentLogs.prefix(3)) { log in
                    NavigationLink {
                        LogDetailView(log: log)
                    } label: {
                        RecentWorkoutRow(log: log)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var prSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent PRs")
                .font(.headline)
            
            ForEach(logViewModel.personalRecords.prefix(3)) { pr in
                PRRow(record: pr)
            }
        }
    }
}

// MARK: - Supporting Views

struct RecentWorkoutRow: View {
    let log: WorkoutLog
    
    var body: some View {
        HStack(spacing: 16) {
            // Date
            VStack(spacing: 2) {
                Text(log.startedAt.formatted(.dateTime.day()))
                    .font(.title3)
                    .fontWeight(.bold)
                Text(log.startedAt.formatted(.dateTime.month(.abbreviated)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 44)
            
            // Workout info
            VStack(alignment: .leading, spacing: 4) {
                Text(log.dayName)
                    .font(.headline)
                
                HStack(spacing: 12) {
                    Label("\(log.exercises.count) exercises", systemImage: "dumbbell")
                    Label(log.formattedDuration, systemImage: "clock")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(Constants.UI.cornerRadius)
    }
}

struct PRRow: View {
    let record: PersonalRecord
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "trophy.fill")
                .font(.title3)
                .foregroundStyle(.yellow)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(record.exerciseName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(record.achievedAt.formattedRelative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(record.formattedRecord)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.blue)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(Constants.UI.cornerRadius)
    }
}

// MARK: - Start Workout Sheet

struct StartWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var programViewModel: ProgramViewModel
    
    let onSelect: (Program?, WorkoutDay) -> Void
    let onQuickStart: () -> Void
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button(action: onQuickStart) {
                        HStack {
                            Image(systemName: "bolt.fill")
                                .foregroundStyle(.orange)
                            Text("Quick Start (Empty Workout)")
                        }
                    }
                }
                
                Section("Choose a Template") {
                    if programViewModel.programs.isEmpty {
                        Text("No programs yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(programViewModel.programs) { program in
                            DisclosureGroup(program.name) {
                                ForEach(program.days) { day in
                                    Button(action: {
                                        onSelect(program, day)
                                    }) {
                                        HStack {
                                            Text(day.name)
                                            Spacer()
                                            Text("\(day.exerciseCount) exercises")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Start Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    HomeView(
        logViewModel: WorkoutLogViewModel(userId: "preview"),
        programViewModel: ProgramViewModel(userId: "preview")
    )
}
