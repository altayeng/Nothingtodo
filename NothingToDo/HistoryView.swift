import SwiftUI
import Charts

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
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
        VStack(spacing: 0) {
            // Tab Selector
            Picker("View Mode", selection: $selectedTab) {
                Text("Charts".localized).tag(0)
                Text("List".localized).tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            
            if selectedTab == 0 {
                // Charts View
                TabView(selection: $historyViewMode) {
                    // Weekly View
                    VStack {
                        Chart {
                            ForEach(weeklyData, id: \.date) { dataPoint in
                                BarMark(
                                    x: .value("Date".localized, dataPoint.date, unit: .day),
                                    y: .value("Days Done Nothing".localized, dataPoint.count)
                                )
                                .foregroundStyle(Color.blue.gradient)
                            }
                        }
                        .frame(height: 200)
                        .padding(.horizontal)
                    }
                    .tag(HistoryViewMode.weekly)
                    .tabItem {
                        Label(HistoryViewMode.weekly.localizedName, systemImage: "calendar")
                    }
                    
                    // Monthly View
                    VStack {
                        Chart {
                            ForEach(monthlyData, id: \.date) { dataPoint in
                                BarMark(
                                    x: .value("Date".localized, dataPoint.date, unit: .weekOfYear),
                                    y: .value("Days Done Nothing".localized, dataPoint.count)
                                )
                                .foregroundStyle(Color.blue.gradient)
                            }
                        }
                        .frame(height: 200)
                        .padding(.horizontal)
                    }
                    .tag(HistoryViewMode.monthly)
                    .tabItem {
                        Label(HistoryViewMode.monthly.localizedName, systemImage: "calendar.badge.clock")
                    }
                }
            } else {
                // List View
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(items) { item in
                            HistoryItemView(item: item)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("History".localized)
        .id(languageManager.refreshToggle)
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
            let keyDate = calendar.startOfDay(for: date)
            groupedCounts[keyDate, default: 0] += 1
        }
        
        return groupedCounts.map { HistoryDataPoint(date: $0.key, count: $0.value) }
            .sorted { $0.date < $1.date }
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
