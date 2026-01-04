import SwiftUI

/// List view for all workout programs
struct ProgramListView: View {
    @ObservedObject var viewModel: ProgramViewModel
    
    @State private var showAddProgram = false
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var programToEdit: Program?
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.programs.isEmpty && !viewModel.isLoading {
                    EmptyStateView(
                        icon: "doc.text.fill",
                        title: "No Programs Yet",
                        message: "Create your first workout program to get started.",
                        actionTitle: "Create Program",
                        action: { showAddProgram = true }
                    )
                } else {
                    List {
                        ForEach(viewModel.filteredPrograms) { program in
                            NavigationLink {
                                ProgramDetailView(program: program, viewModel: viewModel)
                            } label: {
                                ProgramRow(program: program)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    Task { await viewModel.deleteProgram(program) }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {
                                    programToEdit = program
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    Task { await viewModel.copyProgram(program) }
                                } label: {
                                    Label("Copy", systemImage: "doc.on.doc")
                                }
                                .tint(.green)
                                
                                Button {
                                    shareItems = viewModel.getShareItems(for: program)
                                    showShareSheet = true
                                } label: {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                                .tint(.orange)
                            }
                        }
                    }
                    .searchable(text: $viewModel.searchText, prompt: "Search programs")
                    .refreshable {
                        // Refresh handled by listener
                    }
                }
            }
            .navigationTitle("Programs")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddProgram = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
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
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

// MARK: - Program Row

struct ProgramRow: View {
    let program: Program
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(program.name)
                    .font(.headline)
                
                Spacer()
                
                Text("\(program.days.count) days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if !program.description.isEmpty {
                Text(program.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                ForEach(program.days.prefix(4)) { day in
                    Text(day.name)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
                
                if program.days.count > 4 {
                    Text("+\(program.days.count - 4)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ProgramListView(viewModel: ProgramViewModel(userId: "preview"))
}
