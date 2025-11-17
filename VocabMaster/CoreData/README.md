# Core Data Setup for VocabMaster

## Overview
This app uses Core Data to persist vocabulary words, progress tracking, and user settings.

## Data Model

The Core Data model (`VocabMaster.xcdatamodel`) contains three entities:

### 1. WordEntity
Stores individual vocabulary words.

**Attributes:**
- `id` (String) - Unique identifier
- `word` (String) - The vocabulary word
- `definition` (String) - Word definition
- `example` (String) - Example sentence
- `pronunciation` (String, Optional) - IPA pronunciation
- `language` (String, Optional) - Source language code (e.g., "en", "es")
- `translationLanguage` (String, Optional) - Translation language code
- `categoryType` (String) - Category (business, travel, daily, academic)

### 2. CompletedWordEntity
Tracks which words the user has marked as learned.

**Attributes:**
- `wordId` (String) - Reference to WordEntity.id
- `completedDate` (Date) - When the word was completed

### 3. SettingsEntity
Stores app settings.

**Attributes:**
- `currentLanguage` (String) - Currently selected language

## Core Data Model Setup in Xcode

### Creating the .xcdatamodel file:

1. In Xcode, **File** → **New** → **File**
2. Select **Data Model** under Core Data
3. Name it `VocabMaster.xcdatamodel`
4. Click **Create**

### Adding Entities:

#### WordEntity:
1. Click "Add Entity" button
2. Rename to `WordEntity`
3. Add attributes (click + in Attributes section):
   - `id` → Type: String
   - `word` → Type: String
   - `definition` → Type: String
   - `example` → Type: String
   - `pronunciation` → Type: String, Optional: ✓
   - `language` → Type: String, Optional: ✓
   - `translationLanguage` → Type: String, Optional: ✓
   - `categoryType` → Type: String

#### CompletedWordEntity:
1. Click "Add Entity" button
2. Rename to `CompletedWordEntity`
3. Add attributes:
   - `wordId` → Type: String
   - `completedDate` → Type: Date

#### SettingsEntity:
1. Click "Add Entity" button
2. Rename to `SettingsEntity`
3. Add attributes:
   - `currentLanguage` → Type: String

### Code Generation Settings:

For each entity, select it and in the Data Model Inspector:
- **Codegen**: Manual/None (we have custom classes in CoreDataEntities.swift)
- **Module**: Current Product Module

## Files Structure

```
CoreData/
├── VocabMaster.xcdatamodel/     # Core Data model file
│   └── contents/
├── PersistenceController.swift   # Core Data stack manager
├── CoreDataEntities.swift        # Entity class definitions
└── README.md                     # This file
```

## Usage

### Initialization
The `PersistenceController` is initialized in `VocabMasterApp.swift` and passed to the `VocabularyViewModel`.

### Default Data
On first launch, if no data exists, the app automatically populates Core Data with default vocabulary from `VocabularyData.swift`.

### Data Flow
1. **VocabularyViewModel** manages all Core Data operations
2. All CRUD operations go through the ViewModel
3. Changes are immediately persisted to Core Data
4. The ViewModel publishes updates to SwiftUI views

### Key Operations

**Load Data:**
```swift
loadVocabularyFromCoreData() // Fetches all words
loadCompletedWords()         // Fetches progress
loadSettings()               // Fetches user preferences
```

**Add Word:**
```swift
viewModel.addWord(word, to: category)
```

**Update Word:**
```swift
viewModel.updateWord(updatedWord, in: category)
```

**Delete Words:**
```swift
viewModel.deleteWords(ids: ["id1", "id2"], from: category)
```

**Track Progress:**
```swift
viewModel.completeWord(wordId)
```

## Data Persistence

- All data is automatically saved to Core Data
- Data persists across app launches
- Located in app's Documents directory
- Survives app updates

## Testing & Debugging

### Reset All Data:
```swift
PersistenceController.shared.deleteAllData()
```

### Preview Support:
A preview controller with sample data is available for SwiftUI previews:
```swift
.environmentObject(VocabularyViewModel(persistenceController: .preview))
```

## Migration

If you need to modify the data model in the future:
1. Select the .xcdatamodel file
2. Editor → Add Model Version
3. Make changes to the new version
4. Set it as current version
5. Implement migration if needed (for complex changes)

## Troubleshooting

**"Could not find model named VocabMaster"**
- Ensure VocabMaster.xcdatamodel is added to your target
- Check the model name matches in PersistenceController

**Data not persisting:**
- Check `persistenceController.save()` is called after changes
- Verify NSManagedObjectContext is not nil
- Check for Core Data errors in console

**Duplicate words appearing:**
- Ensure word IDs are unique
- Check fetch requests for proper predicates

## Best Practices

1. Always save context after making changes
2. Use fetch requests with predicates for filtering
3. Handle errors gracefully (don't use fatalError in production)
4. Test migration before updating data model
5. Keep entities simple and normalized
