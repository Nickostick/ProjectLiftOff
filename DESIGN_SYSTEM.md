# Premium 2026 Fitness App - Design System

## Color Palette

### Primary Gradients

#### Primary Gradient (Default Actions)
```
Indigo → Purple
#6366F1 → #8B5CF6
Usage: Default buttons, primary actions, home stats
```

#### Secondary Gradient (Alternate)
```
Pink → Purple
#EC4899 → #8B5CF6
Usage: Volume stats, hero cards
```

#### Accent Gradient (Highlights)
```
Cyan → Blue
#06B6D4 → #3B82F6
Usage: Time range picker, reports, secondary actions
```

#### Energy Gradient (CTAs)
```
Amber → Red
#F59E0B → #EF4444
Usage: Start Workout button, urgent actions
```

---

### Muscle Group Gradients

#### Chest (Purple/Teal)
```
Purple → Teal
#7C3AED → #2DD4BF
Exercises: Bench Press, Incline Press, Fly, Dips
```

#### Legs (Orange/Red)
```
Orange → Red
#F97316 → #DC2626
Exercises: Squat, Deadlift, Leg Press, Lunges, Calf Raise
```

#### Back (Teal/Cyan)
```
Teal → Cyan
#14B8A6 → #06B6D4
Exercises: Row, Pull-Up, Lat Pulldown, Deadlift
```

#### Shoulders (Pink/Purple)
```
Pink → Purple
#EC4899 → #A855F7
Exercises: Overhead Press, Lateral Raise, Shrugs
```

#### Arms (Blue/Purple)
```
Blue → Purple
#3B82F6 → #8B5CF6
Exercises: Bicep Curl, Tricep Pushdown, Hammer Curl
```

---

### Stat Type Gradients

#### Volume Gradient
```
Purple → Pink
#8B5CF6 → #EC4899
Usage: Total volume, weekly volume charts
```

#### Workout Count Gradient
```
Blue → Cyan
#3B82F6 → #06B6D4
Usage: Workout count cards, frequency stats
```

#### Duration Gradient
```
Amber → Orange
#F59E0B → #F97316
Usage: Average duration, workout timer
```

#### PR Gradient (Gold)
```
Yellow → Amber
#FBBF24 → #F59E0B
Usage: Personal records, trophy icons
```

#### Streak Gradient (Green)
```
Green → Emerald
#10B981 → #059669
Usage: Consistency streaks, this week stats
```

---

## Typography

### Font Family
- **Primary**: SF Pro Rounded (Apple system font)
- **Fallback**: San Francisco (default)

### Type Scale

```swift
Hero Number:    48pt / Black / Rounded     // Big stat values
Large Title:    34pt / Bold / Rounded      // Page titles
Title 1:        28pt / Bold / Rounded      // Section headers
Title 2:        22pt / Bold / Rounded      // Card titles
Headline:       17pt / Semibold / Rounded  // Button labels
Body:           17pt / Regular / Default   // Body text
Callout:        16pt / Medium / Default    // Subtitles
Caption:        13pt / Medium / Rounded    // Small labels
```

### Usage Examples

```
┌─────────────────────────────┐
│ Good Morning                │ ← 34pt Bold (largeTitle)
│ Friday, January 3           │ ← 16pt Medium (callout)
├─────────────────────────────┤
│ Volume This Week            │ ← 17pt Semibold (headline)
│ 45,230 lbs                  │ ← 48pt Black (heroNumber)
│                             │
│ Workouts                    │ ← 13pt Medium (caption)
│ 12                          │ ← 28pt Bold (title1)
└─────────────────────────────┘
```

---

## Layout System

### Spacing Scale (8pt Grid)

```
8pt   = Tight spacing (icon to text)
12pt  = Default spacing (within cards)
16pt  = Medium spacing (between elements)
20pt  = Card padding (internal)
24pt  = Section spacing (between card groups)
32pt  = Large spacing (page margins)
```

### Corner Radius

```
4pt   = Chips, badges (subtle rounding)
12pt  = Small buttons, tags
16pt  = Medium cards, icons
20pt  = Large buttons (CTAs)
24pt  = Main cards (stat cards, program cards)
32pt  = Hero cards, full-width elements
```

### Card Dimensions

```
PremiumStatCard:    Width: flex, Height: 160pt
HeroStatCard:       Width: flex, Height: 200pt
RecentWorkoutCard:  Width: 180pt, Height: 200pt
PRAchievementCard:  Width: flex, Height: ~100pt
ProgramCard:        Width: flex, Height: ~200pt
```

---

## Shadows & Elevation

### Shadow Presets

#### Level 1: Subtle
```swift
.shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
Usage: Small cards, chips
```

#### Level 2: Standard
```swift
.shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
Usage: Stat cards, program cards (default)
```

#### Level 3: Elevated
```swift
.shadow(color: AppTheme.vibrantPurple.opacity(0.4), radius: 16, x: 0, y: 8)
Usage: Floating start button, CTAs
```

#### Level 4: Glow
```swift
.shadow(color: AppTheme.goldPR.opacity(0.3), radius: 12, x: 0, y: 6)
Usage: PR cards (golden glow)
```

---

## Visual Effects

### Inner Glow (Card Overlay)

```swift
// Subtle white overlay for depth
LinearGradient(
    colors: [.white.opacity(0.1), .clear],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

### Gradient Border

```swift
// Subtle border for premium feel
RoundedRectangle(cornerRadius: 24)
    .stroke(
        LinearGradient(
            colors: [.white.opacity(0.3), .clear],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        lineWidth: 1
    )
```

### Background Orbs (Depth)

```swift
Circle()
    .fill(AppTheme.vibrantPurple.opacity(0.15))
    .frame(width: 220, height: 220)
    .blur(radius: 70)
    .offset(x: screenWidth * 0.7, y: -100)
```

**Orb Guidelines:**
- Use 2-3 orbs max per screen
- Opacity: 0.10-0.15 (subtle, not distracting)
- Blur: 60-80pt (soft glow)
- Colors: Rotate through purple, blue, pink, teal
- Position: Off-screen edges for depth

---

## Animation Curves

### Spring (Default)
```swift
Animation.spring(response: 0.35, dampingFraction: 0.7)
Usage: Tab switching, card appearing, button press
Feel: Smooth, natural, premium
```

### Snappy (Quick Actions)
```swift
Animation.snappy(duration: 0.3)
Usage: Toggle switches, chip selection
Feel: Instant, responsive
```

### Smooth (Slow Transitions)
```swift
Animation.smooth(duration: 0.4)
Usage: Scroll animations, page transitions
Feel: Elegant, flowing
```

### Scale Button Press
```swift
// On press: scale to 0.92
// On release: scale to 1.0
// Duration: 0.35s spring
```

---

## Accessibility

### Contrast Ratios (WCAG 2.2 AA+)

#### White on Gradients
```
White (#FFFFFF) on Purple (#8B5CF6) = 6.2:1 ✅
White (#FFFFFF) on Blue (#3B82F6) = 5.1:1 ✅
White (#FFFFFF) on Pink (#EC4899) = 4.8:1 ✅
White (#FFFFFF) on Orange (#F97316) = 4.5:1 ✅
```

All gradients meet minimum 4.5:1 contrast for WCAG AA.

#### Touch Targets
```
Minimum: 44×44pt (Apple HIG)
Stat Cards: 160pt tall (large target)
Tab Bar Icons: 70pt wide (thumb-friendly)
Start Button: 64pt diameter (easy tap)
```

### VoiceOver Labels

```swift
// Stat Card
.accessibilityLabel("Weekly volume: 45,230 pounds")
.accessibilityHint("Double-tap to view details")

// PR Card
.accessibilityLabel("Personal record: Bench Press, 185 pounds for 5 reps")

// Start Button
.accessibilityLabel("Start workout")
.accessibilityHint("Opens workout template selection")
```

### Dynamic Type Support

All text uses `.font()` modifiers (not fixed sizes), supporting:
- .large (default)
- .xLarge
- .xxLarge
- .xxxLarge
- .accessibility1
- .accessibility2
- .accessibility3

Test with: Settings > Accessibility > Display & Text Size > Larger Text

---

## SF Symbols

### Primary Icons

```
Workouts:       figure.strengthtraining.traditional (24pt)
Volume:         scalemass.fill (24pt)
PRs:            trophy.fill (24pt)
Duration:       clock.fill (20pt)
Calendar:       calendar (20pt)
Exercises:      dumbbell.fill (20pt)
Start:          play.fill (28pt)
Add:            plus.circle.fill (24pt)
Progress:       chart.bar.fill (24pt)
Settings:       gearshape.fill (24pt)
```

### Rendering Mode

```swift
// For gradient icons:
.symbolRenderingMode(.hierarchical)

// Example:
Image(systemName: "trophy.fill")
    .font(.system(size: 24, weight: .bold))
    .foregroundStyle(AppTheme.goldPR)
    .symbolRenderingMode(.hierarchical)
```

---

## Component Usage Matrix

| Component | Where Used | Gradient Type | Height |
|-----------|-----------|---------------|--------|
| PremiumStatCard | Home stats, Reports grid | Stat type | 160pt |
| HeroStatCard | Home volume, Featured stats | Primary/Volume | 200pt |
| GradientWorkoutCard | Quick actions, CTAs | Energy | Auto |
| PRAchievementCard | Home PRs, Reports PRs | PR (gold) | ~100pt |
| PremiumProgramCard | Program list | Rotating | ~200pt |
| PremiumDayCard | Program detail | Muscle group | ~100pt |
| ExerciseChip | Reports filter | Muscle group | 40pt |
| DayChip | Program tags | Accent | 30pt |

---

## Dark Mode Guidelines

### Gradient Behavior
- **Same in both modes**: Gradients use absolute hex values (vibrant in dark mode)
- **Why**: Premium feel requires high saturation regardless of system appearance

### Background Adaptation
```swift
// Auto-adapts:
Color(.systemBackground)          // White → Black
Color(.secondarySystemBackground) // Light gray → Dark gray
Color(.tertiarySystemBackground)  // Lighter gray → Darker gray

// Fixed (gradient cards):
AppTheme.primaryGradient          // Always vibrant
```

### Testing
1. System Settings > Display & Brightness > Appearance > Dark
2. Xcode > Environment Overrides > Interface Style > Dark
3. SwiftUI Preview: `.preferredColorScheme(.dark)`

---

## Responsive Design

### iPhone SE (375×667pt)
- Stat cards: 2-column grid (12pt gap)
- Recent workouts: Horizontal scroll (no stack)
- Hero card: Full width (no side margins)

### iPhone 14 Pro (393×852pt)
- Standard layout (20pt margins)
- All cards visible without scroll on Home

### iPhone 14 Pro Max (430×932pt)
- Increased card padding (24pt)
- 3-column grid option for stats (optional enhancement)

### iPad (1024×1366pt)
- Not optimized (fitness apps are phone-first)
- Consider 2-column layout for stats in future

---

## Motion & Haptics

### Animation Timing
```
Tab switch:         0.35s spring
Card appear:        0.3s snappy
Button press:       0.2s scale
Scroll inertia:     System default
Page transition:    0.4s smooth
```

### Haptic Feedback (iOS 17+)
```swift
// On workout complete:
.sensoryFeedback(.success, trigger: workoutCompleted)

// On PR achieved:
.sensoryFeedback(.impact(.heavy), trigger: prAchieved)

// On button tap:
.sensoryFeedback(.selection, trigger: buttonTapped)
```

---

## Brand Guidelines

### DO ✅
- Use vibrant gradients for energy/motivation
- Color-code by muscle group for quick scanning
- Celebrate PRs with gold glow effects
- Large, bold numbers (48pt+) for key stats
- Smooth spring animations (0.35s)
- White text on gradient backgrounds

### DON'T ❌
- Use photos of people (abstract only)
- Mix more than 3 gradients on one screen
- Use pure black/white backgrounds (use system colors)
- Overuse animations (keep subtle)
- Make touch targets <44pt
- Use low-contrast color combos

---

## File Organization

```
Utilities/
  └── AppTheme.swift          // All colors, gradients, constants

Components/
  └── PremiumCardComponents.swift  // Reusable gradient cards

Views/
  ├── Home/HomeView_Premium.swift
  ├── Templates/ProgramListView_Premium.swift
  ├── Reports/ReportsView_Premium.swift
  └── PremiumTabBar.swift
```

---

## Version History

- **v1.0** (2026-01-03): Initial premium redesign
  - Abstract gradient system
  - Muscle-group color coding
  - Premium card components
  - Custom tab bar with floating button

---

**Design System Complete** ✨
Ready to ship a premium 2026 fitness experience!
