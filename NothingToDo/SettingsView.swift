import SwiftUI
import CoreData

struct SettingsView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Language".localized)) {
                    Picker("Select Language".localized, selection: Binding(
                        get: { languageManager.selectedLanguage },
                        set: { languageManager.setLanguage($0) }
                    )) {
                        ForEach(Language.allCases, id: \.self) { language in
                            Text(language.rawValue).tag(language)
                        }
                    }
                }
                
                Section(header: Text("About".localized)) {
                    LabeledContent("Developer".localized, value: "Altay Kırlı")
                    
                    Link(destination: URL(string: "https://altaykrl.com")!) {
                        HStack {
                            Text("Website".localized)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    LabeledContent("Version".localized, value: "\(appVersion) (\(buildNumber))")
                }
                
                #if DEBUG
                Section(header: Text("Debug Options")) {
                    Button(action: {
                        TestDataGenerator.generateOneMonthStreak(context: viewContext)
                    }) {
                        Text("Generate 1 Month Test Data")
                            .foregroundColor(.blue)
                    }
                }
                #endif
            }
            .id(languageManager.refreshToggle)
            .navigationTitle("Settings".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(LanguageManager.shared)
}
