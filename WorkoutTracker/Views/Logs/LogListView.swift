import SwiftUI

/// List view for all workout logs
struct LogListView: View {
    @ObservedObject var viewModel: WorkoutLogViewModel
    
    @State private var searchText = ""
    @State private var selectedFilter: LogFilter = .all
    
    enum LogFilter: String, CaseIterable {
        case all = "All"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
    }
    
    var filteredLogs: [WorkoutLog] {
        var logs = viewModel.logs
        
        // Apply time filter
        switch selectedFilter {
        case .all:
            break
        case .thisWeek:
            logs = logs.filter { $0.startedAt.isThisWeek }
        case .thisMonth:
            let startOfMonth = Date().startOfMonth
            logs = logs.filter { $0.startedAt >= startOfMonth }
        }
        
        // Apply search
        if !searchText.isEmpty {
            logs = logs.filter {
                $0.dayName.localizedCaseInsensitiveContains(searchText) ||
                $0.programName.localizedCaseInsensitiveContains(searchText) ||
                $0.exercises.contains { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return logs
    }
    
    var groupedLogs: [(String, [WorkoutLog])] {
        Dictionary(grouping: filteredLogs) { log in
            log.startedAt.formatted(.dateTime.month().year())
        }
        .sorted { $0.key > $1.key }
    }
    
    var body: some View {
        Group {
            if viewModel.logs.isEmpty && !viewModel.isLoading {
                EmptyStateView(
                    icon: "doc.text.fill",
                    title: "No Workout Logs",
                    message: "Complete a workout to see it here."
                )
            } else {
                List {
                    // Filter Picker
                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(LogFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 8)
                    
                    // Grouped Logs
                    ForEach(groupedLogs, id: \.0) { month, logs in
                        Section(month) {
                            ForEach(logs) { log in
                                NavigationLink {
                                    LogDetailView(log: log)
                                } label: {
                                    LogRow(log: log)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        Task { await viewModel.deleteLog(log) }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search workouts")
            }
        }
        .navigationTitle("Workout Log")
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
    }
}

// MARK: - Log Row

struct LogRow: View {
    let log: WorkoutLog
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(log.dayName)
                        .font(.headline)
                    
                    if !log.programName.isEmpty {
                        Text(log.programName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(log.startedAt.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()))
                        .font(.subheadline)
                    Text(log.formattedDuration)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            HStack(spacing: 16) {
                Label("\(log.exercises.count) exercises", systemImage: "dumbbell")
                Label("\(log.totalSetsCompleted) sets", systemImage: "checkmark.circle")
                Label(log.totalVolume.formattedVolume + " lbs", systemImage: "scalemass")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            
            // Show PRs if any
            let prExercises = log.exercises.filter { ex in
                ex.completedSets.contains { $0.isPR }
            }
            if !prExercises.isEmpty {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.yellow)
                    Text("PRs: \(prExercises.map { $0.name }.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        LogListView(viewModel: WorkoutLogViewModel(userId: "preview"))
    }
}
