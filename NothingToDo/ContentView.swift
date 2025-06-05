import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var languageManager: LanguageManager
    @State private(set) var currentStreak: Int = 0
    @State private(set) var longestStreak: Int = 0
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var newNote = ""
    @State private var showingAchievement = false
    @State private var achievementTitle = ""
    @State private var timeRemaining: String = ""
    @State private var timer: Timer? = nil
    @State private var showingSettings = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Countdown Timer Display
                        Text(String(format: "Next mark available in: %@".localized, timeRemaining))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .padding(.top, 10)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        // Motivational Quote
                        Text(dailyQuote)
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemGray6))
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            )
                            .padding(.horizontal)
                        
                        // Streak Cards with Achievement Badges
                        HStack(spacing: 15) {
                            // Current Streak Card
                            VStack {
                                ZStack {
                                    Text("\(currentStreak)")
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    
                                    // Achievement Badge
                                    if currentStreak >= 7 {
                                        Image(systemName: "star.circle.fill")
                                            .font(.title)
                                            .foregroundColor(.yellow)
                                            .offset(x: 30, y: -30)
                                    }
                                }
                                
                                Text("Current Streak".localized)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text(streakMotivation)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 5)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemGray6))
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            )
                            
                            // Longest Streak Card
                            VStack {
                                ZStack {
                                    Text("\(longestStreak)")
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    
                                    // Record Badge
                                    if longestStreak >= 30 {
                                        Image(systemName: "crown.fill")
                                            .font(.title)
                                            .foregroundColor(.yellow)
                                            .offset(x: 30, y: -30)
                                    }
                                }
                                
                                Text("Longest Streak".localized)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("Personal Best!".localized)
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 5)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemGray6))
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            )
                        }
                        .padding(.horizontal)
                        
                        // Mark Today Section
                        VStack(spacing: 15) {
                            // Mark Today Button
                            Button {
                                Task {
                                    await markToday()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: canMarkToday ? "checkmark.circle.fill" : "checkmark.circle")
                                        .font(.title2)
                                    Text(todayStatus.localized)
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(canMarkToday ? Color.blue : Color.gray)
                                        .shadow(color: canMarkToday ? Color.blue.opacity(0.3) : Color.gray.opacity(0.3), radius: 10, x: 0, y: 5)
                                )
                            }
                            .disabled(!canMarkToday)
                            
                            // Note Input Field (only shown when canMarkToday)
                            if canMarkToday {
                                TextField("Add a note for today (optional)".localized, text: $newNote)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                    )
                            }
                        }
                        .padding(.horizontal)
                        .animation(.spring(), value: canMarkToday)
                        
                        // History Navigation Link
                        NavigationLink(destination: HistoryView()) {
                            HStack {
                                Text("View History".localized)
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(.systemGray6))
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Nothing To Do".localized)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .alert("Error".localized, isPresented: $showError) {
                Button("OK".localized, role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .alert("Achievement Unlocked! 🎉".localized, isPresented: $showingAchievement) {
                Button("Nice!".localized, role: .cancel) {}
            } message: {
                Text(achievementTitle)
            }
            .onAppear {
                calculateStreaks()
                startTimer()
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
            }
        }
        .id(languageManager.refreshToggle)
        .environment(\.locale, languageManager.locale)
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            withAnimation {
                // Force view refresh by toggling a state property
                let temp = currentStreak
                currentStreak = temp
            }
        }
    }
    
    // MARK: - Other functions remain unchanged
    
    private var dailyQuote: String {
        let quotes = [
            "Doing nothing is an art, and you're mastering it! 🎨".localized,
            "Sometimes the best thing to do is nothing at all ✨".localized,
            "Empty time is not empty life - it's pure freedom 🦋".localized,
            "Today's achievement: Simply being 🌟".localized,
            "Embrace the beauty of doing nothing 🌺".localized
        ]
        return quotes[Calendar.current.component(.day, from: Date()) % quotes.count]
    }
    
    private var streakMotivation: String {
        if currentStreak == 0 {
            return "Start your journey!".localized
        } else if currentStreak < 3 {
            return "Great start!".localized
        } else if currentStreak < 7 {
            return "You're on fire! 🔥".localized
        } else if currentStreak < 14 {
            return "Incredible week! ⭐️".localized
        } else if currentStreak < 30 {
            return "Unstoppable! 🚀".localized
        } else {
            return "Legendary! 👑".localized
        }
    }
    
    private var canMarkToday: Bool {
        guard let lastEntry = items.first?.timestamp else { return true }
        return !Calendar.current.isDateInToday(lastEntry)
    }
    
    private var todayStatus: String {
        if canMarkToday {
            return "Mark Today as Done Nothing"
        } else {
            return "Already Marked Today"
        }
    }
    
    private func checkAchievements() {
        if currentStreak == 7 {
            achievementTitle = "7 Day Streak! You're becoming a master of doing nothing! 🌟"
            showingAchievement = true
        } else if currentStreak == 30 {
            achievementTitle = "30 Day Streak! You're a legendary nothing-doer! 👑"
            showingAchievement = true
        } else if currentStreak == longestStreak && currentStreak > 7 {
            achievementTitle = "New Personal Best! Keep going! 🎯"
            showingAchievement = true
        }
    }
    
    private func markToday() async {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.note = newNote.isEmpty ? nil : newNote
            
            do {
                try viewContext.save()
                calculateStreaks()
                checkAchievements()
                newNote = "" // Reset note field
            } catch {
                showError = true
                errorMessage = "Failed to save: \(error.localizedDescription)"
                handleCoreDataError(error)
            }
        }
    }
    
    private func handleCoreDataError(_ error: Error) {
        #if DEBUG
        print("CoreData error: \(error.localizedDescription)")
        if let nsError = error as NSError? {
            print("Debug error details: \(nsError), \(nsError.userInfo)")
        }
        #endif
    }
    
    func calculateStreaks() {
        var current = 0
        var longest = 0
        var previousDate: Date?
        let calendar = Calendar.current
        
        guard let firstEntry = items.first?.timestamp else {
            currentStreak = 0
            longestStreak = 0
            return
        }
        
        if !calendar.isDateInToday(firstEntry) && 
           !calendar.isDateInYesterday(firstEntry) {
            currentStreak = 0
        } else {
            current = 1
            previousDate = firstEntry
            
            for item in items.dropFirst() {
                guard let date = item.timestamp else { continue }
                
                if let previous = previousDate {
                    let dayDifference = calendar.dateComponents([.day], from: date, to: previous).day ?? 0
                    
                    if dayDifference == 1 {
                        current += 1
                    } else {
                        break
                    }
                }
                previousDate = date
            }
            currentStreak = current
        }
        
        var tempStreak = 1
        previousDate = nil
        
        for item in items {
            guard let date = item.timestamp else { continue }
            
            if let previous = previousDate {
                let dayDifference = calendar.dateComponents([.day], from: date, to: previous).day ?? 0
                
                if dayDifference == 1 {
                    tempStreak += 1
                    longest = max(longest, tempStreak)
                } else {
                    tempStreak = 1
                }
            }
            previousDate = date
        }
        
        longestStreak = max(longest, currentStreak)
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
                calculateStreaks()
            } catch {
                handleCoreDataError(error)
            }
        }
    }
    
    // MARK: - Timer Functions
    
    private func startTimer() {
        updateTimeRemaining()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            updateTimeRemaining()
        }
    }
    
    private func updateTimeRemaining() {
        let calendar = Calendar.current
        let now = Date()
        guard let nextMidnight = calendar.nextDate(after: now,
                                             matching: DateComponents(hour: 0, minute: 0, second: 0),
                                             matchingPolicy: .nextTime) else {
            timeRemaining = "Unknown"
            return
        }
        
        let diff = calendar.dateComponents([.hour, .minute, .second], from: now, to: nextMidnight)
        let h = diff.hour ?? 0
        let m = diff.minute ?? 0
        let s = diff.second ?? 0
        timeRemaining = String(format: "%02dh %02dm %02ds", h, m, s)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    formatter.doesRelativeDateFormatting = true
    return formatter
}()
