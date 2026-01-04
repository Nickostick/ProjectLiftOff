import SwiftUI

/// Premium 2026 HomeView - Bold gradient aesthetic with energetic vibes
struct HomeView_Premium: View {
    @ObservedObject var logViewModel: WorkoutLogViewModel
    @ObservedObject var programViewModel: ProgramViewModel

    @State private var showStartWorkout = false
    @State private var selectedProgram: Program?
    @State private var selectedDay: WorkoutDay?

    var body: some View {
        NavigationStack {
            ZStack {
                // Background with subtle orbs
                backgroundLayer

                ScrollView {
                    VStack(spacing: 24) {
                        // Welcome Section
                        welcomeSection
                            .padding(.horizontal, AppTheme.Layout.screenPadding)

                        // Hero Volume Card
                        heroVolumeCard
                            .padding(.horizontal, AppTheme.Layout.screenPadding)

                        // Quick Stats Grid
                        statsGrid
                            .padding(.horizontal, AppTheme.Layout.screenPadding)

                        // Quick Start CTA
                        quickStartCTA
                            .padding(.horizontal, AppTheme.Layout.screenPadding)

                        // Recent Workouts
                        recentWorkoutsSection

                        // Personal Records
                        if !logViewModel.personalRecords.isEmpty {
                            prSection
                                .padding(.horizontal, AppTheme.Layout.screenPadding)
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
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

    // MARK: - Background Layer

    private var backgroundLayer: some View {
        AppTheme.darkBackground.ignoresSafeArea()
    }

    // MARK: - Welcome Section

    private var welcomeSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(greeting)
                    .font(AppTheme.Typography.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(Date().formatted(.dateTime.weekday(.wide).month().day()))
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            // Profile circle
            Circle()
                .fill(AppTheme.cardBackground)
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                )
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        default:
            return "Good Evening"
        }
    }

    // MARK: - Hero Volume Card

    private var heroVolumeCard: some View {
        HeroStatCard(
            title: "Volume This Week",
            value: logViewModel.totalVolumeThisWeek.formattedVolume + " lbs",
            icon: "scalemass.fill",
            gradient: AppTheme.volumeGradient,
            trend: calculateWeeklyTrend(),
            trendUp: true
        )
        .accessibilityLabel("Weekly volume: \(logViewModel.totalVolumeThisWeek.formattedVolume) pounds")
    }

    private func calculateWeeklyTrend() -> String? {
        // Placeholder for trend calculation
        // Could compare to previous week's volume
        return nil
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        HStack(spacing: 12) {
            PremiumStatCard(
                title: "Workouts",
                value: "\(logViewModel.workoutsThisWeek)",
                icon: "figure.strengthtraining.traditional",
                gradient: AppTheme.workoutCountGradient,
                subtitle: "This week"
            )

            PremiumStatCard(
                title: "PRs",
                value: "\(logViewModel.personalRecords.count)",
                icon: "trophy.fill",
                gradient: AppTheme.prGradient,
                subtitle: "All time"
            )
        }
        .frame(height: 160)
    }

    // MARK: - Quick Start CTA

    private var quickStartCTA: some View {
        GlowingCTAButton(
            title: "Start Workout",
            subtitle: "Choose a template or start fresh",
            icon: "play.fill",
            gradient: AppTheme.energyGradient,
            action: { showStartWorkout = true }
        )
        .accessibilityLabel("Start workout")
        .accessibilityHint("Opens workout template selection")
    }

    // MARK: - Recent Workouts Section

    private var recentWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Workouts")
                    .font(AppTheme.Typography.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                NavigationLink {
                    LogListView(viewModel: logViewModel)
                } label: {
                    Text("See All")
                        .font(AppTheme.Typography.callout)
                        .foregroundStyle(AppTheme.neonGreen)
                }
            }
            .padding(.horizontal, AppTheme.Layout.screenPadding)

            if logViewModel.recentLogs.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "dumbbell")
                        .font(.system(size: 48, weight: .light))
                        .foregroundStyle(AppTheme.textSecondary)

                    Text("No Workouts Yet")
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("Start your first workout to see it here")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.Layout.cardCornerRadius)
                .padding(.horizontal, AppTheme.Layout.screenPadding)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(logViewModel.recentLogs.prefix(5)) { log in
                            NavigationLink {
                                LogDetailView(log: log)
                            } label: {
                                PremiumRecentWorkoutCard(log: log)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, AppTheme.Layout.screenPadding)
                }
            }
        }
    }

    // MARK: - PR Section

    private var prSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent PRs")
                .font(AppTheme.Typography.title2)
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.textPrimary)

            VStack(spacing: 12) {
                ForEach(logViewModel.personalRecords.prefix(3)) { pr in
                    PRAchievementCard(
                        exerciseName: pr.exerciseName,
                        record: pr.formattedRecord,
                        achievedAt: pr.achievedAt.formattedRelative,
                        estimated1RM: "\(String(format: "%.0f", pr.estimated1RM)) lbs",
                        gradient: AppTheme.muscleGroupGradient(for: pr.exerciseName)
                    )
                }
            }
        }
    }
}

// MARK: - Premium Recent Workout Card

struct PremiumRecentWorkoutCard: View {
    let log: WorkoutLog

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date badge
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(log.startedAt.formatted(.dateTime.day()))
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(log.startedAt.formatted(.dateTime.month(.abbreviated)))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Spacer()
            }

            Spacer()

            // Workout name
            Text(log.dayName)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(2)

            // Stats
            VStack(alignment: .leading, spacing: 6) {
                Label("\(log.exercises.count) exercises", systemImage: "dumbbell.fill")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(AppTheme.textSecondary)

                Label(log.formattedDuration, systemImage: "clock.fill")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .padding(16)
        .frame(width: 160, height: 180)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Layout.cardCornerRadius)
                .fill(AppTheme.cardBackground)
        )
    }
}

// MARK: - Preview

#Preview {
    HomeView_Premium(
        logViewModel: WorkoutLogViewModel(userId: "preview"),
        programViewModel: ProgramViewModel(userId: "preview")
    )
}
