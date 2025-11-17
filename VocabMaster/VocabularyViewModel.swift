//
//  VocabularyViewModel.swift
//  VocabMaster
//
//  ViewModel using Data Provider Pattern for easy backend swapping
//

import Foundation
import SwiftUI
import Combine

@MainActor
class VocabularyViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var completedWords: Set<String> = []
    @Published var currentLanguage: Language = .en
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSyncing = false
    
    private let dataProvider: VocabularyDataProvider
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(dataProvider: VocabularyDataProvider? = nil) {
        self.dataProvider = dataProvider ?? DataProviderFactory.createConfiguredProvider()
        
        Task {
            await loadData()
        }
    }
    
    // MARK: - Data Loading
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Load settings first
            let settings = try await dataProvider.getSettings()
            currentLanguage = settings.currentLanguage
            
            // Load vocabulary
            await loadVocabulary()
            
            // Load progress
            await loadProgress()
            
            // Initialize with default data if needed
            if categories.allSatisfy({ $0.words.isEmpty }) && AppConfiguration.Features.autoInitializeDefaultData {
                await initializeDefaultData()
            }
            
        } catch {
            errorMessage = "Failed to load data: \(error.localizedDescription)"
            print("Error loading data: \(error)")
        }
        
        isLoading = false
    }
    
    private func loadVocabulary() async {
        do {
            var loadedCategories: [Category] = []
            
            for categoryType in CategoryType.allCases {
                let words = try await dataProvider.fetchWords(for: categoryType)
                let category = Category(id: categoryType.rawValue, type: categoryType, words: words)
                loadedCategories.append(category)
            }
            
            categories = loadedCategories
        } catch {
            print("Error loading vocabulary: \(error)")
        }
    }
    
    private func loadProgress() async {
        do {
            completedWords = try await dataProvider.fetchCompletedWordIds()
        } catch {
            print("Error loading progress: \(error)")
        }
    }
    
    private func initializeDefaultData() async {
        let defaultCategories = VocabularyData.getDefaultCategories()
        
        do {
            for category in defaultCategories {
                _ = try await dataProvider.createWords(category.words, in: category.type)
            }
            
            await loadVocabulary()
        } catch {
            print("Error initializing default data: \(error)")
        }
    }
    
    // MARK: - Category Operations
    
    func getCategory(type: CategoryType) -> Category? {
        return categories.first { $0.type == type }
    }
    
    func getCategoryWords(type: CategoryType, language: Language) -> [VocabularyWord] {
        guard let category = getCategory(type: type) else { return [] }
        return category.words.filter { word in
            word.language == nil || word.language == language
        }
    }
    
    func getAvailableCategories(for language: Language) -> [CategoryType] {
        return categories.compactMap { category in
            let hasWords = category.words.contains { word in
                word.language == nil || word.language == language
            }
            return hasWords ? category.type : nil
        }
    }
    
    // MARK: - Word CRUD Operations
    
    func addWord(_ word: VocabularyWord, to categoryType: CategoryType) {
        Task {
            do {
                let createdWord = try await dataProvider.createWord(word, in: categoryType)
                
                // Update local state
                if let index = categories.firstIndex(where: { $0.type == categoryType }) {
                    var updatedCategory = categories[index]
                    updatedCategory.words.append(createdWord)
                    categories[index] = updatedCategory
                }
            } catch {
                errorMessage = "Failed to add word: \(error.localizedDescription)"
            }
        }
    }
    
    func updateWord(_ word: VocabularyWord, in categoryType: CategoryType) {
        Task {
            do {
                let updatedWord = try await dataProvider.updateWord(word, in: categoryType)
                
                // Update local state
                if let categoryIndex = categories.firstIndex(where: { $0.type == categoryType }),
                   let wordIndex = categories[categoryIndex].words.firstIndex(where: { $0.id == word.id }) {
                    var updatedCategory = categories[categoryIndex]
                    updatedCategory.words[wordIndex] = updatedWord
                    categories[categoryIndex] = updatedCategory
                }
            } catch {
                errorMessage = "Failed to update word: \(error.localizedDescription)"
            }
        }
    }
    
    func deleteWords(ids: [String], from categoryType: CategoryType) {
        Task {
            do {
                try await dataProvider.deleteWords(ids: ids)
                
                // Update local state
                if let index = categories.firstIndex(where: { $0.type == categoryType }) {
                    var updatedCategory = categories[index]
                    updatedCategory.words.removeAll { ids.contains($0.id) }
                    categories[index] = updatedCategory
                }
                
                completedWords.subtract(ids)
            } catch {
                errorMessage = "Failed to delete words: \(error.localizedDescription)"
            }
        }
    }
    
    func addWords(_ words: [VocabularyWord], to categoryType: CategoryType) {
        Task {
            do {
                let createdWords = try await dataProvider.createWords(words, in: categoryType)
                
                // Update local state
                if let index = categories.firstIndex(where: { $0.type == categoryType }) {
                    var updatedCategory = categories[index]
                    updatedCategory.words.append(contentsOf: createdWords)
                    categories[index] = updatedCategory
                }
            } catch {
                errorMessage = "Failed to add words: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Progress Operations
    
    func completeWord(_ wordId: String) {
        Task {
            do {
                try await dataProvider.markWordCompleted(id: wordId)
                completedWords.insert(wordId)
            } catch {
                print("Error completing word: \(error)")
            }
        }
    }
    
    func uncompleteWord(_ wordId: String) {
        Task {
            do {
                try await dataProvider.markWordIncomplete(id: wordId)
                completedWords.remove(wordId)
            } catch {
                print("Error uncompleting word: \(error)")
            }
        }
    }
    
    func clearProgress() {
        Task {
            do {
                try await dataProvider.clearAllProgress()
                completedWords = []
            } catch {
                errorMessage = "Failed to clear progress: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Statistics
    
    func getTotalWords(for language: Language) -> Int {
        return categories.reduce(0) { total, category in
            total + category.words.filter { $0.language == nil || $0.language == language }.count
        }
    }
    
    func getCompletedWordsCount(for language: Language) -> Int {
        var count = 0
        for category in categories {
            for word in category.words {
                if (word.language == nil || word.language == language) && completedWords.contains(word.id) {
                    count += 1
                }
            }
        }
        return count
    }
    
    func getProgress(for categoryType: CategoryType, language: Language) -> (completed: Int, total: Int) {
        let words = getCategoryWords(type: categoryType, language: language)
        let completed = words.filter { completedWords.contains($0.id) }.count
        return (completed, words.count)
    }
    
    // MARK: - Language Settings
    
    func setCurrentLanguage(_ language: Language) {
        Task {
            do {
                try await dataProvider.setCurrentLanguage(language)
                currentLanguage = language
            } catch {
                errorMessage = "Failed to set language: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Import/Export
    
    func importVocabulary(_ words: [VocabularyWord], to category: CategoryType, replaceExisting: Bool = false) {
        Task {
            do {
                try await dataProvider.importVocabulary(words, category: category, replaceExisting: replaceExisting)
                await loadVocabulary()
            } catch {
                errorMessage = "Failed to import vocabulary: \(error.localizedDescription)"
            }
        }
    }
    
    func exportVocabulary() async -> [CategoryType: [VocabularyWord]]? {
        do {
            return try await dataProvider.exportVocabulary()
        } catch {
            errorMessage = "Failed to export vocabulary: \(error.localizedDescription)"
            return nil
        }
    }
    
    // MARK: - Sync (for cloud providers)
    
    func syncData() {
        guard dataProvider.supportsSyncing else {
            print("Data provider does not support syncing")
            return
        }
        
        Task {
            isSyncing = true
            
            do {
                try await dataProvider.syncData()
                await loadData() // Reload after sync
            } catch {
                errorMessage = "Sync failed: \(error.localizedDescription)"
            }
            
            isSyncing = false
        }
    }
    
    var supportsSyncing: Bool {
        dataProvider.supportsSyncing
    }
    
    // MARK: - Reset
    
    func resetAllData() {
        Task {
            do {
                try await dataProvider.resetAllData()
                categories = []
                completedWords = []
                currentLanguage = .en
                
                if AppConfiguration.Features.autoInitializeDefaultData {
                    await initializeDefaultData()
                }
            } catch {
                errorMessage = "Failed to reset data: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Error Handling Extension

extension VocabularyViewModel {
    func clearError() {
        errorMessage = nil
    }
    
    var hasError: Bool {
        errorMessage != nil
    }
}
