import SwiftUI

// MARK: - Dark Theme Stat Card

struct PremiumStatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: LinearGradient
    var subtitle: String? = nil
    var showGlow: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)

            Spacer()

            // Value
            Text(value)
                .font(AppTheme.Typography.title1)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            // Title
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.textSecondary)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(AppTheme.textTertiary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.Layout.cardPadding)
        .frame(height: 140)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Layout.cardCornerRadius)
                .fill(AppTheme.cardBackground)
        )
    }
}

// MARK: - Large Hero Stat Card

struct HeroStatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: LinearGradient
    var trend: String? = nil
    var trendUp: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)

                Spacer()

                // Trend indicator
                if let trend = trend {
                    HStack(spacing: 4) {
                        Image(systemName: trendUp ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 12, weight: .medium))
                        Text(trend)
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(AppTheme.neonGreen)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(AppTheme.neonGreen.opacity(0.15))
                    )
                }
            }

            Spacer()

            // Value
            Text(value)
                .font(AppTheme.Typography.heroNumber)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            // Title
            Text(title)
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .frame(height: 180)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Layout.cardCornerRadius)
                .fill(AppTheme.cardBackground)
        )
    }
}

// MARK: - Dark Workout Card

struct GradientWorkoutCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: LinearGradient
    var badge: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(AppTheme.neonGreen)
                    .frame(width: 50, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppTheme.neonGreen.opacity(0.15))
                    )

                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                // Badge or chevron
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(AppTheme.cardBackgroundSecondary)
                        )
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.textTertiary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Layout.cardCornerRadius)
                    .fill(AppTheme.cardBackground)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - PR Achievement Card

struct PRAchievementCard: View {
    let exerciseName: String
    let record: String
    let achievedAt: String
    let estimated1RM: String
    let gradient: LinearGradient

    var body: some View {
        HStack(spacing: 16) {
            // Trophy icon
            ZStack {
                Circle()
                    .fill(AppTheme.neonGreen.opacity(0.15))
                    .frame(width: 50, height: 50)

                Image(systemName: "trophy.fill")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(AppTheme.neonGreen)
            }

            // Exercise info
            VStack(alignment: .leading, spacing: 6) {
                Text(exerciseName)
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(achievedAt)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            // Record value
            VStack(alignment: .trailing, spacing: 4) {
                Text(record)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.neonGreen)

                Text("1RM: \(estimated1RM)")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Layout.cardCornerRadius)
                .fill(AppTheme.cardBackground)
        )
    }
}

// MARK: - Program Card

struct PremiumProgramCard: View {
    let program: Program
    var gradient: LinearGradient = AppTheme.primaryGradient

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text(program.name)
                    .font(AppTheme.Typography.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(2)

                Spacer()

                // Day count badge
                Text("\(program.days.count)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(AppTheme.cardBackgroundSecondary)
                    )
            }

            // Description
            if !program.description.isEmpty {
                Text(program.description)
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(2)
            }

            // Day tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(program.days.prefix(4)) { day in
                        Text(day.name)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(AppTheme.cardBackgroundSecondary)
                            )
                    }

                    if program.days.count > 4 {
                        Text("+\(program.days.count - 4)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AppTheme.textTertiary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(AppTheme.cardBackgroundSecondary.opacity(0.5))
                            )
                    }
                }
            }

            // Stats footer
            HStack(spacing: 16) {
                Label("\(program.days.count) days", systemImage: "calendar")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(AppTheme.textSecondary)

                let totalExercises = program.days.reduce(0) { $0 + $1.exercises.count }
                Label("\(totalExercises) exercises", systemImage: "dumbbell.fill")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Layout.cardCornerRadius)
                .fill(AppTheme.cardBackground)
        )
    }
}

// MARK: - Day Card

struct PremiumDayCard: View {
    let day: WorkoutDay

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(day.name)
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)

                Spacer()

                // Exercise count badge
                Text("\(day.exercises.count)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(AppTheme.cardBackgroundSecondary)
                    )
            }

            // Exercise preview
            if !day.exercises.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(day.exercises.prefix(3)) { exercise in
                            Text(exercise.name)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(AppTheme.textSecondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(AppTheme.cardBackgroundSecondary)
                                )
                        }

                        if day.exercises.count > 3 {
                            Text("+\(day.exercises.count - 3)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(AppTheme.textTertiary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(AppTheme.cardBackgroundSecondary.opacity(0.5))
                                )
                        }
                    }
                }
            } else {
                Text("No exercises")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(AppTheme.textTertiary)
            }

            // Stats
            HStack(spacing: 12) {
                Label("\(day.exercises.count) exercises", systemImage: "dumbbell.fill")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Layout.cardCornerRadius)
                .fill(AppTheme.cardBackground)
        )
    }
}

// MARK: - Day Tag Chip

struct DayChip: View {
    let name: String
    let gradient: LinearGradient
    var isCompact: Bool = false

    var body: some View {
        Text(name)
            .font(.system(size: isCompact ? 11 : 12, weight: .medium))
            .foregroundStyle(AppTheme.textPrimary)
            .padding(.horizontal, isCompact ? 10 : 14)
            .padding(.vertical, isCompact ? 5 : 8)
            .background(
                Capsule()
                    .fill(AppTheme.cardBackgroundSecondary)
            )
    }
}

// MARK: - Exercise Progress Chip

struct ExerciseChip: View {
    let name: String
    let isSelected: Bool
    let gradient: LinearGradient

    var body: some View {
        Text(name)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(isSelected ? AppTheme.darkBackground : AppTheme.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? AppTheme.neonGreen : AppTheme.cardBackground)
            )
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? Color.clear : AppTheme.cardBackgroundSecondary,
                        lineWidth: 1
                    )
            )
    }
}

// MARK: - Glowing CTA Button

struct GlowingCTAButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: LinearGradient
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(AppTheme.neonGreen.opacity(0.2))
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(AppTheme.darkBackground)
                }

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.darkBackground)

                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(AppTheme.darkBackground.opacity(0.8))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppTheme.darkBackground)
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Layout.cardCornerRadius)
                    .fill(AppTheme.neonGreen)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Stat Cards") {
    ZStack {
        AppTheme.darkBackground.ignoresSafeArea()

        VStack(spacing: 16) {
            HStack(spacing: 12) {
                PremiumStatCard(
                    title: "Workouts",
                    value: "12",
                    icon: "figure.strengthtraining.traditional",
                    gradient: AppTheme.workoutCountGradient,
                    subtitle: "This week"
                )

                PremiumStatCard(
                    title: "PRs",
                    value: "8",
                    icon: "trophy.fill",
                    gradient: AppTheme.prGradient
                )
            }

            HeroStatCard(
                title: "Volume This Week",
                value: "45,230 lbs",
                icon: "scalemass.fill",
                gradient: AppTheme.volumeGradient,
                trend: "+12%",
                trendUp: true
            )
        }
        .padding()
    }
}
