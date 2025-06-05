import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss

    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Language")) {
                    Picker("Select Language", selection: $languageManager.selectedLanguage) {
                        ForEach(Language.allCases, id: \.self) { language in
                            Text(language.rawValue).tag(language)
                        }
                    }
                }
                
                Section(header: Text("About")) {
                    LabeledContent("Developer", value: "Altay")
                    
                    Link(destination: URL(string: "https://github.com/altaywtf")!) {
                        HStack {
                            Text("Website")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    LabeledContent("Version", value: "\(appVersion) (\(buildNumber))")
                }
            }
            .id(languageManager.selectedLanguage)
            .environment(\.locale, languageManager.locale)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
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