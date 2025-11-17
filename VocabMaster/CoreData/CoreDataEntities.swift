//
//  CoreDataEntities.swift
//  VocabMaster
//

import CoreData

// MARK: - WordEntity
@objc(WordEntity)
public class WordEntity: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var word: String
    @NSManaged public var definition: String
    @NSManaged public var example: String
    @NSManaged public var pronunciation: String?
    @NSManaged public var language: String?
    @NSManaged public var translationLanguage: String?
    @NSManaged public var categoryType: String
}

extension WordEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WordEntity> {
        return NSFetchRequest<WordEntity>(entityName: "WordEntity")
    }
    
    // Convert to VocabularyWord model
    func toVocabularyWord() -> VocabularyWord {
        return VocabularyWord(
            id: id,
            word: word,
            definition: definition,
            example: example,
            pronunciation: pronunciation,
            language: language.flatMap { Language(rawValue: $0) },
            translationLanguage: translationLanguage.flatMap { Language(rawValue: $0) }
        )
    }
    
    // Update from VocabularyWord model
    func update(from vocabularyWord: VocabularyWord, category: CategoryType) {
        self.id = vocabularyWord.id
        self.word = vocabularyWord.word
        self.definition = vocabularyWord.definition
        self.example = vocabularyWord.example
        self.pronunciation = vocabularyWord.pronunciation
        self.language = vocabularyWord.language?.rawValue
        self.translationLanguage = vocabularyWord.translationLanguage?.rawValue
        self.categoryType = category.rawValue
    }
}

// MARK: - CompletedWordEntity
@objc(CompletedWordEntity)
public class CompletedWordEntity: NSManagedObject {
    @NSManaged public var wordId: String
    @NSManaged public var completedDate: Date
}

extension CompletedWordEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CompletedWordEntity> {
        return NSFetchRequest<CompletedWordEntity>(entityName: "CompletedWordEntity")
    }
}

// MARK: - SettingsEntity
@objc(SettingsEntity)
public class SettingsEntity: NSManagedObject {
    @NSManaged public var currentLanguage: String
}

extension SettingsEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SettingsEntity> {
        return NSFetchRequest<SettingsEntity>(entityName: "SettingsEntity")
    }
}
