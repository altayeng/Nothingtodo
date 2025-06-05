import Foundation
import SwiftUI
import OSLog

extension String {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "NothingToDo", category: "StringLocalization")
    
    var localized: String {
        let languageManager = LanguageManager.shared
        let bundle = Bundle.main
        let languageCode = languageManager.selectedLanguage.locale
        
        Self.logger.info("Localizing string: '\(self)' with language: \(languageManager.selectedLanguage.rawValue)")
        
        if let path = bundle.path(forResource: languageCode, ofType: "lproj"),
           let languageBundle = Bundle(path: path) {
            Self.logger.info("Found language bundle for '\(languageCode)' at path: \(path)")
            let localizedString = languageBundle.localizedString(forKey: self, value: nil, table: nil)
            Self.logger.info("Localized result: '\(localizedString)'")
            return localizedString
        }
        
        Self.logger.warning("Failed to find language bundle, falling back to main bundle localization")
        let fallbackString = NSLocalizedString(self, bundle: .main, comment: "")
        Self.logger.info("Fallback localization result: '\(fallbackString)'")
        return fallbackString
    }
}
