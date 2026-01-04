import SwiftUI

/// Reusable stat card component for dashboard
struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var subtitle: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(Constants.UI.cornerRadius)
    }
}

/// Large stat card for important metrics
struct LargeStatCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var trend: String? = nil
    var trendUp: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                
                Spacer()
                
                if let trend = trend {
                    HStack(spacing: 4) {
                        Image(systemName: trendUp ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption)
                        Text(trend)
                            .font(.caption)
                    }
                    .foregroundStyle(trendUp ? .green : .red)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(
                colors: [color.opacity(0.15), color.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(Constants.UI.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 16) {
            StatCardView(
                title: "Workouts",
                value: "12",
                icon: "figure.strengthtraining.traditional",
                color: .blue,
                subtitle: "This month"
            )
            
            StatCardView(
                title: "Volume",
                value: "45,230 lbs",
                icon: "scalemass",
                color: .purple
            )
        }
        
        LargeStatCardView(
            title: "Total Volume This Week",
            value: "15,500 lbs",
            icon: "flame.fill",
            color: .orange,
            trend: "+12%",
            trendUp: true
        )
    }
    .padding()
}
