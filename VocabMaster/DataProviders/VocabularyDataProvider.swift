//
//  VocabularyDataProvider.swift
//  VocabMaster
//
//  Data Provider Protocol - Abstract interface for CRUD operations
//  This allows easy swapping between Core Data, AWS, Firebase, etc.
//

import Foundation
import Combine

// MARK: - Data Provider Result

enum DataProviderError: Error {
    case notFound
    case invalidData
    case saveFailed
    case deleteFailed
    case networkError
    case unauthorized
    case unknown(String)
    
    var localizedDescription: String {
        switch self {
        case .notFound: return "Data not found"
        case .invalidData: return "Invalid data format"
        case .saveFailed: return "Failed to save data"
        case .deleteFailed: return "Failed to delete data"
        case .networkError: return "Network error occurred"
        case .unauthorized: return "Unauthorized access"
        case .unknown(let message): return message
        }
    }
}

// MARK: - Vocabulary Data Provider Protocol

protocol VocabularyDataProvider {
    
    // MARK: - Word CRUD Operations
    
    /// Fetch all words for a specific category
    func fetchWords(for category: CategoryType) async throws -> [VocabularyWord]
    
    /// Fetch all words across all categories
    func fetchAllWords() async throws -> [VocabularyWord]
    
    /// Fetch words filtered by language
    func fetchWords(for category: CategoryType, language: Language) async throws -> [VocabularyWord]
    
    /// Fetch a single word by ID
    func fetchWord(id: String) async throws -> VocabularyWord
    
    /// Create a new word
    func createWord(_ word: VocabularyWord, in category: CategoryType) async throws -> VocabularyWord
    
    /// Create multiple words (bulk insert)
    func createWords(_ words: [VocabularyWord], in category: CategoryType) async throws -> [VocabularyWord]
    
    /// Update an existing word
    func updateWord(_ word: VocabularyWord, in category: CategoryType) async throws -> VocabularyWord
    
    /// Delete a word by ID
    func deleteWord(id: String) async throws
    
    /// Delete multiple words (bulk delete)
    func deleteWords(ids: [String]) async throws
    
    /// Delete all words in a category
    func deleteAllWords(in category: CategoryType) async throws
    
    // MARK: - Progress CRUD Operations
    
    /// Mark a word as completed
    func markWordCompleted(id: String) async throws
    
    /// Unmark a word as completed
    func markWordIncomplete(id: String) async throws
    
    /// Check if a word is completed
    func isWordCompleted(id: String) async throws -> Bool
    
    /// Fetch all completed word IDs
    func fetchCompletedWordIds() async throws -> Set<String>
    
    /// Fetch completion progress for a category
    func fetchProgress(for category: CategoryType, language: Language) async throws -> (completed: Int, total: Int)
    
    /// Fetch overall progress
    func fetchOverallProgress(for language: Language) async throws -> (completed: Int, total: Int)
    
    /// Clear all progress
    func clearAllProgress() async throws
    
    // MARK: - Settings CRUD Operations
    
    /// Get current language setting
    func getCurrentLanguage() async throws -> Language
    
    /// Set current language
    func setCurrentLanguage(_ language: Language) async throws
    
    /// Get all settings
    func getSettings() async throws -> AppSettings
    
    /// Update settings
    func updateSettings(_ settings: AppSettings) async throws
    
    // MARK: - Batch Operations
    
    /// Import vocabulary from external source
    func importVocabulary(_ words: [VocabularyWord], category: CategoryType, replaceExisting: Bool) async throws
    
    /// Export all vocabulary
    func exportVocabulary() async throws -> [CategoryType: [VocabularyWord]]
    
    /// Reset all data (dangerous operation)
    func resetAllData() async throws
    
    // MARK: - Sync Operations (for cloud providers)
    
    /// Sync local data with remote
    func syncData() async throws
    
    /// Check if sync is available
    var supportsSyncing: Bool { get }
}

// MARK: - App Settings Model

struct AppSettings: Codable {
    var currentLanguage: Language
    var lastSyncDate: Date?
    var userId: String?
    
    init(currentLanguage: Language = .en, lastSyncDate: Date? = nil, userId: String? = nil) {
        self.currentLanguage = currentLanguage
        self.lastSyncDate = lastSyncDate
        self.userId = userId
    }
}

// MARK: - Default Implementations (Optional methods)

extension VocabularyDataProvider {
    var supportsSyncing: Bool { false }
    
    func syncData() async throws {
        // Default: no-op for providers that don't support syncing
    }
    
    func clearAllProgress() async throws {
        let completedIds = try await fetchCompletedWordIds()
        for id in completedIds {
            try await markWordIncomplete(id: id)
        }
    }
    
    func fetchOverallProgress(for language: Language) async throws -> (completed: Int, total: Int) {
        var totalWords = 0
        var completedWords = 0
        
        for category in CategoryType.allCases {
            let progress = try await fetchProgress(for: category, language: language)
            totalWords += progress.total
            completedWords += progress.completed
        }
        
        return (completedWords, totalWords)
    }
}

// MARK: - Provider Factory

enum DataProviderType {
    case coreData
    case aws
    case firebase
    case mock
}

class DataProviderFactory {
    static func createProvider(type: DataProviderType) -> VocabularyDataProvider {
        switch type {
        case .coreData:
            return CoreDataVocabularyProvider(persistenceController: .shared)
        case .aws:
            return AWSVocabularyProvider()
        case .firebase:
            return FirebaseVocabularyProvider()
        case .mock:
            return MockVocabularyProvider()
        }
    }
}
