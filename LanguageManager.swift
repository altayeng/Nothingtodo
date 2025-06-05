import SwiftUI

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var selectedLanguage: Language {
        didSet {
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "selectedLanguage")
            objectWillChange.send()
        }
    }
    
    var locale: Locale {
        if let languageCode = selectedLanguage.locale {
            return Locale(identifier: languageCode)
        }
        return .current
    }
    
    private init() {
        let savedLanguageRawValue = UserDefaults.standard.string(forKey: "selectedLanguage") ?? ""
        self.selectedLanguage = Language(rawValue: savedLanguageRawValue) ?? .system
    }
}

enum Language: String, CaseIterable, Codable {
    case system = "System"
    case english = "English"
    case turkish = "Türkçe"
    case spanish = "Español"
    case french = "Français"
    case german = "Deutsch"
    
    var locale: String? {
        switch self {
        case .system:
            return nil
        case .english: return "en"
        case .turkish: return "tr"
        case .spanish: return "es"
        case .french: return "fr"
        case .german: return "de"
        }
    }
} 