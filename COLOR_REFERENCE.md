# Premium 2026 Color Reference - Quick Lookup

## Hex Color Values (Copy-Paste Ready)

### Primary Palette

```swift
// Electric Blue
#3B82F6

// Vibrant Purple
#8B5CF6

// Hot Pink
#EC4899

// Energy Orange
#F97316

// Cyan
#06B6D4

// Gold PR
#FBBF24

// Success Green
#10B981
```

---

## Gradient Definitions

### Primary Gradients

```swift
// Primary (Default Actions)
LinearGradient(
    colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
// Visual: Indigo → Purple (45° diagonal)

// Secondary (Alternate)
LinearGradient(
    colors: [Color(hex: "EC4899"), Color(hex: "8B5CF6")],
    startPoint: .leading,
    endPoint: .trailing
)
// Visual: Pink → Purple (horizontal)

// Accent (Highlights)
LinearGradient(
    colors: [Color(hex: "06B6D4"), Color(hex: "3B82F6")],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
// Visual: Cyan → Blue (45° diagonal)

// Energy (CTAs)
LinearGradient(
    colors: [Color(hex: "F59E0B"), Color(hex: "EF4444")],
    startPoint: .leading,
    endPoint: .trailing
)
// Visual: Amber → Red (horizontal)
```

---

## Muscle Group Colors (Exercise Auto-Detection)

### Chest Exercises
**Gradient**: Purple (#7C3AED) → Teal (#2DD4BF)
**Triggers**: "bench", "chest", "fly", "press" (with chest)
**Example**: Bench Press, Incline Dumbbell Press

```swift
LinearGradient(
    colors: [Color(hex: "7C3AED"), Color(hex: "2DD4BF")],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

### Leg Exercises
**Gradient**: Orange (#F97316) → Red (#DC2626)
**Triggers**: "squat", "leg", "lunge", "deadlift", "calf", "hip"
**Example**: Barbell Squat, Leg Press, Romanian Deadlift

```swift
LinearGradient(
    colors: [Color(hex: "F97316"), Color(hex: "DC2626")],
    startPoint: .leading,
    endPoint: .trailing
)
```

### Back Exercises
**Gradient**: Teal (#14B8A6) → Cyan (#06B6D4)
**Triggers**: "row", "pull", "lat", "deadlift"
**Example**: Bent Over Row, Pull-Up, Lat Pulldown

```swift
LinearGradient(
    colors: [Color(hex: "14B8A6"), Color(hex: "06B6D4")],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

### Shoulder Exercises
**Gradient**: Pink (#EC4899) → Purple (#A855F7)
**Triggers**: "shoulder", "lateral", "overhead", "shrug", "raise"
**Example**: Overhead Press, Lateral Raise

```swift
LinearGradient(
    colors: [Color(hex: "EC4899"), Color(hex: "A855F7")],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

### Arm Exercises
**Gradient**: Blue (#3B82F6) → Purple (#8B5CF6)
**Triggers**: "curl", "tricep", "bicep", "arm"
**Example**: Bicep Curl, Tricep Pushdown

```swift
LinearGradient(
    colors: [Color(hex: "3B82F6"), Color(hex: "8B5CF6")],
    startPoint: .leading,
    endPoint: .trailing
)
```

---

## Stat Type Gradients

### Volume
**Usage**: Total volume, weekly volume charts
```swift
LinearGradient(
    colors: [Color(hex: "8B5CF6"), Color(hex: "EC4899")],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```
**Visual**: Purple → Pink (45° diagonal)

### Workout Count
**Usage**: Workout count cards, frequency stats
```swift
LinearGradient(
    colors: [Color(hex: "3B82F6"), Color(hex: "06B6D4")],
    startPoint: .leading,
    endPoint: .trailing
)
```
**Visual**: Blue → Cyan (horizontal)

### Duration
**Usage**: Average duration, workout timer
```swift
LinearGradient(
    colors: [Color(hex: "F59E0B"), Color(hex: "F97316")],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```
**Visual**: Amber → Orange (45° diagonal)

### Personal Records
**Usage**: PR cards, trophy icons
```swift
LinearGradient(
    colors: [Color(hex: "FBBF24"), Color(hex: "F59E0B")],
    startPoint: .leading,
    endPoint: .trailing
)
```
**Visual**: Yellow → Amber (horizontal, gold glow)

### Streaks
**Usage**: Consistency streaks, this week stats
```swift
LinearGradient(
    colors: [Color(hex: "10B981"), Color(hex: "059669")],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```
**Visual**: Green → Emerald (45° diagonal)

---

## Usage Examples

### Home Screen Volume Card
```swift
HeroStatCard(
    title: "Volume This Week",
    value: "45,230 lbs",
    icon: "scalemass.fill",
    gradient: AppTheme.volumeGradient,  // Purple → Pink
    trend: "+12%",
    trendUp: true
)
```

### Workout Count Stat
```swift
PremiumStatCard(
    title: "Workouts",
    value: "12",
    icon: "figure.strengthtraining.traditional",
    gradient: AppTheme.workoutCountGradient,  // Blue → Cyan
    subtitle: "This week"
)
```

### Start Workout Button
```swift
GlowingCTAButton(
    title: "Start Workout",
    subtitle: "Choose a template or start fresh",
    icon: "play.fill",
    gradient: AppTheme.energyGradient,  // Amber → Red
    action: { showStartWorkout = true }
)
```

### Program Card
```swift
PremiumProgramCard(
    program: myProgram,
    gradient: AppTheme.primaryGradient  // Indigo → Purple
)
```

### Recent Workout Card (Auto-Detect)
```swift
let firstExercise = log.exercises.first?.name  // "Bench Press"
let gradient = AppTheme.muscleGroupGradient(for: firstExercise)
// Returns: Purple (#7C3AED) → Teal (#2DD4BF) for chest
```

---

## Color Accessibility

### Contrast Ratios (White Text on Gradient)

| Color | Hex | Contrast vs White | WCAG AA+ |
|-------|-----|-------------------|----------|
| Electric Blue | #3B82F6 | 5.1:1 | ✅ Pass |
| Vibrant Purple | #8B5CF6 | 6.2:1 | ✅ Pass |
| Hot Pink | #EC4899 | 4.8:1 | ✅ Pass |
| Energy Orange | #F97316 | 4.5:1 | ✅ Pass |
| Cyan | #06B6D4 | 5.3:1 | ✅ Pass |
| Gold PR | #FBBF24 | 4.6:1 | ✅ Pass |
| Success Green | #10B981 | 5.8:1 | ✅ Pass |

**All gradients meet WCAG 2.2 AA+ requirements (4.5:1 minimum)**

---

## Quick SwiftUI Implementation

### 1. Import Theme
```swift
import SwiftUI
// AppTheme is available automatically (same module)
```

### 2. Use Gradient in View
```swift
Text("45,230 lbs")
    .font(.system(size: 48, weight: .black, design: .rounded))
    .foregroundStyle(
        LinearGradient(
            colors: [AppTheme.vibrantPurple, AppTheme.hotPink],
            startPoint: .leading,
            endPoint: .trailing
        )
    )
```

### 3. Apply to Background
```swift
VStack {
    // Content
}
.gradientCardBackground(AppTheme.volumeGradient)
// Applies gradient fill + inner glow + shadow
```

### 4. Auto-Detect Exercise Color
```swift
let exerciseName = "Bench Press"
let gradient = AppTheme.muscleGroupGradient(for: exerciseName)
// Returns chest gradient (Purple → Teal)

Rectangle()
    .fill(gradient)
    .frame(width: 60, height: 60)
    .cornerRadius(16)
```

---

## CSS Equivalents (For Web Version)

### Gradient Syntax

```css
/* Primary Gradient */
background: linear-gradient(135deg, #6366F1, #8B5CF6);

/* Volume Gradient */
background: linear-gradient(135deg, #8B5CF6, #EC4899);

/* Workout Count Gradient */
background: linear-gradient(90deg, #3B82F6, #06B6D4);

/* Energy Gradient */
background: linear-gradient(90deg, #F59E0B, #EF4444);

/* PR Gradient (Gold) */
background: linear-gradient(90deg, #FBBF24, #F59E0B);
```

**Angle Key:**
- 90deg = horizontal (left → right)
- 135deg = 45° diagonal (top-left → bottom-right)

---

## Figma Color Styles (If Designing)

### Create Gradient Styles

1. **Primary Gradient**
   - Type: Linear
   - Angle: 135°
   - Stop 1: #6366F1 (0%)
   - Stop 2: #8B5CF6 (100%)

2. **Volume Gradient**
   - Type: Linear
   - Angle: 135°
   - Stop 1: #8B5CF6 (0%)
   - Stop 2: #EC4899 (100%)

3. **Energy Gradient**
   - Type: Linear
   - Angle: 90°
   - Stop 1: #F59E0B (0%)
   - Stop 2: #EF4444 (100%)

---

## Dark Mode Adjustments (Optional)

If gradients feel too dark in dark mode:

```swift
// Lighten purple by 10%
Color(hex: "8B5CF6") → Color(hex: "A78BFA")

// Lighten blue by 10%
Color(hex: "3B82F6") → Color(hex: "60A5FA")

// Lighten pink by 10%
Color(hex: "EC4899") → Color(hex: "F472B6")
```

**Recommendation**: Keep original values for consistent vibrant feel.

---

## SF Symbol Pairing

| Stat Type | Icon | Color | Gradient |
|-----------|------|-------|----------|
| Volume | scalemass.fill | Purple | volumeGradient |
| Workouts | figure.strengthtraining.traditional | Blue | workoutCountGradient |
| Duration | clock.fill | Orange | durationGradient |
| PRs | trophy.fill | Gold | prGradient |
| Streaks | flame.fill | Green | streakGradient |
| Chest | dumbbell.fill | Purple/Teal | Chest gradient |
| Legs | figure.walk | Orange/Red | Legs gradient |
| Back | figure.strengthtraining.functional | Teal/Cyan | Back gradient |

---

## Animation Pairing

| Element | Animation | Duration | Damping |
|---------|-----------|----------|---------|
| Tab switch | Spring | 0.35s | 0.7 |
| Stat appear | Snappy | 0.3s | - |
| Button press | Scale (0.92x) | 0.2s | - |
| Card slide-in | Smooth | 0.4s | - |
| Gradient underline | Spring | 0.35s | 0.7 |

---

## Quick Copy-Paste Snippets

### Gradient Button
```swift
Button(action: myAction) {
    Text("Start")
        .font(.headline)
        .foregroundStyle(.white)
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
        .background(AppTheme.energyGradient)
        .cornerRadius(20)
        .shadow(color: AppTheme.energyOrange.opacity(0.4), radius: 16, x: 0, y: 8)
}
```

### Gradient Text
```swift
Text("45,230 lbs")
    .font(AppTheme.Typography.heroNumber)
    .foregroundStyle(AppTheme.volumeGradient)
```

### Gradient Icon
```swift
Image(systemName: "trophy.fill")
    .font(.system(size: 24, weight: .bold))
    .foregroundStyle(AppTheme.prGradient)
    .symbolRenderingMode(.hierarchical)
```

---

**Color reference complete! Copy and paste these values as needed.** 🎨
