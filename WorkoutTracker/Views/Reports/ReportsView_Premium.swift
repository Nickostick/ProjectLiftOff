import SwiftUI
import Charts

/// Premium 2026 ReportsView - Bold gradient aesthetic with energetic stats
struct ReportsView_Premium: View {
    @StateObject private var viewModel: ReportsViewModel
    @ObservedObject var logViewModel: WorkoutLogViewModel

    @State private var selectedExercise: String?
    @State private var showExportOptions = false

    init(userId: String, logViewModel: WorkoutLogViewModel) {
        _viewModel = StateObject(wrappedValue: ReportsViewModel(userId: userId))
        self.logViewModel = logViewModel
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                backgroundLayer

                ScrollView {
                    VStack(spacing: 24) {
                        // Title
                        HStack {
                            Text("Your Progress")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        .padding(.horizontal, AppTheme.Layout.screenPadding)

                        // Time range selector
                        timeRangePicker
                            .padding(.horizontal, AppTheme.Layout.screenPadding)

                        // Summary stats grid
                        summaryStatsGrid
                            .padding(.horizontal, AppTheme.Layout.screenPadding)

                        // Charts section
                        if !viewModel.weeklyVolumeData.isEmpty {
                            weeklyVolumeChart
                        }

                        if !viewModel.workoutFrequencyData.isEmpty {
                            workoutFrequencyChart
                        }

                        // Personal Records
                        prSection
                            .padding(.horizontal, AppTheme.Layout.screenPadding)

                        // Exercise Progress
                        exerciseProgressSection
                    }
                    .padding(.vertical, 20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        LogListView(viewModel: logViewModel)
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 20))
                            .foregroundStyle(AppTheme.neonGreen)
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: {
                            Task { await viewModel.exportToCSV() }
                        }) {
                            Label("Export CSV", systemImage: "tablecells")
                        }

                        Button(action: {
                            Task { await viewModel.exportToPDF() }
                        }) {
                            Label("Export PDF", systemImage: "doc.richtext")
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(AppTheme.primaryGradient)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .refreshable {
                await viewModel.loadReportData()
            }
            .task {
                await viewModel.loadReportData()
            }
            .sheet(isPresented: $viewModel.showExportSheet) {
                if let url = viewModel.exportURL {
                    ShareSheet(items: [url])
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(AppTheme.neonGreen)
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }

    // MARK: - Background Layer

    private var backgroundLayer: some View {
        ZStack {
            AppTheme.darkBackground
                .ignoresSafeArea()

            GeometryReader { geo in
                AppTheme.backgroundOrb(color: AppTheme.cyan, size: 200, blur: 70)
                    .offset(x: geo.size.width * 0.8, y: 50)

                AppTheme.backgroundOrb(color: AppTheme.neonGreen, size: 180, blur: 65)
                    .offset(x: -50, y: geo.size.height * 0.6)
            }
        }
    }

    // MARK: - Time Range Picker

    private var timeRangePicker: some View {
        HStack(spacing: 0) {
            ForEach(ReportsViewModel.TimeRange.allCases, id: \.self) { range in
                Button(action: {
                    withAnimation(AppTheme.Animation.spring) {
                        viewModel.selectedTimeRange = range
                        Task { await viewModel.loadReportData() }
                    }
                }) {
                    Text(range.shortLabel)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(viewModel.selectedTimeRange == range ? AppTheme.darkBackground : Color(hex: "666666"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            viewModel.selectedTimeRange == range
                                ? AppTheme.neonGreen
                                : Color.clear
                        )
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color(hex: "1A1A1A"))
        .cornerRadius(12)
    }

    // MARK: - Summary Stats Grid

    private var summaryStatsGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                PremiumStatCard(
                    title: "Workouts",
                    value: "\(viewModel.totalWorkouts)",
                    icon: "figure.strengthtraining.traditional",
                    gradient: AppTheme.workoutCountGradient
                )

                PremiumStatCard(
                    title: "Volume",
                    value: formatVolumeShort(viewModel.totalVolume),
                    icon: "scalemass.fill",
                    gradient: AppTheme.volumeGradient,
                    subtitle: "lbs total"
                )
            }
            .frame(height: 160)

            HStack(spacing: 12) {
                PremiumStatCard(
                    title: "Avg Duration",
                    value: viewModel.averageWorkoutDuration.formattedDuration,
                    icon: "clock.fill",
                    gradient: AppTheme.durationGradient
                )

                PremiumStatCard(
                    title: "This Week",
                    value: "\(viewModel.workoutsThisWeek)",
                    icon: "calendar",
                    gradient: AppTheme.streakGradient,
                    subtitle: "workouts"
                )
            }
            .frame(height: 160)
        }
    }

    // MARK: - Weekly Volume Chart

    private var weeklyVolumeChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Volume")
                .font(AppTheme.Typography.title2)
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.horizontal, AppTheme.Layout.screenPadding)

            VStack(alignment: .leading, spacing: 12) {
                Chart(viewModel.weeklyVolumeData) { point in
                    BarMark(
                        x: .value("Week", point.weekLabel),
                        y: .value("Volume", point.volume)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.neonGreen, AppTheme.hotPink],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(6)
                }
                .frame(height: 220)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [5]))
                            .foregroundStyle(Color(.separator).opacity(0.3))
                        AxisValueLabel {
                            if let volume = value.as(Double.self) {
                                Text(formatVolume(volume))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                .padding(20)
            }
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.Layout.cardCornerRadius)
            .padding(.horizontal, AppTheme.Layout.screenPadding)
        }
    }

    // MARK: - Workout Frequency Chart

    private var workoutFrequencyChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Week's Activity")
                .font(AppTheme.Typography.title2)
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.horizontal, AppTheme.Layout.screenPadding)

            VStack(alignment: .leading, spacing: 12) {
                Chart(viewModel.workoutFrequencyData) { point in
                    BarMark(
                        x: .value("Day", point.dayLabel),
                        y: .value("Workouts", point.count)
                    )
                    .foregroundStyle(
                        point.count > 0
                            ? LinearGradient(
                                colors: [AppTheme.successGreen, AppTheme.cyan],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                            : LinearGradient(
                                colors: [Color(.separator).opacity(0.3)],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                    )
                    .cornerRadius(6)
                }
                .frame(height: 180)
                .chartYScale(domain: 0...3)
                .chartYAxis {
                    AxisMarks(position: .leading, values: [0, 1, 2, 3]) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [5]))
                            .foregroundStyle(Color(.separator).opacity(0.3))
                        AxisValueLabel()
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                .padding(20)
            }
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.Layout.cardCornerRadius)
            .padding(.horizontal, AppTheme.Layout.screenPadding)
        }
    }

    // MARK: - PR Section

    private var prSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Personal Records")
                    .font(AppTheme.Typography.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                Text("\(viewModel.allPRs.count) total")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(AppTheme.cardBackground)
                    )
            }

            if viewModel.allPRs.isEmpty {
                emptyPRsView
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.recentPRs) { pr in
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

    private var emptyPRsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "trophy")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(AppTheme.textSecondary)

            Text("Complete workouts to set PRs")
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.Layout.cardCornerRadius)
    }

    // MARK: - Exercise Progress Section

    private var exerciseProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Exercise Progress")
                .font(AppTheme.Typography.title2)
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.horizontal, AppTheme.Layout.screenPadding)

            if viewModel.allPRs.isEmpty {
                emptyExerciseProgressView
                    .padding(.horizontal, AppTheme.Layout.screenPadding)
            } else {
                // Exercise selector chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(Set(viewModel.allPRs.map { $0.exerciseName })).sorted(), id: \.self) { exercise in
                            Button(action: {
                                withAnimation(AppTheme.Animation.spring) {
                                    selectedExercise = exercise
                                    Task { await viewModel.loadExerciseProgress(exerciseName: exercise) }
                                }
                            }) {
                                ExerciseChip(
                                    name: exercise,
                                    isSelected: selectedExercise == exercise,
                                    gradient: AppTheme.muscleGroupGradient(for: exercise)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, AppTheme.Layout.screenPadding)
                }

                // Progress chart for selected exercise
                if let exercise = selectedExercise,
                   let progress = viewModel.exerciseProgressData.first(where: { $0.exerciseName == exercise }),
                   !progress.dataPoints.isEmpty {
                    ProgressChartView(progress: progress)
                        .padding(.horizontal, AppTheme.Layout.screenPadding)
                }
            }
        }
    }

    private var emptyExerciseProgressView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(AppTheme.textSecondary)

            Text("Exercise progress charts will appear once you log workouts")
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.Layout.cardCornerRadius)
    }

    // MARK: - Helpers

    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1000 {
            return String(format: "%.0fk", volume / 1000)
        }
        return String(format: "%.0f", volume)
    }

    private func formatVolumeShort(_ volume: Double) -> String {
        if volume >= 1_000_000 {
            return String(format: "%.1fM", volume / 1_000_000)
        } else if volume >= 1000 {
            return String(format: "%.1fk", volume / 1000)
        }
        return String(format: "%.0f", volume)
    }
}

// MARK: - Preview

#Preview {
    ReportsView_Premium(
        userId: "preview",
        logViewModel: WorkoutLogViewModel(userId: "preview")
    )
}
