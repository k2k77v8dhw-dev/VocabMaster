//
//  CoreDataVocabularyProvider.swift
//  VocabMaster
//
//  Core Data implementation of VocabularyDataProvider
//

import Foundation
import CoreData

class CoreDataVocabularyProvider: VocabularyDataProvider {
    
    private let persistenceController: PersistenceController
    private var context: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }
    
    // MARK: - Word CRUD Operations
    
    func fetchWords(for category: CategoryType) async throws -> [VocabularyWord] {
        let fetchRequest: NSFetchRequest<WordEntity> = WordEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "categoryType == %@", category.rawValue)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "word", ascending: true)]
        
        return try await context.perform {
            let entities = try self.context.fetch(fetchRequest)
            return entities.map { $0.toVocabularyWord() }
        }
    }
    
    func fetchAllWords() async throws -> [VocabularyWord] {
        let fetchRequest: NSFetchRequest<WordEntity> = WordEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "categoryType", ascending: true),
                                        NSSortDescriptor(key: "word", ascending: true)]
        
        return try await context.perform {
            let entities = try self.context.fetch(fetchRequest)
            return entities.map { $0.toVocabularyWord() }
        }
    }
    
    func fetchWords(for category: CategoryType, language: Language) async throws -> [VocabularyWord] {
        let words = try await fetchWords(for: category)
        return words.filter { word in
            word.language == nil || word.language == language
        }
    }
    
    func fetchWord(id: String) async throws -> VocabularyWord {
        let fetchRequest: NSFetchRequest<WordEntity> = WordEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.fetchLimit = 1
        
        return try await context.perform {
            guard let entity = try self.context.fetch(fetchRequest).first else {
                throw DataProviderError.notFound
            }
            return entity.toVocabularyWord()
        }
    }
    
    func createWord(_ word: VocabularyWord, in category: CategoryType) async throws -> VocabularyWord {
        try await context.perform {
            let entity = WordEntity(context: self.context)
            entity.update(from: word, category: category)
            
            try self.context.save()
            return entity.toVocabularyWord()
        }
    }
    
    func createWords(_ words: [VocabularyWord], in category: CategoryType) async throws -> [VocabularyWord] {
        try await context.perform {
            var createdWords: [VocabularyWord] = []
            
            for word in words {
                let entity = WordEntity(context: self.context)
                entity.update(from: word, category: category)
                createdWords.append(entity.toVocabularyWord())
            }
            
            try self.context.save()
            return createdWords
        }
    }
    
    func updateWord(_ word: VocabularyWord, in category: CategoryType) async throws -> VocabularyWord {
        let fetchRequest: NSFetchRequest<WordEntity> = WordEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", word.id)
        fetchRequest.fetchLimit = 1
        
        return try await context.perform {
            guard let entity = try self.context.fetch(fetchRequest).first else {
                throw DataProviderError.notFound
            }
            
            entity.update(from: word, category: category)
            try self.context.save()
            return entity.toVocabularyWord()
        }
    }
    
    func deleteWord(id: String) async throws {
        let fetchRequest: NSFetchRequest<WordEntity> = WordEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        try await context.perform {
            let entities = try self.context.fetch(fetchRequest)
            for entity in entities {
                self.context.delete(entity)
            }
            
            // Also delete completion record
            let completedFetchRequest: NSFetchRequest<CompletedWordEntity> = CompletedWordEntity.fetchRequest()
            completedFetchRequest.predicate = NSPredicate(format: "wordId == %@", id)
            
            let completedEntities = try self.context.fetch(completedFetchRequest)
            for entity in completedEntities {
                self.context.delete(entity)
            }
            
            try self.context.save()
        }
    }
    
    func deleteWords(ids: [String]) async throws {
        let fetchRequest: NSFetchRequest<WordEntity> = WordEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id IN %@", ids)
        
        try await context.perform {
            let entities = try self.context.fetch(fetchRequest)
            for entity in entities {
                self.context.delete(entity)
            }
            
            // Also delete completion records
            let completedFetchRequest: NSFetchRequest<CompletedWordEntity> = CompletedWordEntity.fetchRequest()
            completedFetchRequest.predicate = NSPredicate(format: "wordId IN %@", ids)
            
            let completedEntities = try self.context.fetch(completedFetchRequest)
            for entity in completedEntities {
                self.context.delete(entity)
            }
            
            try self.context.save()
        }
    }
    
    func deleteAllWords(in category: CategoryType) async throws {
        let fetchRequest: NSFetchRequest<WordEntity> = WordEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "categoryType == %@", category.rawValue)
        
        try await context.perform {
            let entities = try self.context.fetch(fetchRequest)
            let ids = entities.map { $0.id }
            
            for entity in entities {
                self.context.delete(entity)
            }
            
            // Also delete completion records
            if !ids.isEmpty {
                let completedFetchRequest: NSFetchRequest<CompletedWordEntity> = CompletedWordEntity.fetchRequest()
                completedFetchRequest.predicate = NSPredicate(format: "wordId IN %@", ids)
                
                let completedEntities = try self.context.fetch(completedFetchRequest)
                for entity in completedEntities {
                    self.context.delete(entity)
                }
            }
            
            try self.context.save()
        }
    }
    
    // MARK: - Progress CRUD Operations
    
    func markWordCompleted(id: String) async throws {
        try await context.perform {
            // Check if already completed
            let fetchRequest: NSFetchRequest<CompletedWordEntity> = CompletedWordEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "wordId == %@", id)
            
            let existing = try self.context.fetch(fetchRequest)
            if existing.isEmpty {
                let entity = CompletedWordEntity(context: self.context)
                entity.wordId = id
                entity.completedDate = Date()
                
                try self.context.save()
            }
        }
    }
    
    func markWordIncomplete(id: String) async throws {
        let fetchRequest: NSFetchRequest<CompletedWordEntity> = CompletedWordEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "wordId == %@", id)
        
        try await context.perform {
            let entities = try self.context.fetch(fetchRequest)
            for entity in entities {
                self.context.delete(entity)
            }
            try self.context.save()
        }
    }
    
    func isWordCompleted(id: String) async throws -> Bool {
        let fetchRequest: NSFetchRequest<CompletedWordEntity> = CompletedWordEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "wordId == %@", id)
        fetchRequest.fetchLimit = 1
        
        return try await context.perform {
            let count = try self.context.count(for: fetchRequest)
            return count > 0
        }
    }
    
    func fetchCompletedWordIds() async throws -> Set<String> {
        let fetchRequest: NSFetchRequest<CompletedWordEntity> = CompletedWordEntity.fetchRequest()
        
        return try await context.perform {
            let entities = try self.context.fetch(fetchRequest)
            return Set(entities.map { $0.wordId })
        }
    }
    
    func fetchProgress(for category: CategoryType, language: Language) async throws -> (completed: Int, total: Int) {
        let words = try await fetchWords(for: category, language: language)
        let completedIds = try await fetchCompletedWordIds()
        
        let completedCount = words.filter { completedIds.contains($0.id) }.count
        return (completedCount, words.count)
    }
    
    // MARK: - Settings CRUD Operations
    
    func getCurrentLanguage() async throws -> Language {
        let settings = try await getSettings()
        return settings.currentLanguage
    }
    
    func setCurrentLanguage(_ language: Language) async throws {
        var settings = try await getSettings()
        settings.currentLanguage = language
        try await updateSettings(settings)
    }
    
    func getSettings() async throws -> AppSettings {
        let fetchRequest: NSFetchRequest<SettingsEntity> = SettingsEntity.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        return try await context.perform {
            if let entity = try self.context.fetch(fetchRequest).first,
               let language = Language(rawValue: entity.currentLanguage) {
                return AppSettings(currentLanguage: language)
            } else {
                // Create default settings
                let entity = SettingsEntity(context: self.context)
                entity.currentLanguage = Language.en.rawValue
                try self.context.save()
                return AppSettings(currentLanguage: .en)
            }
        }
    }
    
    func updateSettings(_ settings: AppSettings) async throws {
        let fetchRequest: NSFetchRequest<SettingsEntity> = SettingsEntity.fetchRequest()
        
        try await context.perform {
            let entity = try self.context.fetch(fetchRequest).first ?? SettingsEntity(context: self.context)
            entity.currentLanguage = settings.currentLanguage.rawValue
            try self.context.save()
        }
    }
    
    // MARK: - Batch Operations
    
    func importVocabulary(_ words: [VocabularyWord], category: CategoryType, replaceExisting: Bool) async throws {
        if replaceExisting {
            try await deleteAllWords(in: category)
        }
        
        _ = try await createWords(words, in: category)
    }
    
    func exportVocabulary() async throws -> [CategoryType: [VocabularyWord]] {
        var result: [CategoryType: [VocabularyWord]] = [:]
        
        for category in CategoryType.allCases {
            let words = try await fetchWords(for: category)
            result[category] = words
        }
        
        return result
    }
    
    func resetAllData() async throws {
        try await context.perform {
            // Delete all words
            let wordFetchRequest: NSFetchRequest<NSFetchRequestResult> = WordEntity.fetchRequest()
            let wordDeleteRequest = NSBatchDeleteRequest(fetchRequest: wordFetchRequest)
            try self.context.execute(wordDeleteRequest)
            
            // Delete all completed words
            let completedFetchRequest: NSFetchRequest<NSFetchRequestResult> = CompletedWordEntity.fetchRequest()
            let completedDeleteRequest = NSBatchDeleteRequest(fetchRequest: completedFetchRequest)
            try self.context.execute(completedDeleteRequest)
            
            // Reset settings
            let settingsFetchRequest: NSFetchRequest<NSFetchRequestResult> = SettingsEntity.fetchRequest()
            let settingsDeleteRequest = NSBatchDeleteRequest(fetchRequest: settingsFetchRequest)
            try self.context.execute(settingsDeleteRequest)
            
            try self.context.save()
        }
    }
}
