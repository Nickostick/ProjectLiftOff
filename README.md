# ProjectLiftOff 🏋️

A complete iOS workout tracking app with Firebase backend, featuring workout programs, real-time logging, progressive overload tracking, and detailed progress reports.

## ⚠️ Security Notice

**This is a template app.** You must set up your own Firebase project to use it:
- The repository does NOT contain API keys or sensitive credentials
- You need to add your own `GoogleService-Info.plist` (see setup below)
- Configure Firebase Security Rules to protect your data
- Never commit your real Firebase config file to version control

## Features

- **Authentication**: Apple Sign In and email/password via Firebase Auth
- **Premium Dark Theme**: Modern dark UI with neon green (#D4FF00) accents
- **Program Templates**: Create, edit, copy, share, and delete workout programs
- **Workout Days**: Organize programs into multiple workout days (e.g., "Arm Day", "Chest Day")
- **Exercises**: Track sets, reps, weight, notes, and rest times
- **Workout Logging**: Start from templates, log actual performance, timer included
- **Personal Records**: Automatic PR detection and tracking
- **Reports**: Weekly volume charts, exercise progress graphs, export to PDF/CSV
- **Offline Support**: Works offline with automatic sync when online
- **Notifications**: Configurable workout reminders
- **Dark Mode**: Full support for iOS dark mode

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Firebase account

## Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" and follow the wizard
3. Once created, click the iOS icon to add an iOS app
4. Enter bundle ID: `com.workout.tracker` (or your custom bundle ID)
5. Download `GoogleService-Info.plist`

### 2. Add Configuration File

1. Place `GoogleService-Info.plist` in the `WorkoutTracker/WorkoutTracker/` directory
2. In Xcode, right-click the WorkoutTracker folder → Add Files to "WorkoutTracker"
3. Select `GoogleService-Info.plist`

### 3. Enable Firebase Services

In Firebase Console:

1. **Authentication**:
   - Go to Authentication → Sign-in method
   - Enable "Email/Password"
   - Enable "Apple" for Sign in with Apple support

2. **Firestore**:
   - Go to Firestore Database → Create database
   - Choose "Start in test mode" for development
   - Select a location close to your users

3. **Security Rules** (REQUIRED for production):
   - In Firestore Console, go to Rules tab
   - Copy the contents from `firestore.rules` in this repo
   - Deploy the rules to ensure users can only access their own data
   - **Critical**: Never use "test mode" rules in production!

## Installation

1. Clone or download this project
2. Open `WorkoutTracker.xcodeproj` in Xcode
3. Wait for Swift Package Manager to resolve Firebase dependencies (this may take a few minutes)
4. Add your `GoogleService-Info.plist` file
5. Update the bundle identifier in project settings if desired
6. Set your development team in Signing & Capabilities
7. Build and run on simulator or device

## Project Structure

```
WorkoutTracker/
├── WorkoutTrackerApp.swift      # App entry point
├── ContentView.swift            # Root view with auth routing
├── Assets.xcassets              # App icons and colors
│
├── Models/
│   ├── Program.swift            # Workout program template
│   ├── WorkoutDay.swift         # Day within a program
│   ├── Exercise.swift           # Exercise definition
│   ├── WorkoutLog.swift         # Completed workout log
│   └── PersonalRecord.swift     # PR tracking
│
├── ViewModels/
│   ├── AuthViewModel.swift      # Authentication state
│   ├── ProgramViewModel.swift   # Template management
│   ├── WorkoutLogViewModel.swift # Workout logging
│   └── ReportsViewModel.swift   # Reports and stats
│
├── Services/
│   ├── FirebaseService.swift    # Firebase initialization
│   ├── AuthManager.swift        # Authentication
│   ├── FirestoreManager.swift   # Database operations
│   └── NotificationManager.swift # Push notifications
│
├── Views/
│   ├── Auth/                    # Login/signup
│   ├── Home/                    # Dashboard
│   ├── Templates/               # Program management
│   ├── Logs/                    # Workout history
│   └── Reports/                 # Charts and export
│
├── Components/                  # Reusable UI components
└── Utilities/                   # Extensions and helpers
```

## Usage

### Creating a Program

1. Go to the "Programs" tab
2. Tap "+" to create a new program
3. Add workout days (e.g., "Arm Day", "Leg Day")
4. Add exercises to each day with sets, reps, and target weight

### Logging a Workout

1. Go to "Home" tab and tap "Start Workout"
2. Select a program and day, or start a quick workout
3. Log your actual reps and weight for each set
4. Tap the checkmark to complete each set
5. Finish workout to save and check for PRs

### Viewing Reports

1. Go to "Reports" tab
2. View weekly volume trends
3. Check personal records
4. Export data as PDF or CSV

## License

MIT License - feel free to use and modify for your own projects.
