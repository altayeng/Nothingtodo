//
//  NothingToDoApp.swift
//  NothingToDo
//
//  Created by Altay on 5.06.2025.
//

import SwiftUI
import UserNotifications

@main
struct NothingToDoApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var languageManager = LanguageManager.shared
    
    init() {
        // Initialize with the current language
        let initialLanguage = LanguageManager.shared.selectedLanguage
        requestNotificationPermission()
        scheduleNotification(for: initialLanguage)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(languageManager)
                .environment(\.locale, languageManager.locale)
                .id(languageManager.refreshToggle)
                .onChange(of: languageManager.selectedLanguage) { newLanguage in
                    scheduleNotification(for: newLanguage)
                }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    private func getLocalizedNotificationText(for language: Language) -> (title: String, body: String) {
        switch language.locale {
        case "tr":
            return (title: "Hiçbir Şey Yapma", body: "Bugün hiçbir şey yaptın mı? Gel ve işaretle!")
        case "es":
            return (title: "No Hagas Nada", body: "¿Has hecho nada hoy? Ven y marca!")
        case "fr":
            return (title: "Ne Fais Rien", body: "N'as-tu rien fait aujourd'hui ? Viens et marque-toi !")
        case "de":
            return (title: "Mach Nichts", body: "Hast du heute nichts gemacht? Komm und markiere es!")
        default: // English
            return (title: "Nothing To Do", body: "Have you done nothing today? Come and mark it!")
        }
    }
    
    private func scheduleNotification(for language: Language) {
        let localizedText = getLocalizedNotificationText(for: language)
        let content = UNMutableNotificationContent()
        content.title = localizedText.title
        content.body = localizedText.body
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 22
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
}
