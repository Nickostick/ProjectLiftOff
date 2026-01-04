import SwiftUI

/// Main app entry point
@main
struct WorkoutTrackerApp: App {
    
    // Initialize Firebase on app launch
    init() {
        FirebaseService.shared.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(nil) // Respects system dark mode setting
        }
    }
}
