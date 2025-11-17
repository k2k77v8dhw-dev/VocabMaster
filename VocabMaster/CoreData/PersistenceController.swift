//
//  PersistenceController.swift
//  VocabMaster
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "VocabMaster")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error loading Core Data: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Preview Support
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // Add sample data for previews
        let sampleWord = WordEntity(context: viewContext)
        sampleWord.id = UUID().uuidString
        sampleWord.word = "Sample"
        sampleWord.definition = "An example"
        sampleWord.example = "This is a sample sentence."
        sampleWord.categoryType = "daily"
        sampleWord.language = "en"
        
        try? viewContext.save()
        return controller
    }()
    
    // MARK: - Save Context
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Error saving context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Delete All Data (for testing/reset)
    func deleteAllData() {
        let context = container.viewContext
        
        let entities = ["WordEntity", "CompletedWordEntity", "SettingsEntity"]
        
        for entity in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                try context.save()
            } catch {
                print("Error deleting \(entity): \(error)")
            }
        }
    }
}
