import SwiftUI
import FirebaseAuth

/// Main content view that handles authentication state routing
struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView(userId: authViewModel.currentUserId ?? "")
            } else {
                AuthenticationView()
            }
        }
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
    }
}

/// Main tab-based navigation for authenticated users
struct MainTabView: View {
    let userId: String
    
    @StateObject private var programViewModel: ProgramViewModel
    @StateObject private var logViewModel: WorkoutLogViewModel
    @State private var selectedTab = Tab.home
    @State private var showStartWorkout = false
    
    enum Tab {
        case home, programs, reports, settings
    }
    
    init(userId: String) {
        self.userId = userId
        _programViewModel = StateObject(wrappedValue: ProgramViewModel(userId: userId))
        _logViewModel = StateObject(wrappedValue: WorkoutLogViewModel(userId: userId))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content
            Group {
                switch selectedTab {
                case .home:
                    HomeView_Premium(logViewModel: logViewModel, programViewModel: programViewModel)
                case .programs:
                    ProgramListView_Premium(viewModel: programViewModel)
                case .reports:
                    ReportsView_Premium(userId: userId, logViewModel: logViewModel)
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 60)
            }
            
            // Premium Custom Tab Bar
            PremiumTabBar(selectedTab: $selectedTab) {
                showStartWorkout = true
            }
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

struct CustomTabBar: View {
    @Binding var selectedTab: MainTabView.Tab
    let onStartWorkout: () -> Void
    
    var body: some View {
        HStack {
            // Home
            TabButton(icon: "house.fill", title: "Home", isSelected: selectedTab == .home) {
                selectedTab = .home
            }
            
            Spacer()
            
            // Programs
            TabButton(icon: "doc.text.fill", title: "Programs", isSelected: selectedTab == .programs) {
                selectedTab = .programs
            }
            
            Spacer()
            
            // Start Workout Button
            Button(action: onStartWorkout) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 56, height: 56)
                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }
            .offset(y: -20)
            
            Spacer()
            
            // Reports
            TabButton(icon: "chart.bar.fill", title: "Reports", isSelected: selectedTab == .reports) {
                selectedTab = .reports
            }
            
            Spacer()
            
            // Settings
            TabButton(icon: "gearshape.fill", title: "Settings", isSelected: selectedTab == .settings) {
                selectedTab = .settings
            }
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 1)
        .background(
            Rectangle()
                .fill(.regularMaterial)
                .ignoresSafeArea()
                .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
        )
    }
}

struct TabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .foregroundStyle(isSelected ? .blue : .secondary)
            .frame(width: 60)
        }
        .buttonStyle(.plain)
    }
}

/// Settings view for app configuration
struct SettingsView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var notificationManager = NotificationManager.shared
    
    @State private var showSignOutAlert = false
    @State private var showDeleteAccountAlert = false
    @AppStorage(Constants.UserDefaultsKeys.preferredWeightUnit) private var weightUnit = WeightUnit.pounds.rawValue
    
    var body: some View {
        NavigationStack {
            List {
                // Account Section
                Section("Account") {
                    if let user = authViewModel.currentUser {
                        HStack {
                            Circle()
                                .fill(Color.blue.gradient)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text(String(user.email?.prefix(1).uppercased() ?? "U"))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.displayName ?? "User")
                                    .font(.headline)
                                Text(user.email ?? "")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    Button(role: .destructive, action: { showSignOutAlert = true }) {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
                
                // Preferences Section
                Section("Preferences") {
                    Picker("Weight Unit", selection: $weightUnit) {
                        ForEach(WeightUnit.allCases, id: \.rawValue) { unit in
                            Text(unit.fullName).tag(unit.rawValue)
                        }
                    }
                }
                
                // Notifications Section
                Section("Notifications") {
                    Toggle("Workout Reminders", isOn: $notificationManager.reminderEnabled)
                        .onChange(of: notificationManager.reminderEnabled) { _, enabled in
                            if enabled {
                                Task {
                                    let granted = await notificationManager.requestAuthorization()
                                    if !granted {
                                        notificationManager.reminderEnabled = false
                                    } else {
                                        notificationManager.saveSettings()
                                    }
                                }
                            } else {
                                notificationManager.saveSettings()
                            }
                        }
                    
                    if notificationManager.reminderEnabled {
                        NavigationLink {
                            ReminderSettingsView()
                        } label: {
                            Label("Reminder Schedule", systemImage: "clock")
                        }
                    }
                }
                
                // About Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Constants.App.appVersion)
                            .foregroundStyle(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://firebase.google.com")!) {
                        Label("Powered by Firebase", systemImage: "server.rack")
                    }
                }
                
                // Danger Zone
                Section {
                    Button(role: .destructive, action: { showDeleteAccountAlert = true }) {
                        Label("Delete Account", systemImage: "trash")
                    }
                }
            }
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Sign Out", role: .destructive) {
                    authViewModel.signOut()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
                Button("Delete", role: .destructive) {
                    Task {
                        try? await FirebaseService.shared.auth.deleteAccount()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete your account and all data. This action cannot be undone.")
            }
        }
    }
}

/// Reminder settings view for notification configuration
struct ReminderSettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    
    @State private var reminderDate = Date()
    
    private let weekdays = [
        (1, "Sunday"),
        (2, "Monday"),
        (3, "Tuesday"),
        (4, "Wednesday"),
        (5, "Thursday"),
        (6, "Friday"),
        (7, "Saturday")
    ]
    
    var body: some View {
        List {
            Section("Reminder Time") {
                DatePicker(
                    "Time",
                    selection: $reminderDate,
                    displayedComponents: .hourAndMinute
                )
                .onChange(of: reminderDate) { _, newDate in
                    let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                    notificationManager.reminderTime = components
                    notificationManager.saveSettings()
                }
            }
            
            Section("Reminder Days") {
                ForEach(weekdays, id: \.0) { weekday, name in
                    Toggle(name, isOn: Binding(
                        get: { notificationManager.reminderDays.contains(weekday) },
                        set: { isOn in
                            if isOn {
                                notificationManager.reminderDays.insert(weekday)
                            } else {
                                notificationManager.reminderDays.remove(weekday)
                            }
                            notificationManager.saveSettings()
                        }
                    ))
                }
            }
        }
        .navigationTitle("Reminder Schedule")
        .onAppear {
            // Set initial date from reminder time
            var components = DateComponents()
            components.hour = notificationManager.reminderTime.hour ?? 9
            components.minute = notificationManager.reminderTime.minute ?? 0
            if let date = Calendar.current.date(from: components) {
                reminderDate = date
            }
        }
    }
}

#Preview {
    ContentView()
}
