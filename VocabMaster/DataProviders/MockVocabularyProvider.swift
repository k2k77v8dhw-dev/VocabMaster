//
//  MockVocabularyProvider.swift
//  VocabMaster
//
//  Mock implementation for testing and development
//

import Foundation

class MockVocabularyProvider: VocabularyDataProvider {
    
    // In-memory storage
    private var words: [CategoryType: [VocabularyWord]] = [:]
    private var completedIds: Set<String> = []
    private var settings: AppSettings = AppSettings()
    
    init() {
        // Initialize with default data
        let defaultCategories = VocabularyData.getDefaultCategories()
        for category in defaultCategories {
            words[category.type] = category.words
        }
    }
    
    // MARK: - Word CRUD Operations
    
    func fetchWords(for category: CategoryType) async throws -> [VocabularyWord] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        return words[category] ?? []
    }
    
    func fetchAllWords() async throws -> [VocabularyWord] {
        try await Task.sleep(nanoseconds: 100_000_000)
        
        return CategoryType.allCases.flatMap { words[$0] ?? [] }
    }
    
    func fetchWords(for category: CategoryType, language: Language) async throws -> [VocabularyWord] {
        let categoryWords = try await fetchWords(for: category)
        return categoryWords.filter { $0.language == nil || $0.language == language }
    }
    
    func fetchWord(id: String) async throws -> VocabularyWord {
        try await Task.sleep(nanoseconds: 100_000_000)
        
        for category in CategoryType.allCases {
            if let word = words[category]?.first(where: { $0.id == id }) {
                return word
            }
        }
        
        throw DataProviderError.notFound
    }
    
    func createWord(_ word: VocabularyWord, in category: CategoryType) async throws -> VocabularyWord {
        try await Task.sleep(nanoseconds: 100_000_000)
        
        words[category, default: []].append(word)
        return word
    }
    
    func createWords(_ words: [VocabularyWord], in category: CategoryType) async throws -> [VocabularyWord] {
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds for bulk
        
        self.words[category, default: []].append(contentsOf: words)
        return words
    }
    
    func updateWord(_ word: VocabularyWord, in category: CategoryType) async throws -> VocabularyWord {
        try await Task.sleep(nanoseconds: 100_000_000)
        
        guard var categoryWords = words[category],
              let index = categoryWords.firstIndex(where: { $0.id == word.id }) else {
            throw DataProviderError.notFound
        }
        
        categoryWords[index] = word
        words[category] = categoryWords
        
        return word
    }
    
    func deleteWord(id: String) async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
        
        for category in CategoryType.allCases {
            words[category]?.removeAll { $0.id == id }
        }
        
        completedIds.remove(id)
    }
    
    func deleteWords(ids: [String]) async throws {
        try await Task.sleep(nanoseconds: 150_000_000)
        
        for category in CategoryType.allCases {
            words[category]?.removeAll { ids.contains($0.id) }
        }
        
        completedIds.subtract(ids)
    }
    
    func deleteAllWords(in category: CategoryType) async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
        
        if let categoryWords = words[category] {
            let ids = categoryWords.map { $0.id }
            completedIds.subtract(ids)
        }
        
        words[category] = []
    }
    
    // MARK: - Progress CRUD Operations
    
    func markWordCompleted(id: String) async throws {
        try await Task.sleep(nanoseconds: 50_000_000)
        
        completedIds.insert(id)
    }
    
    func markWordIncomplete(id: String) async throws {
        try await Task.sleep(nanoseconds: 50_000_000)
        
        completedIds.remove(id)
    }
    
    func isWordCompleted(id: String) async throws -> Bool {
        try await Task.sleep(nanoseconds: 50_000_000)
        
        return completedIds.contains(id)
    }
    
    func fetchCompletedWordIds() async throws -> Set<String> {
        try await Task.sleep(nanoseconds: 50_000_000)
        
        return completedIds
    }
    
    func fetchProgress(for category: CategoryType, language: Language) async throws -> (completed: Int, total: Int) {
        try await Task.sleep(nanoseconds: 50_000_000)
        
        let categoryWords = try await fetchWords(for: category, language: language)
        let completedCount = categoryWords.filter { completedIds.contains($0.id) }.count
        
        return (completedCount, categoryWords.count)
    }
    
    // MARK: - Settings CRUD Operations
    
    func getCurrentLanguage() async throws -> Language {
        try await Task.sleep(nanoseconds: 30_000_000)
        
        return settings.currentLanguage
    }
    
    func setCurrentLanguage(_ language: Language) async throws {
        try await Task.sleep(nanoseconds: 30_000_000)
        
        settings.currentLanguage = language
    }
    
    func getSettings() async throws -> AppSettings {
        try await Task.sleep(nanoseconds: 30_000_000)
        
        return settings
    }
    
    func updateSettings(_ settings: AppSettings) async throws {
        try await Task.sleep(nanoseconds: 30_000_000)
        
        self.settings = settings
    }
    
    // MARK: - Batch Operations
    
    func importVocabulary(_ words: [VocabularyWord], category: CategoryType, replaceExisting: Bool) async throws {
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        if replaceExisting {
            self.words[category] = words
        } else {
            self.words[category, default: []].append(contentsOf: words)
        }
    }
    
    func exportVocabulary() async throws -> [CategoryType: [VocabularyWord]] {
        try await Task.sleep(nanoseconds: 200_000_000)
        
        return words
    }
    
    func resetAllData() async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
        
        words = [:]
        completedIds = []
        settings = AppSettings()
    }
}

// MARK: - Firebase Provider Stub

class FirebaseVocabularyProvider: VocabularyDataProvider {
    
    // TODO: Implement Firebase integration
    // This would use Firebase Firestore for data storage
    // and Firebase Authentication for user management
    
    init() {
        print("FirebaseVocabularyProvider: Not yet implemented")
    }
    
    func fetchWords(for category: CategoryType) async throws -> [VocabularyWord] {
        throw DataProviderError.unknown("Firebase provider not implemented")
    }
    
    func fetchAllWords() async throws -> [VocabularyWord] {
        throw DataProviderError.unknown("Firebase provider not implemented")
    }
    
    func fetchWords(for category: CategoryType, language: Language) async throws -> [VocabularyWord] {
        throw DataProviderError.unknown("Firebase provider not implemented")
    }
    
    func fetchWord(id: String) async throws -> VocabularyWord {
        throw DataProviderError.unknown("Firebase provider not implemented")
    }
    
    func createWord(_ word: VocabularyWord, in category: CategoryType) async throws -> VocabularyWord {
        throw DataProviderError.unknown("Firebase provider not implemented")
    }
    
    func createWords(_ words: [VocabularyWord], in category: CategoryType) async throws -> [VocabularyWord] {
        throw DataProviderError.unknown("Firebase provider not implemented")
    }
    
    func updateWord(_ word: VocabularyWord, in category: CategoryType) async throws -> VocabularyWord {
        throw DataProviderError.unknown("Firebase provider not implemented")
    }
    
    func deleteWord(id: String) async throws {
        throw DataProviderError.unknown("Firebase provider not implemented")
    }
    
    func deleteWords(ids: [String]) async throws {
        throw DataProviderError.unknown("Firebase provider not implemented")
    }
    
    func deleteAllWords(in category: CategoryType) async throws {
        throw DataProviderError.unknown("Firebase provider not implemented")
    }
    
    func markWordCompleted(id: String) async throws {
        throw DataProviderError.unknown("Firebase provider not implemented")
    }
    
    func markWordIncomplete(id: String) async throws {
        throw DataProviderError.unknown("Firebase provider not implemented")
    }
    
    func isWordCompleted(id: String) async throws -> Bool {
        throw DataProviderError.unknown("Firebase provider not implemented")
    }
    
    func fetchCompletedWordIds() async throws -> Set<String> {
        throw DataProviderError.unknown("Firebase provider not implemented")
    }
    
    func fetchProgress(for category: CategoryType, language: Language) async throws -> (completed: Int, total: Int) {
        throw DataProviderError.unknown("Firebase provider not implemented")
    }
    
    func getCurrentLanguage() async throws -> Language {
        throw DataProviderError.unknown("Firebase provider not implemented")
    }
    
    func setCurrentLanguage(_ language: Language) async throws {
        throw DataProviderError.unknown("Firebase provider not implemented")
    }
    
    func getSettings() async throws -> AppSettings {
        throw DataProviderError.unknown("Firebase provider not implemented")
    }
    
    func updateSettings(_ settings: AppSettings) async throws {
        throw DataProviderError.unknown("Firebase provider not implemented")
    }
    
    func importVocabulary(_ words: [VocabularyWord], category: CategoryType, replaceExisting: Bool) async throws {
        throw DataProviderError.unknown("Firebase provider not implemented")
    }
    
    func exportVocabulary() async throws -> [CategoryType: [VocabularyWord]] {
        throw DataProviderError.unknown("Firebase provider not implemented")
    }
    
    func resetAllData() async throws {
        throw DataProviderError.unknown("Firebase provider not implemented")
    }
}
