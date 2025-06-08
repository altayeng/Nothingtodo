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
                // Modern gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color(.systemGray6).opacity(0.5)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Custom Header with Settings Button
                        HStack {
                            Text("Nothing to Do".localized)
                                .font(.system(.largeTitle, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button(action: {
                                showingSettings = true
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .overlay(
                                                Circle()
                                                    .stroke(.blue.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // Countdown Timer Display with modern design
                        VStack(spacing: 8) {
                            Text("Next mark available in".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(timeRemaining)
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                        .padding(.top, 10)
                        
                        // Motivational Quote with glassmorphism effect
                        Text(dailyQuote)
                            .font(.system(.title3, design: .rounded, weight: .medium))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(.linearGradient(
                                                colors: [.white.opacity(0.5), .clear],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 8)
                            )
                            .padding(.horizontal)
                        
                        // Modern Streak Cards with improved layout
                        VStack(spacing: 16) {
                            // Current Streak Card
                            VStack(spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Current Streak".localized)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        HStack(alignment: .bottom, spacing: 8) {
                                            Text("\(currentStreak)")
                                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                                .foregroundColor(.primary)
                                            
                                            Text("days")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .offset(y: -4)
                                        }
                                        
                                        Text(streakMotivation)
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                    
                                    Spacer()
                                    
                                    ZStack {
                                        Circle()
                                            .fill(.blue.opacity(0.1))
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: currentStreak >= 7 ? "star.fill" : "calendar")
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(.linearGradient(
                                                colors: [.blue.opacity(0.3), .clear],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ), lineWidth: 1)
                                    )
                                    .shadow(color: Color.blue.opacity(0.1), radius: 15, x: 0, y: 6)
                            )
                            
                            // Longest Streak Card
                            VStack(spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Longest Streak".localized)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        HStack(alignment: .bottom, spacing: 8) {
                                            Text("\(longestStreak)")
                                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                                .foregroundColor(.primary)
                                            
                                            Text("days")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .offset(y: -4)
                                        }
                                        
                                        Text("Personal Best!".localized)
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                    
                                    Spacer()
                                    
                                    ZStack {
                                        Circle()
                                            .fill(.orange.opacity(0.1))
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: longestStreak >= 30 ? "crown.fill" : "trophy")
                                            .font(.title2)
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(.linearGradient(
                                                colors: [.orange.opacity(0.3), .clear],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ), lineWidth: 1)
                                    )
                                    .shadow(color: Color.orange.opacity(0.1), radius: 15, x: 0, y: 6)
                            )
                        }
                        .padding(.horizontal)
                        
                        // Modern Mark Today Section
                        VStack(spacing: 16) {
                            // Mark Today Button with enhanced design
                            Button {
                                Task {
                                    await markToday()
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: canMarkToday ? "checkmark.circle.fill" : "checkmark.circle")
                                        .font(.title2)
                                        .foregroundColor(canMarkToday ? .white : .secondary)
                                    
                                    Text(todayStatus.localized)
                                        .font(.system(.title3, weight: .semibold))
                                        .foregroundColor(canMarkToday ? .white : .secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(canMarkToday ? 
                                            LinearGradient(
                                                gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ) : 
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color(.systemGray4), Color(.systemGray5)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(
                                            color: canMarkToday ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2), 
                                            radius: canMarkToday ? 15 : 8, 
                                            x: 0, 
                                            y: canMarkToday ? 6 : 3
                                        )
                                )
                                .scaleEffect(canMarkToday ? 1.0 : 0.98)
                            }
                            .disabled(!canMarkToday)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: canMarkToday)
                            
                            // Modern Note Input Field
                            if canMarkToday {
                                TextField("Add a note for today (optional)".localized, text: $newNote, axis: .vertical)
                                    .lineLimit(3...6)
                                    .font(.body)
                                    .padding(10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(.ultraThinMaterial)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color(.systemGray4), lineWidth: 1)
                                            )
                                    )
                                    .transition(.asymmetric(
                                        insertion: .scale.combined(with: .opacity).animation(.spring(response: 0.4)),
                                        removal: .scale.combined(with: .opacity).animation(.easeInOut(duration: 0.2))
                                    ))
                            }
                        }
                        .padding(.horizontal)
                        
                        // Modern History Navigation Link
                        NavigationLink(destination: HistoryView()) {
                            HStack(spacing: 16) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("View History".localized)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("See your progress over time")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color(.systemGray5), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationBarHidden(true)
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
        let now = Date()
        
        guard let firstEntry = items.first?.timestamp else {
            currentStreak = 0
            longestStreak = 0
            return
        }
        
        // Check if streak should be broken due to 26+ hour gap
        let hoursSinceLastEntry = Calendar.current.dateComponents([.hour], from: firstEntry, to: now).hour ?? 0
        
        // If last entry was today, continue current streak
        if calendar.isDateInToday(firstEntry) {
            current = 1
            previousDate = firstEntry
        }
        // If last entry was yesterday and within 26 hours, continue streak
        else if calendar.isDateInYesterday(firstEntry) && hoursSinceLastEntry < 26 {
            current = 1
            previousDate = firstEntry
        }
        // If more than 26 hours have passed, break the streak
        else {
            currentStreak = 0
            // Still calculate longest streak from history
            var tempStreak = 1
            previousDate = nil
            
            for item in items {
                guard let date = item.timestamp else { continue }
                
                if let previous = previousDate {
                    let dayDifference = calendar.dateComponents([.day], from: date, to: previous).day ?? 0
                    let hourDifference = calendar.dateComponents([.hour], from: date, to: previous).hour ?? 0
                    
                    // Check if entries are consecutive days and within 26 hours
                    if dayDifference == 1 && hourDifference < 26 {
                        tempStreak += 1
                        longest = max(longest, tempStreak)
                    } else {
                        tempStreak = 1
                    }
                }
                previousDate = date
            }
            
            longestStreak = longest
            return
        }
        
        // Calculate current streak from consecutive days
        for item in items.dropFirst() {
            guard let date = item.timestamp else { continue }
            
            if let previous = previousDate {
                let dayDifference = calendar.dateComponents([.day], from: date, to: previous).day ?? 0
                let hourDifference = calendar.dateComponents([.hour], from: date, to: previous).hour ?? 0
                
                // Check if entries are consecutive days and within 26 hours
                if dayDifference == 1 && hourDifference < 26 {
                    current += 1
                } else {
                    break
                }
            }
            previousDate = date
        }
        currentStreak = current
        
        // Calculate longest streak from all history
        var tempStreak = 1
        previousDate = nil
        
        for item in items {
            guard let date = item.timestamp else { continue }
            
            if let previous = previousDate {
                let dayDifference = calendar.dateComponents([.day], from: date, to: previous).day ?? 0
                let hourDifference = calendar.dateComponents([.hour], from: date, to: previous).hour ?? 0
                
                // Check if entries are consecutive days and within 26 hours
                if dayDifference == 1 && hourDifference < 26 {
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
