# ProjectLiftOff 🏋️

A native iOS workout tracking application built with SwiftUI and Firebase. ProjectLiftOff replaces traditional spreadsheet-based workout logging with an intuitive mobile experience designed for progressive overload training.

## What is ProjectLiftOff?

ProjectLiftOff is a comprehensive workout tracking app that helps you:

- **Create structured workout programs** - Define reusable templates with multiple workout days
- **Log workouts in real-time** - Track sets, reps, and weight with built-in rest timers
- **Track progressive overload** - Automatic personal record detection and historical tracking
- **Analyze your progress** - Visual charts showing volume, strength trends, and PRs over time
- **Train anywhere** - Cloud sync via Firebase ensures your data is available across devices

Built for lifters who want to move beyond spreadsheets while maintaining full control over their programming.

## Architecture

### Tech Stack

- **Frontend**: SwiftUI (iOS 17.0+)
- **Backend**: Firebase (Firestore + Authentication)
- **Language**: Swift
- **Minimum iOS**: 17.0
- **Authentication**: Apple Sign In + Email/Password

### Design Philosophy

**Dark-First UI**: Modern dark theme with neon green (#D4FF00) accents optimized for gym environments

**Offline-First**: Local caching with automatic sync when connectivity is restored

**Progressive Overload Focus**: Built specifically for strength training with emphasis on tracking weight progression

### Project Structure

```
WorkoutTracker/
├── Models/                    # Data models
│   ├── Program.swift          # Workout program template
│   ├── WorkoutDay.swift       # Training day within a program
│   ├── Exercise.swift         # Exercise definition with targets
│   ├── WorkoutLog.swift       # Completed workout record
│   └── PersonalRecord.swift   # PR tracking
│
├── ViewModels/                # Business logic & state management
│   ├── AuthViewModel.swift
│   ├── ProgramViewModel.swift
│   ├── WorkoutLogViewModel.swift
│   └── ReportsViewModel.swift
│
├── Views/                     # SwiftUI views
│   ├── Auth/                  # Authentication screens
│   ├── Home/                  # Dashboard
│   ├── Templates/             # Program management
│   ├── Logs/                  # Workout logging & history
│   └── Reports/               # Progress charts & analytics
│
├── Services/                  # External integrations
│   ├── FirebaseService.swift
│   ├── AuthManager.swift
│   ├── FirestoreManager.swift
│   └── NotificationManager.swift
│
├── Components/                # Reusable UI components
│   ├── PremiumCardComponents.swift
│   ├── ExerciseRowView.swift
│   └── SetRowView.swift
│
└── Utilities/                 # Helpers & extensions
    ├── AppTheme.swift         # Design system
    ├── ExportManager.swift    # PDF/CSV export
    └── Extensions.swift
```

### Data Model

```
User (Firebase Auth)
  └── Programs (Firestore Collection)
        ├── Program
        │    └── WorkoutDays[]
        │         └── Exercises[]
        │              ├── targetSets
        │              ├── targetReps
        │              └── targetWeight
        │
        ├── WorkoutLogs (Firestore Collection)
        │    ├── programId (reference)
        │    ├── dayId (reference)
        │    └── completedSets[]
        │         ├── actualReps
        │         └── actualWeight
        │
        └── PersonalRecords (Firestore Collection)
             ├── exerciseName
             ├── maxWeight
             └── estimatedOneRepMax
```

### Key Features

**Program Management**
- Create unlimited workout programs (e.g., "PPL", "5/3/1", "Hypertrophy Block")
- Organize programs into workout days (e.g., "Push Day A", "Pull Day B")
- Define target sets, reps, and weights for each exercise
- Copy, share, and delete programs with confirmation

**Active Workout Logging**
- Start workouts from templates or create quick workouts
- Check off sets in real-time with rest timers
- Automatically detect personal records
- Modify exercises and weights on the fly

**Progress Tracking**
- Visual charts showing weekly volume trends
- Exercise-specific progress graphs
- Personal record history with estimated 1RM calculations
- Export data to PDF or CSV

**Authentication**
- Apple Sign In (primary)
- Email/Password fallback
- Secure user data isolation via Firestore security rules

## Setup

### Prerequisites

- Xcode 15.0+
- iOS 17.0+ device or simulator
- Firebase account
- Apple Developer account (for TestFlight/App Store)

### Firebase Configuration

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Add an iOS app with bundle ID: `com.yourname.workouttracker`

2. **Download Configuration**
   - Download `GoogleService-Info.plist`
   - Add it to `WorkoutTracker/` directory in Xcode
   - **Never commit this file to version control**

3. **Enable Services**

   **Authentication:**
   - Enable Apple Sign In
   - Enable Email/Password

   **Firestore Database:**
   - Create database in your preferred region
   - Deploy security rules from `firestore.rules`:

   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       function isAuthenticated() {
         return request.auth != null;
       }

       match /programs/{programId} {
         allow read, write: if isAuthenticated() &&
                               resource.data.userId == request.auth.uid;
         allow create: if isAuthenticated() &&
                          request.resource.data.userId == request.auth.uid;
       }

       match /workoutLogs/{logId} {
         allow read, write: if isAuthenticated() &&
                               resource.data.userId == request.auth.uid;
         allow create: if isAuthenticated() &&
                          request.resource.data.userId == request.auth.uid;
       }

       match /personalRecords/{recordId} {
         allow read, write: if isAuthenticated() &&
                               resource.data.userId == request.auth.uid;
         allow create: if isAuthenticated() &&
                          request.resource.data.userId == request.auth.uid;
       }

       match /{document=**} {
         allow read, write: if false;
       }
     }
   }
   ```

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Nickostick/ProjectLiftOff.git
   cd ProjectLiftOff
   ```

2. **Add Firebase configuration**
   - Place your `GoogleService-Info.plist` in `WorkoutTracker/` directory

3. **Open in Xcode**
   ```bash
   open WorkoutTracker.xcodeproj
   ```

4. **Configure signing**
   - Select your development team in Signing & Capabilities
   - Update bundle identifier if needed

5. **Build and run**
   - Select a device or simulator
   - Press Cmd+R to build and run

## Usage

### Creating Your First Program

1. Navigate to **Programs** tab
2. Tap **+** to create a new program
3. Name it (e.g., "Push Pull Legs")
4. Add workout days:
   - Push Day: Bench, Overhead Press, Tricep Extensions
   - Pull Day: Deadlift, Rows, Bicep Curls
   - Leg Day: Squats, Leg Press, Leg Curls
5. For each exercise, set target sets, reps, and weight

### Logging a Workout

1. Go to **Home** tab
2. Tap **"Start Workout"**
3. Select a program and day (or create a quick workout)
4. For each set:
   - Enter actual reps and weight
   - Tap checkmark to complete
   - Rest timer starts automatically
5. Tap **"Finish Workout"** when done
6. Review any new personal records!

### Viewing Progress

1. Navigate to **Reports** tab
2. Select time range (1W, 1M, 3M, 1Y, ALL)
3. View:
   - Weekly volume trends
   - Exercise-specific progress
   - Personal records list
4. Export data as PDF or CSV

## Security

**This repository does NOT contain:**
- ❌ Firebase API keys
- ❌ Database credentials
- ❌ User data

**You must:**
- ✅ Create your own Firebase project
- ✅ Add your own `GoogleService-Info.plist`
- ✅ Deploy Firestore security rules
- ✅ Never commit credentials to version control

**Firestore security rules ensure:**
- Users can only read/write their own data
- All operations require authentication
- No cross-user data access

## Distribution

### TestFlight (Recommended for Personal Use)

- Upload builds via Xcode
- Builds expire after 90 days
- Free with Apple Developer account
- No App Store review required

### App Store

- Requires screenshots, description, and review
- One-time setup, no expiration
- Can be private (unlisted) or public

## Roadmap

Potential future enhancements:

- [ ] Exercise library with instructions and videos
- [ ] Workout templates marketplace
- [ ] Social features (share workouts, follow friends)
- [ ] Advanced analytics (periodization, deload recommendations)
- [ ] Apple Watch companion app
- [ ] HealthKit integration
- [ ] Custom exercise creation

## Contributing

This is a personal project, but feedback and suggestions are welcome! Feel free to:

- Open issues for bugs or feature requests
- Submit pull requests
- Fork and customize for your own needs

## License

MIT License - See LICENSE file for details

## Acknowledgments

Built with:
- [Firebase iOS SDK](https://firebase.google.com/docs/ios/setup)
- [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- Apple's Human Interface Guidelines

---

**Note**: This is a workout tracking app template. You must set up your own Firebase backend to use it. See [Setup](#setup) for instructions.
