import SwiftUI
import Foundation
import OSLog

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "NothingToDo", category: "LanguageManager")
    
    @AppStorage("selectedLanguage") private(set) var selectedLanguage = Language.system {
        didSet {
            logger.info("Language changed from \(oldValue.rawValue) to \(self.selectedLanguage.rawValue)")
            updateLocale()
            UserDefaults.standard.set([self.selectedLanguage.locale], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            logger.info("AppleLanguages updated to: \(UserDefaults.standard.stringArray(forKey: "AppleLanguages") ?? [])")
            refreshToggle.toggle()
        }
    }
    
    @Published private(set) var locale: Locale
    @Published private(set) var refreshToggle = false
    
    private init() {
        logger.info("Initializing LanguageManager")
        
        // First initialize the locale with a default value
        self.locale = Locale.current
        
        // Then load saved language if available
        if let savedLanguages = UserDefaults.standard.stringArray(forKey: "AppleLanguages"),
           let savedLanguageCode = savedLanguages.first,
           let language = Language.allCases.first(where: { [weak self] lang in
               lang.locale == savedLanguageCode
           }) {
            logger.info("Found saved language: \(savedLanguageCode), matching to: \(language.rawValue)")
            selectedLanguage = language
        } else {
            logger.info("No saved language found, using system default")
            selectedLanguage = .system
        }
        
        // Finally update the locale
        updateLocale()
        logger.info("Initial locale set to: \(self.selectedLanguage.locale)")
    }
    
    func setLanguage(_ language: Language) {
        logger.info("Setting language to: \(language.rawValue)")
        selectedLanguage = language
    }
    
    private func updateLocale() {
        let identifier = selectedLanguage.locale
        locale = Locale(identifier: identifier)
        logger.info("Updating locale to: \(identifier)")
        
        // Force update the main bundle
        if let languageBundlePath = Bundle.main.path(forResource: identifier, ofType: "lproj"),
           let languageBundle = Bundle(path: languageBundlePath) {
            logger.info("Found language bundle at: \(languageBundlePath)")
            UserDefaults.standard.set([identifier], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
        } else {
            logger.error("Failed to find language bundle for: \(identifier)")
        }
        
        logger.info("Current bundle localizations: \(Bundle.main.localizations)")
        logger.info("Current preferred localizations: \(Bundle.main.preferredLocalizations)")
    }
}

enum Language: String, CaseIterable, Codable {
    case system = "System"
    case english = "English"
    case turkish = "Türkçe"
    case spanish = "Español"
    case french = "Français"
    case german = "Deutsch"
    
    var locale: String {
        switch self {
        case .system:
            let preferredLanguage = Bundle.main.preferredLocalizations.first ?? "en"
            return preferredLanguage
        case .english: return "en"
        case .turkish: return "tr"
        case .spanish: return "es"
        case .french: return "fr"
        case .german: return "de"
        }
    }
}
