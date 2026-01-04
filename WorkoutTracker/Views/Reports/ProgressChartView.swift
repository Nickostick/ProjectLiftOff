import SwiftUI
import Charts

/// Chart view for exercise progress over time
struct ProgressChartView: View {
    let progress: ExerciseProgress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(progress.exerciseName)
                        .font(.headline)
                    
                    if progress.progressPercentage != 0 {
                        HStack(spacing: 4) {
                            Image(systemName: progress.progressPercentage > 0 ? "arrow.up.right" : "arrow.down.right")
                            Text(String(format: "%.1f%%", abs(progress.progressPercentage)))
                        }
                        .font(.caption)
                        .foregroundStyle(progress.progressPercentage > 0 ? .green : .red)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Max: \(Int(progress.maxWeight)) lbs")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Latest: \(Int(progress.latestWeight)) lbs")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            if progress.dataPoints.count > 1 {
                Chart(progress.dataPoints) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Weight", point.weight)
                    )
                    .foregroundStyle(Color.blue.gradient)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Weight", point.weight)
                    )
                    .foregroundStyle(Color.blue)
                    .symbolSize(30)
                    
                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Weight", point.weight)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .frame(height: 180)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 5)) { value in
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let weight = value.as(Double.self) {
                                Text("\(Int(weight))")
                            }
                        }
                    }
                }
            } else {
                Text("Need more data points to show chart")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(Constants.UI.cornerRadius)
    }
}

/// Chart for volume trends
struct VolumeChartView: View {
    let data: [WeeklyVolumePoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Volume Trend")
                .font(.headline)
            
            Chart(data) { point in
                AreaMark(
                    x: .value("Week", point.weekStart),
                    y: .value("Volume", point.volume)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.5), Color.purple.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                LineMark(
                    x: .value("Week", point.weekStart),
                    y: .value("Volume", point.volume)
                )
                .foregroundStyle(Color.purple)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            .frame(height: 150)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(Constants.UI.cornerRadius)
    }
}

#Preview {
    VStack {
        ProgressChartView(progress: ExerciseProgress(
            exerciseName: "Bench Press",
            dataPoints: [
                ProgressDataPoint(date: Date().addingTimeInterval(-86400 * 30), weight: 135, reps: 8, volume: 1080),
                ProgressDataPoint(date: Date().addingTimeInterval(-86400 * 23), weight: 145, reps: 8, volume: 1160),
                ProgressDataPoint(date: Date().addingTimeInterval(-86400 * 16), weight: 150, reps: 8, volume: 1200),
                ProgressDataPoint(date: Date().addingTimeInterval(-86400 * 9), weight: 155, reps: 6, volume: 930),
                ProgressDataPoint(date: Date().addingTimeInterval(-86400 * 2), weight: 160, reps: 8, volume: 1280)
            ]
        ))
    }
    .padding()
}
