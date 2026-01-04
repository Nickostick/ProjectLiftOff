import SwiftUI

/// Premium 2026 Custom TabBar with gradient selection indicators
struct PremiumTabBar: View {
    @Binding var selectedTab: MainTabView.Tab
    let onStartWorkout: () -> Void

    @Namespace private var animation

    var body: some View {
        HStack(spacing: 0) {
            // Home
            PremiumTabButton(
                icon: "house.fill",
                title: "Home",
                isSelected: selectedTab == .home,
                animation: animation
            ) {
                withAnimation(AppTheme.Animation.spring) {
                    selectedTab = .home
                }
            }

            Spacer()

            // Programs
            PremiumTabButton(
                icon: "doc.text.fill",
                title: "Programs",
                isSelected: selectedTab == .programs,
                animation: animation
            ) {
                withAnimation(AppTheme.Animation.spring) {
                    selectedTab = .programs
                }
            }

            Spacer()

            // Start Workout Button (Center)
            startWorkoutButton
                .offset(y: -20)

            Spacer()

            // Reports
            PremiumTabButton(
                icon: "chart.bar.fill",
                title: "Reports",
                isSelected: selectedTab == .reports,
                animation: animation
            ) {
                withAnimation(AppTheme.Animation.spring) {
                    selectedTab = .reports
                }
            }

            Spacer()

            // Settings
            PremiumTabButton(
                icon: "gearshape.fill",
                title: "Settings",
                isSelected: selectedTab == .settings,
                animation: animation
            ) {
                withAnimation(AppTheme.Animation.spring) {
                    selectedTab = .settings
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 2)
        .background(
            Rectangle()
                .fill(AppTheme.cardBackground)
                .ignoresSafeArea()
        )
    }

    // MARK: - Start Workout Button

    private var startWorkoutButton: some View {
        Button(action: onStartWorkout) {
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppTheme.neonGreen.opacity(0.3),
                                .clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 50
                        )
                    )
                    .frame(width: 80, height: 80)
                    .blur(radius: 8)

                // Solid circle
                Circle()
                    .fill(AppTheme.neonGreen)
                    .frame(width: 64, height: 64)
                    .shadow(color: AppTheme.neonGreen.opacity(0.4), radius: 16, x: 0, y: 8)

                // Plus icon
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(AppTheme.darkBackground)
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel("Start workout")
    }
}

// MARK: - Premium Tab Button

struct PremiumTabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let animation: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // Icon
                ZStack {
                    if isSelected {
                        // Glow background
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        AppTheme.neonGreen.opacity(0.3),
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 25
                                )
                            )
                            .frame(width: 50, height: 50)
                            .blur(radius: 4)
                    }

                    Image(systemName: icon)
                        .font(.system(size: 24, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? AppTheme.neonGreen : Color(.secondaryLabel))
                        .symbolRenderingMode(.hierarchical)
                }
                .frame(height: 32)

                // Label
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? AppTheme.neonGreen : Color(.secondaryLabel))

                // Selection indicator (underline)
                if isSelected {
                    Capsule()
                        .fill(AppTheme.neonGreen)
                        .frame(width: 32, height: 4)
                        .matchedGeometryEffect(id: "TAB_SELECTION", in: animation)
                } else {
                    Capsule()
                        .fill(Color.clear)
                        .frame(width: 32, height: 4)
                }
            }
            .frame(width: 70)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(AppTheme.Animation.spring, value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Spacer()

        PremiumTabBar(
            selectedTab: .constant(.home),
            onStartWorkout: {}
        )
    }
    .background(Color(.systemBackground))
}
