import CoreData
import Foundation

enum TestDataGenerator {
    static func generateOneMonthStreak(context: NSManagedObjectContext) {
        // Clear existing data
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Item")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try? context.execute(deleteRequest)
        
        // Generate dates for the last 30 days
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Sample notes to make it more realistic
        let sampleNotes = [
            "Perfectly did nothing today!",
            "Resisted the urge to be productive",
            "A masterclass in doing nothing",
            "Achievement unlocked: Zero tasks completed",
            "Pure relaxation day"
        ]
        
        // Create entries for the last 30 days
        for day in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -day, to: today) else { continue }
            
            let item = Item(context: context)
            item.timestamp = date
            
            // Add notes to some days (every 3-4 days)
            if day % 3 == 0 || day % 4 == 0 {
                item.note = sampleNotes[day % sampleNotes.count]
            }
        }
        
        // Save the context
        try? context.save()
    }
}
