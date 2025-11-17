//
//  Models.swift
//  VocabMaster
//

import Foundation
import SwiftUI

// MARK: - Language
enum Language: String, CaseIterable, Codable {
    case en, es, fr, de, ja, zh, ko, ar, ru, pt
    
    var name: String {
        switch self {
        case .en: return "English"
        case .es: return "Spanish"
        case .fr: return "French"
        case .de: return "German"
        case .ja: return "Japanese"
        case .zh: return "Chinese"
        case .ko: return "Korean"
        case .ar: return "Arabic"
        case .ru: return "Russian"
        case .pt: return "Portuguese"
        }
    }
    
    var flag: String {
        switch self {
        case .en: return "🇬🇧"
        case .es: return "🇪🇸"
        case .fr: return "🇫🇷"
        case .de: return "🇩🇪"
        case .ja: return "🇯🇵"
        case .zh: return "🇨🇳"
        case .ko: return "🇰🇷"
        case .ar: return "🇸🇦"
        case .ru: return "🇷🇺"
        case .pt: return "🇵🇹"
        }
    }
    
    var nativeName: String {
        switch self {
        case .en: return "English"
        case .es: return "Español"
        case .fr: return "Français"
        case .de: return "Deutsch"
        case .ja: return "日本語"
        case .zh: return "中文"
        case .ko: return "한국어"
        case .ar: return "العربية"
        case .ru: return "Русский"
        case .pt: return "Português"
        }
    }
}

// MARK: - VocabularyWord
struct VocabularyWord: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var word: String
    var definition: String
    var example: String
    var pronunciation: String?
    var language: Language?
    var translationLanguage: Language?
    
    static func == (lhs: VocabularyWord, rhs: VocabularyWord) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - CategoryType
enum CategoryType: String, CaseIterable, Codable {
    case business, travel, daily, academic
    
    var name: String {
        switch self {
        case .business: return "Business English"
        case .travel: return "Travel & Tourism"
        case .daily: return "Daily Conversation"
        case .academic: return "Academic Terms"
        }
    }
    
    var icon: String {
        switch self {
        case .business: return "briefcase.fill"
        case .travel: return "airplane"
        case .daily: return "message.fill"
        case .academic: return "graduationcap.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .business: return Color(hex: "007AFF")
        case .travel: return Color(hex: "34C759")
        case .daily: return Color(hex: "FF9500")
        case .academic: return Color(hex: "AF52DE")
        }
    }
}

// MARK: - Category
struct Category: Identifiable, Codable {
    var id: String
    var type: CategoryType
    var words: [VocabularyWord]
    
    var name: String { type.name }
    var icon: String { type.icon }
    var color: Color { type.color }
}

// MARK: - Sentence (for import wizard)
struct Sentence: Identifiable {
    var id = UUID()
    var original: String
    var translation: String
    var selected: Bool = true
}

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
