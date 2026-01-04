import Foundation
import PDFKit
import UIKit

/// Manages PDF and CSV export of workout data
final class ExportManager {
    
    // MARK: - Singleton
    static let shared = ExportManager()
    
    private init() {}
    
    // MARK: - CSV Export
    
    /// Export workout logs to CSV format
    func exportLogsToCSV(_ logs: [WorkoutLog]) -> URL? {
        var csvContent = "Date,Program,Day,Exercise,Sets,Reps,Weight,Volume,Duration,Notes\n"
        
        for log in logs {
            let date = log.startedAt.formattedShort
            let duration = log.formattedDuration
            
            for exercise in log.exercises {
                for set in exercise.completedSets where set.isCompleted {
                    let row = [
                        date,
                        log.programName.escapedForCSV,
                        log.dayName.escapedForCSV,
                        exercise.name.escapedForCSV,
                        "\(set.setNumber)",
                        "\(set.actualReps)",
                        "\(set.weight)",
                        "\(set.volume)",
                        duration,
                        exercise.notes.escapedForCSV
                    ].joined(separator: ",")
                    
                    csvContent += row + "\n"
                }
            }
        }
        
        return saveToFile(content: csvContent, filename: "workout_log_export.csv")
    }
    
    /// Export personal records to CSV
    func exportPRsToCSV(_ records: [PersonalRecord]) -> URL? {
        var csvContent = "Exercise,Weight,Reps,Date,Estimated 1RM\n"
        
        for record in records {
            let row = [
                record.exerciseName.escapedForCSV,
                "\(record.weight)",
                "\(record.reps)",
                record.achievedAt.formattedShort,
                String(format: "%.1f", record.estimated1RM)
            ].joined(separator: ",")
            
            csvContent += row + "\n"
        }
        
        return saveToFile(content: csvContent, filename: "personal_records_export.csv")
    }
    
    // MARK: - PDF Export
    
    /// Export workout summary to PDF
    func exportSummaryToPDF(
        logs: [WorkoutLog],
        records: [PersonalRecord],
        totalVolume: Double,
        workoutCount: Int
    ) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Workout Tracker",
            kCGPDFContextAuthor: "Workout Tracker App",
            kCGPDFContextTitle: "Workout Summary Report"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = margin
            let contentWidth = pageWidth - (margin * 2)
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.label
            ]
            
            let title = "Workout Summary Report"
            title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: titleAttributes)
            yPosition += 40
            
            // Date
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.secondaryLabel
            ]
            
            let dateString = "Generated: \(Date().formattedWithTime)"
            dateString.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: dateAttributes)
            yPosition += 30
            
            // Summary stats
            let statsAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.label
            ]
            
            let stats = [
                "Total Workouts: \(workoutCount)",
                "Total Volume: \(totalVolume.formattedVolume) lbs",
                "Personal Records: \(records.count)"
            ]
            
            for stat in stats {
                stat.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: statsAttributes)
                yPosition += 20
            }
            
            yPosition += 20
            
            // Recent Workouts Section
            let sectionAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                .foregroundColor: UIColor.label
            ]
            
            "Recent Workouts".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 30
            
            let itemAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.label
            ]
            
            for log in logs.prefix(10) {
                // Check if we need a new page
                if yPosition > pageHeight - margin - 50 {
                    context.beginPage()
                    yPosition = margin
                }
                
                let logString = "• \(log.startedAt.formattedShort) - \(log.dayName): \(log.exercises.count) exercises, \(log.totalVolume.formattedVolume) lbs"
                logString.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: itemAttributes)
                yPosition += 20
            }
            
            yPosition += 30
            
            // Check for new page before PRs
            if yPosition > pageHeight - margin - 100 {
                context.beginPage()
                yPosition = margin
            }
            
            // Personal Records Section
            "Personal Records".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 30
            
            for record in records.prefix(15) {
                if yPosition > pageHeight - margin - 30 {
                    context.beginPage()
                    yPosition = margin
                }
                
                let recordString = "• \(record.exerciseName): \(record.formattedRecord) (Est. 1RM: \(String(format: "%.0f", record.estimated1RM)) lbs)"
                recordString.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: itemAttributes)
                yPosition += 20
            }
        }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("workout_summary.pdf")
        
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("❌ Failed to save PDF: \(error)")
            return nil
        }
    }
    
    // MARK: - Helper Methods
    
    private func saveToFile(content: String, filename: String) -> URL? {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        do {
            try content.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            print("❌ Failed to save file: \(error)")
            return nil
        }
    }
}

// MARK: - String Extension for CSV
private extension String {
    var escapedForCSV: String {
        if contains(",") || contains("\"") || contains("\n") {
            return "\"\(replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return self
    }
}
