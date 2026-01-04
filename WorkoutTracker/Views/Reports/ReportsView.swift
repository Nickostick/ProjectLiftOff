import SwiftUI
import Charts

/// Reports view with statistics and charts
struct ReportsView: View {
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
            ScrollView {
                VStack(spacing: 20) {
                    // Time Range Picker
                    Picker("Time Range", selection: $viewModel.selectedTimeRange) {
                        ForEach(ReportsViewModel.TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .onChange(of: viewModel.selectedTimeRange) { _, _ in
                        Task { await viewModel.loadReportData() }
                    }
                    
                    // Summary Cards
                    summarySection
                    
                    // Weekly Volume Chart
                    if !viewModel.weeklyVolumeData.isEmpty {
                        weeklyVolumeChart
                    }
                    
                    // Workout Frequency Chart
                    if !viewModel.workoutFrequencyData.isEmpty {
                        workoutFrequencyChart
                    }
                    
                    // Personal Records
                    prSection
                    
                    // Exercise Progress
                    exerciseProgressSection
                }
                .padding(.vertical)
            }
            .navigationTitle("Reports")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        LogListView(viewModel: logViewModel)
                    } label: {
                        Label("History", systemImage: "clock.arrow.circlepath")
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
                        Image(systemName: "square.and.arrow.up")
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
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
    
    // MARK: - Summary Section
    
    private var summarySection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCardView(
                    title: "Total Workouts",
                    value: "\(viewModel.totalWorkouts)",
                    icon: "figure.strengthtraining.traditional",
                    color: .blue
                )
                
                StatCardView(
                    title: "Total Volume",
                    value: viewModel.totalVolume.formattedVolume + " lbs",
                    icon: "scalemass.fill",
                    color: .purple
                )
            }
            
            HStack(spacing: 12) {
                StatCardView(
                    title: "Avg. Duration",
                    value: viewModel.averageWorkoutDuration.formattedDuration,
                    icon: "clock.fill",
                    color: .orange
                )
                
                StatCardView(
                    title: "This Week",
                    value: "\(viewModel.workoutsThisWeek) workouts",
                    icon: "calendar",
                    color: .green
                )
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Weekly Volume Chart
    
    private var weeklyVolumeChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Volume")
                .font(.headline)
                .padding(.horizontal)
            
            Chart(viewModel.weeklyVolumeData) { point in
                BarMark(
                    x: .value("Week", point.weekLabel),
                    y: .value("Volume", point.volume)
                )
                .foregroundStyle(Color.blue.gradient)
                .cornerRadius(4)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let volume = value.as(Double.self) {
                            Text(formatVolume(volume))
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(Constants.UI.cornerRadius)
        .padding(.horizontal)
    }
    
    // MARK: - Workout Frequency Chart
    
    private var workoutFrequencyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week's Activity")
                .font(.headline)
                .padding(.horizontal)
            
            Chart(viewModel.workoutFrequencyData) { point in
                BarMark(
                    x: .value("Day", point.dayLabel),
                    y: .value("Workouts", point.count)
                )
                .foregroundStyle(point.count > 0 ? Color.green.gradient : Color.gray.opacity(0.3).gradient)
                .cornerRadius(4)
            }
            .frame(height: 150)
            .chartYScale(domain: 0...3)
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(Constants.UI.cornerRadius)
        .padding(.horizontal)
    }
    
    // MARK: - PR Section
    
    private var prSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Personal Records")
                    .font(.headline)
                
                Spacer()
                
                Text("\(viewModel.allPRs.count) total")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            if viewModel.allPRs.isEmpty {
                Text("Complete workouts to set PRs")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                ForEach(viewModel.recentPRs) { pr in
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(pr.exerciseName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(pr.achievedAt.formattedRelative)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(pr.formattedRecord)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Est. 1RM: \(String(format: "%.0f", pr.estimated1RM)) lbs")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(Constants.UI.cornerRadius)
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - Exercise Progress Section
    
    private var exerciseProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Exercise Progress")
                .font(.headline)
                .padding(.horizontal)
            
            if viewModel.allPRs.isEmpty {
                Text("Exercise progress charts will appear once you log workouts")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                // Exercise selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(Set(viewModel.allPRs.map { $0.exerciseName })).sorted(), id: \.self) { exercise in
                            Button(action: {
                                selectedExercise = exercise
                                Task { await viewModel.loadExerciseProgress(exerciseName: exercise) }
                            }) {
                                Text(exercise)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(selectedExercise == exercise ? Color.blue : Color(.secondarySystemBackground))
                                    .foregroundStyle(selectedExercise == exercise ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Progress chart for selected exercise
                if let exercise = selectedExercise,
                   let progress = viewModel.exerciseProgressData.first(where: { $0.exerciseName == exercise }),
                   !progress.dataPoints.isEmpty {
                    ProgressChartView(progress: progress)
                        .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1000 {
            return String(format: "%.0fk", volume / 1000)
        }
        return String(format: "%.0f", volume)
    }
}

#Preview {
    ReportsView(
        userId: "preview",
        logViewModel: WorkoutLogViewModel(userId: "preview")
    )
}
