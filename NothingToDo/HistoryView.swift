import SwiftUI
import Charts

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var historyViewMode: HistoryViewMode = .weekly
    @State private var selectedTab = 0
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    enum HistoryViewMode: String, CaseIterable, Identifiable {
        case weekly = "Weekly"
        case monthly = "Monthly"
        
        var id: String { self.rawValue }
        
        var localizedName: String {
            self.rawValue.localized
        }
    }
    
    var body: some View {
        ZStack {
            // Modern gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color(.systemGray6).opacity(0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Custom Header with Back Button
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
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
                    
                    Spacer()
                    
                    Text("History".localized)
                        .font(.system(.title, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Invisible spacer to center the title
                    Circle()
                        .fill(.clear)
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial)
                
                // Modern Tab Selector
                VStack(spacing: 0) {
                    Picker("View Mode", selection: $selectedTab) {
                        Label("Charts", systemImage: "chart.bar.fill").tag(0)
                        Label("List", systemImage: "list.bullet").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    
                    Divider()
                        .opacity(0.3)
                }
                .background(.ultraThinMaterial)
                
                if selectedTab == 0 {
                    // Modern Charts View
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            // Chart Mode Selector
                            HStack {
                                ForEach(HistoryViewMode.allCases, id: \.id) { mode in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            historyViewMode = mode
                                        }
                                    }) {
                                        Text(mode.localizedName)
                                            .font(.system(.subheadline, weight: .medium))
                                            .foregroundColor(historyViewMode == mode ? .white : .primary)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(
                                                Capsule()
                                                    .fill(historyViewMode == mode ? Color.blue : Color(.systemGray5))
                                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: historyViewMode)
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.top, 20)
                            
                            // Chart Container
                            VStack(spacing: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(historyViewMode == .weekly ? "Weekly Activity" : "Monthly Overview")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        
                                        Text(historyViewMode == .weekly ? "Days per week (last 12 weeks)" : "Activity by month")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                
                                // Enhanced Chart
                                if historyViewMode == .weekly {
                                    Chart {
                                        ForEach(weeklyData, id: \.date) { dataPoint in
                                            BarMark(
                                                x: .value("Week".localized, dataPoint.date, unit: .weekOfYear),
                                                y: .value("Days", dataPoint.count)
                                            )
                                            .foregroundStyle(.linearGradient(
                                                colors: [.blue, .blue.opacity(0.7)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            ))
                                            .cornerRadius(6)
                                        }
                                    }
                                    .frame(height: 220)
                                    .chartYAxis {
                                        AxisMarks(position: .leading, values: [0, 1, 2, 3, 4, 5, 6, 7]) { value in
                                            AxisValueLabel {
                                                if let intValue = value.as(Int.self) {
                                                    Text("\(intValue)")
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
                                            AxisGridLine()
                                                .foregroundStyle(.secondary.opacity(0.3))
                                        }
                                    }
                                    .chartXAxis {
                                        AxisMarks { _ in
                                            AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                } else {
                                    Chart {
                                        ForEach(monthlyData, id: \.date) { dataPoint in
                                            BarMark(
                                                x: .value("Date".localized, dataPoint.date, unit: .month),
                                                y: .value("Count", dataPoint.count)
                                            )
                                            .foregroundStyle(.linearGradient(
                                                colors: [.orange, .orange.opacity(0.7)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            ))
                                            .cornerRadius(4)
                                        }
                                    }
                                    .frame(height: 220)
                                    .chartYAxis {
                                        AxisMarks(position: .leading) { _ in
                                            AxisValueLabel()
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .chartXAxis {
                                        AxisMarks { _ in
                                            AxisValueLabel(format: .dateTime.month(.abbreviated))
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(.linearGradient(
                                                colors: [.white.opacity(0.5), .clear],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 8)
                            )
                            .padding(.horizontal, 20)
                            
                            // Statistics Cards
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                StatCard(
                                    title: "Total Days",
                                    value: "\(items.count)",
                                    icon: "calendar.badge.checkmark",
                                    color: .blue
                                )
                                
                                StatCard(
                                    title: "This Month",
                                    value: "\(currentMonthCount)",
                                    icon: "calendar.circle",
                                    color: .green
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 20)
                    }
                } else {
                    // Modern List View
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            if items.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "calendar.badge.plus")
                                        .font(.system(size: 60))
                                        .foregroundColor(.secondary.opacity(0.5))
                                    
                                    Text("No history yet")
                                        .font(.title2)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Start marking your nothing-doing days to see them here!")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.vertical, 60)
                            } else {
                                ForEach(items) { item in
                                    ModernHistoryItemView(item: item)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .id(languageManager.refreshToggle)
    }
    
    private var currentMonthCount: Int {
        let calendar = Calendar.current
        let now = Date()
        return items.filter { item in
            guard let date = item.timestamp else { return false }
            return calendar.isDate(date, equalTo: now, toGranularity: .month)
        }.count
    }
    
    // MARK: - History Data
    
    struct HistoryDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let count: Int
    }
    
    private var weeklyData: [HistoryDataPoint] {
        let calendar = Calendar.current
        var groupedCounts: [Date: Int] = [:]
        
        for item in items {
            guard let date = item.timestamp else { continue }
            // Get the start of the week for this date
            let weekOfYear = calendar.component(.weekOfYear, from: date)
            let year = calendar.component(.year, from: date)
            
            // Create a date for the start of this week
            var dateComponents = DateComponents()
            dateComponents.yearForWeekOfYear = year
            dateComponents.weekOfYear = weekOfYear
            dateComponents.weekday = calendar.firstWeekday
            
            if let weekStartDate = calendar.date(from: dateComponents) {
                groupedCounts[weekStartDate, default: 0] += 1
            }
        }
        
        return groupedCounts.map { HistoryDataPoint(date: $0.key, count: $0.value) }
            .sorted { $0.date < $1.date }
            .suffix(12) // Show last 12 weeks
    }
    
    private var monthlyData: [HistoryDataPoint] {
        let calendar = Calendar.current
        var groupedCounts: [Date: Int] = [:]
        
        for item in items {
            guard let date = item.timestamp else { continue }
            let comps = calendar.dateComponents([.year, .month], from: date)
            if let keyDate = calendar.date(from: comps) {
                groupedCounts[keyDate, default: 0] += 1
            }
        }
        
        return groupedCounts.map { HistoryDataPoint(date: $0.key, count: $0.value) }
            .sorted { $0.date < $1.date }
    }
}

struct ModernHistoryItemView: View {
    let item: Item
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        HStack(spacing: 16) {
            // Date circle
            VStack(spacing: 2) {
                Text(item.timestamp?.formatted(.dateTime.day()) ?? "?")
                    .font(.system(.title3, weight: .bold))
                    .foregroundColor(.blue)
                
                Text(item.timestamp?.formatted(.dateTime.month(.abbreviated)) ?? "")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 44, height: 44)
            .background(
                Circle()
                    .fill(.blue.opacity(0.1))
                    .overlay(
                        Circle()
                            .stroke(.blue.opacity(0.3), lineWidth: 1)
                    )
            )
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(item.timestamp.map { dateFormatter.string(from: $0) } ?? "Unknown Date")
                        .font(.system(.body, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(item.timestamp.map { timeFormatter.string(from: $0) } ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let note = item.note, !note.isEmpty {
                    Text(note)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .padding(.top, 2)
                } else {
                    Text("Enjoyed doing nothing")
                        .font(.subheadline)
                        .foregroundColor(.secondary.opacity(0.7))
                        .italic()
                        .padding(.top, 2)
                }
            }
            
            // Checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundColor(.green)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.linearGradient(
                            colors: [.white.opacity(0.5), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(.title, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.linearGradient(
                            colors: [color.opacity(0.3), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 1)
                )
                .shadow(color: color.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

struct HistoryItemView: View {
    let item: Item
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.timestamp.map { dateFormatter.string(from: $0) } ?? "Unknown Date")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
            
            if let note = item.note, !note.isEmpty {
                Text(note)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}
