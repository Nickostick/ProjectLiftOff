import Foundation
import UserNotifications

/// Manages local notifications for workout reminders
final class NotificationManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = NotificationManager()
    
    // MARK: - Published Properties
    @Published private(set) var isAuthorized = false
    @Published var reminderEnabled = false
    @Published var reminderTime = DateComponents(hour: 9, minute: 0)
    @Published var reminderDays: Set<Int> = [2, 4, 6] // Mon, Wed, Fri (Sunday = 1)
    
    // MARK: - Private Properties
    private let center = UNUserNotificationCenter.current()
    
    // MARK: - Initialization
    private init() {
        loadSettings()
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    /// Request notification permission
    @MainActor
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            isAuthorized = granted
            return granted
        } catch {
            print("❌ Notification authorization error: \(error)")
            return false
        }
    }
    
    /// Check current authorization status
    func checkAuthorizationStatus() {
        center.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Reminder Scheduling
    
    /// Schedule workout reminders based on settings
    func scheduleReminders() {
        guard isAuthorized && reminderEnabled else {
            cancelAllReminders()
            return
        }
        
        // Cancel existing reminders first
        cancelAllReminders()
        
        // Schedule for each selected day
        for weekday in reminderDays {
            scheduleReminder(for: weekday)
        }
        
        print("✅ Scheduled reminders for days: \(reminderDays)")
    }
    
    /// Schedule a reminder for a specific weekday
    private func scheduleReminder(for weekday: Int) {
        var dateComponents = reminderTime
        dateComponents.weekday = weekday
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = "Time to Workout! 💪"
        content.body = getRandomMotivationalMessage()
        content.sound = .default
        content.categoryIdentifier = "WORKOUT_REMINDER"
        
        let request = UNNotificationRequest(
            identifier: "workout_reminder_\(weekday)",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("❌ Failed to schedule reminder: \(error)")
            }
        }
    }
    
    /// Cancel all scheduled reminders
    func cancelAllReminders() {
        center.removePendingNotificationRequests(withIdentifiers: 
            (1...7).map { "workout_reminder_\($0)" }
        )
    }
    
    /// Schedule a one-time reminder
    func scheduleOneTimeReminder(at date: Date, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("❌ Failed to schedule one-time reminder: \(error)")
            }
        }
    }
    
    // MARK: - Settings Persistence
    
    private func loadSettings() {
        reminderEnabled = UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.enableNotifications)
        
        if let days = UserDefaults.standard.array(forKey: Constants.UserDefaultsKeys.reminderDays) as? [Int] {
            reminderDays = Set(days)
        }
        
        if let hour = UserDefaults.standard.object(forKey: "reminderHour") as? Int,
           let minute = UserDefaults.standard.object(forKey: "reminderMinute") as? Int {
            reminderTime = DateComponents(hour: hour, minute: minute)
        }
    }
    
    func saveSettings() {
        UserDefaults.standard.set(reminderEnabled, forKey: Constants.UserDefaultsKeys.enableNotifications)
        UserDefaults.standard.set(Array(reminderDays), forKey: Constants.UserDefaultsKeys.reminderDays)
        UserDefaults.standard.set(reminderTime.hour, forKey: "reminderHour")
        UserDefaults.standard.set(reminderTime.minute, forKey: "reminderMinute")
        
        scheduleReminders()
    }
    
    // MARK: - Helper Methods
    
    private func getRandomMotivationalMessage() -> String {
        let messages = [
            "Your future self will thank you! Let's crush it today.",
            "Consistency beats intensity. Time to build those habits!",
            "Every rep counts. Let's make today count!",
            "Progress, not perfection. Get moving!",
            "You're stronger than you think. Prove it today!",
            "The only bad workout is the one that didn't happen.",
            "Champions are made when no one is watching.",
            "Your body can stand almost anything. It's your mind you have to convince."
        ]
        return messages.randomElement() ?? messages[0]
    }
    
    /// Get weekday name from number (1 = Sunday)
    static func weekdayName(_ weekday: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        
        var components = DateComponents()
        components.weekday = weekday
        
        if let date = Calendar.current.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime) {
            return formatter.string(from: date)
        }
        return ""
    }
}
