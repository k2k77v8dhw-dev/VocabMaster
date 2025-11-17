# VocabMaster Data Provider Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                          iOS Application                             │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │                    Presentation Layer                       │    │
│  │                      (SwiftUI Views)                        │    │
│  │                                                             │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │    │
│  │  │   Home View  │  │  Study View  │  │ Manage View  │    │    │
│  │  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘    │    │
│  │         │                 │                 │             │    │
│  │         └─────────────────┴─────────────────┘             │    │
│  │                           │                                │    │
│  └───────────────────────────┼────────────────────────────────┘    │
│                              │                                     │
│  ┌───────────────────────────▼────────────────────────────────┐    │
│  │                   Business Logic Layer                      │    │
│  │                  VocabularyViewModel                        │    │
│  │                                                             │    │
│  │  • State Management (@Published)                           │    │
│  │  • Business Logic                                           │    │
│  │  • UI Updates                                               │    │
│  │  • Error Handling                                           │    │
│  └───────────────────────────┬────────────────────────────────┘    │
│                              │                                     │
│  ┌───────────────────────────▼────────────────────────────────┐    │
│  │                    Abstraction Layer                        │    │
│  │              VocabularyDataProvider Protocol                │    │
│  │                                                             │    │
│  │  • CRUD Operations                                          │    │
│  │  • Progress Tracking                                        │    │
│  │  • Settings Management                                      │    │
│  │  • Batch Operations                                         │    │
│  │  • Sync Support                                             │    │
│  └─────────┬─────────────┬──────────────┬───────────┬─────────┘    │
│            │             │              │           │              │
│            ▼             ▼              ▼           ▼              │
│  ┌─────────────┐  ┌─────────┐  ┌──────────┐  ┌─────────┐         │
│  │  Core Data  │  │   AWS   │  │   Mock   │  │Firebase │         │
│  │  Provider   │  │Provider │  │ Provider │  │Provider │         │
│  └──────┬──────┘  └────┬────┘  └────┬─────┘  └────┬────┘         │
│         │              │            │             │               │
└─────────┼──────────────┼────────────┼─────────────┼───────────────┘
          │              │            │             │
          ▼              ▼            ▼             ▼
    ┌──────────┐   ┌──────────┐  ┌────────┐  ┌──────────┐
    │ SQLite   │   │   AWS    │  │Memory  │  │Firebase  │
    �� Database │   │   API    │  │ Array  │  │Firestore │
    └──────────┘   └──────────┘  └────────┘  └──────────┘
```

## Layer Breakdown

### 1. Presentation Layer (SwiftUI Views)

**Responsibility:** Display UI and capture user input

**Components:**
- `VocabularyHomeView` - Main screen with categories
- `FlashcardStudyView` - Study mode
- `ProgressView` - Statistics
- `ManageVocabularyView` - Word management
- `AddVocabularyWizardView` - Import wizard

**Key Characteristics:**
- ✅ No business logic
- ✅ Only UI state
- ✅ Reactive to ViewModel changes
- ✅ Sends actions to ViewModel

**Example:**
```swift
struct VocabularyHomeView: View {
    @EnvironmentObject var viewModel: VocabularyViewModel
    
    var body: some View {
        // UI only - no data logic
        List(viewModel.categories) { category in
            CategoryCard(category: category)
        }
    }
}
```

---

### 2. Business Logic Layer (ViewModel)

**Responsibility:** Manage app state and coordinate data operations

**File:** `VocabularyViewModel.swift`

**Key Properties:**
```swift
@Published var categories: [Category]
@Published var completedWords: Set<String>
@Published var currentLanguage: Language
@Published var isLoading: Bool
@Published var errorMessage: String?
```

**Key Methods:**
```swift
func loadData() async
func addWord(_ word: VocabularyWord, to category: CategoryType)
func updateWord(_ word: VocabularyWord, in category: CategoryType)
func deleteWords(ids: [String], from category: CategoryType)
func completeWord(_ wordId: String)
func setCurrentLanguage(_ language: Language)
```

**Key Characteristics:**
- ✅ ObservableObject for SwiftUI reactivity
- ✅ No knowledge of storage implementation
- ✅ Uses DataProvider protocol
- ✅ Handles async operations
- ✅ Manages UI state
- ✅ Error handling

**Dependencies:**
- DataProvider (protocol)
- Models (VocabularyWord, Category, etc.)

---

### 3. Abstraction Layer (Protocol)

**Responsibility:** Define data operations contract

**File:** `VocabularyDataProvider.swift`

**Protocol Definition:**
```swift
protocol VocabularyDataProvider {
    // Word Operations
    func fetchWords(for category: CategoryType) async throws -> [VocabularyWord]
    func createWord(_ word: VocabularyWord, in category: CategoryType) async throws -> VocabularyWord
    func updateWord(_ word: VocabularyWord, in category: CategoryType) async throws -> VocabularyWord
    func deleteWord(id: String) async throws
    func deleteWords(ids: [String]) async throws
    
    // Progress Operations
    func markWordCompleted(id: String) async throws
    func fetchCompletedWordIds() async throws -> Set<String>
    
    // Settings Operations
    func getCurrentLanguage() async throws -> Language
    func setCurrentLanguage(_ language: Language) async throws
    
    // Batch Operations
    func importVocabulary(_ words: [VocabularyWord], category: CategoryType, replaceExisting: Bool) async throws
    func exportVocabulary() async throws -> [CategoryType: [VocabularyWord]]
    
    // Sync Operations
    var supportsSyncing: Bool { get }
    func syncData() async throws
}
```

**Key Benefits:**
- ✅ Decouples business logic from storage
- ✅ Enables multiple implementations
- ✅ Testability (Mock implementation)
- ✅ Flexibility (swap backends)
- ✅ Consistent API

---

### 4. Implementation Layer (Providers)

#### A. Core Data Provider

**File:** `CoreDataVocabularyProvider.swift`

**Storage:** SQLite Database (via Core Data)

**Architecture:**
```
CoreDataVocabularyProvider
    ↓
PersistenceController
    ↓
NSManagedObjectContext
    ↓
NSPersistentContainer
    ↓
SQLite Database (VocabMaster.sqlite)
```

**Key Features:**
- ✅ Offline-first
- ✅ Fast local storage
- ✅ ACID transactions
- ✅ Relationships and indexing
- ✅ Automatic migration support

**Entities:**
- `WordEntity` - Vocabulary words
- `CompletedWordEntity` - Progress tracking
- `SettingsEntity` - User preferences

**Example:**
```swift
func createWord(_ word: VocabularyWord, in category: CategoryType) async throws -> VocabularyWord {
    try await context.perform {
        let entity = WordEntity(context: self.context)
        entity.update(from: word, category: category)
        try self.context.save()
        return entity.toVocabularyWord()
    }
}
```

#### B. AWS Provider

**File:** `AWSVocabularyProvider.swift`

**Storage:** AWS Cloud (API Gateway + Lambda + DynamoDB)

**Architecture:**
```
AWSVocabularyProvider
    ↓
URLSession (HTTPS)
    ↓
AWS API Gateway
    ↓
AWS Lambda Functions
    ↓
DynamoDB Tables
```

**Key Features:**
- ✅ Cloud sync
- ✅ Multi-device support
- ✅ Offline caching
- ✅ JWT authentication
- ✅ Scalable infrastructure

**API Endpoints:**
- `GET /api/v1/words?category={category}` - Fetch words
- `POST /api/v1/words` - Create word
- `PUT /api/v1/words/{id}` - Update word
- `DELETE /api/v1/words/{id}` - Delete word
- `GET /api/v1/progress` - Fetch progress
- `POST /api/v1/sync` - Sync data

**Example:**
```swift
func createWord(_ word: VocabularyWord, in category: CategoryType) async throws -> VocabularyWord {
    let request = Request(word: word, category: category.rawValue)
    let body = try JSONEncoder().encode(request)
    
    return try await makeRequest(
        endpoint: "/api/v1/words",
        method: "POST",
        body: body
    )
}
```

#### C. Mock Provider

**File:** `MockVocabularyProvider.swift`

**Storage:** In-Memory Arrays

**Architecture:**
```
MockVocabularyProvider
    ↓
In-Memory Dictionaries
[CategoryType: [VocabularyWord]]
```

**Key Features:**
- ✅ No setup required
- ✅ Pre-loaded data
- ✅ Network delay simulation
- ✅ Perfect for testing
- ✅ Fast and predictable

**Example:**
```swift
func createWord(_ word: VocabularyWord, in category: CategoryType) async throws -> VocabularyWord {
    // Simulate network delay
    try await Task.sleep(nanoseconds: 100_000_000)
    
    words[category, default: []].append(word)
    return word
}
```

#### D. Firebase Provider (Stub)

**File:** `FirebaseVocabularyProvider.swift`

**Status:** 🚧 Template implementation

**Planned Architecture:**
```
FirebaseVocabularyProvider
    ↓
Firebase SDK
    ↓
Cloud Firestore
```

**Potential Features:**
- Real-time sync
- Offline persistence
- Firebase Authentication
- Cloud Functions

---

## Data Flow Diagrams

### Create Word Flow

```
User Input
    ↓
SwiftUI View
    ↓
ViewModel.addWord()
    ↓
DataProvider.createWord()
    ↓
┌─────────────┬──────────────┬────────────┐
│  Core Data  │     AWS      │    Mock    │
│  Provider   │   Provider   │  Provider  │
└──────┬──────┴──────┬───────┴─────┬──────┘
       ↓             ↓             ↓
   Save to      POST to API   Add to Array
    SQLite         Gateway
       ↓             ↓             ↓
   Return        Return         Return
    Word          Word           Word
       ↓             ↓             ↓
       └─────────────┴─────────────┘
                    ↓
          Update ViewModel State
                    ↓
            UI Automatically Updates
```

### Fetch Words Flow

```
View Appears
    ↓
ViewModel.loadData()
    ↓
DataProvider.fetchWords(for: .business)
    ↓
┌─────────────┬──────────────┬────────────┐
│  Core Data  │     AWS      │    Mock    │
│  Provider   │   Provider   │  Provider  │
└──────┬────��─┴──────┬───────┴─────┬──────┘
       ↓             ↓             ↓
  Fetch from    GET from API  Return from
   Core Data      Gateway         Memory
       ↓             ↓             ↓
   Return        Return         Return
   [Words]       [Words]        [Words]
       ↓             ↓             ↓
       └─────────────┴─────────────┘
                    ↓
          Update ViewModel.categories
                    ↓
          UI Displays Categories
```

### Sync Flow (AWS Only)

```
User Triggers Sync
    ↓
ViewModel.syncData()
    ↓
AWSProvider.syncData()
    ↓
POST /api/v1/sync
    ↓
AWS Lambda Process Sync
    ↓
Compare lastSyncDate
    ↓
Return Changes
    ↓
Provider Updates Cache
    ↓
Provider Fetches Updated Data
    ↓
ViewModel Reloads
    ↓
UI Updates
```

---

## Configuration System

### AppConfiguration Structure

```swift
struct AppConfiguration {
    
    // MARK: - Provider Selection
    static let dataProviderType: DataProviderType = .coreData
    
    // MARK: - AWS Config
    struct AWS {
        static let baseURL = "https://api.example.com/v1"
        static let apiKey = "..."
        static let enableOfflineCache = true
        static let cacheExpirationTime: TimeInterval = 3600
    }
    
    // MARK: - Core Data Config
    struct CoreData {
        static let modelName = "VocabMaster"
        static let enableAutomaticMigration = true
    }
    
    // MARK: - Feature Flags
    struct Features {
        static let enableSync = true
        static let enableExportImport = true
        static let autoInitializeDefaultData = true
    }
    
    // MARK: - Debug Config
    struct Debug {
        static let logNetworkRequests = true
        static let useMockProviderInDebug = false
        static let resetDataOnLaunch = false
    }
}
```

### Factory Pattern

```swift
class DataProviderFactory {
    static func createProvider(type: DataProviderType) -> VocabularyDataProvider {
        switch type {
        case .coreData:
            return CoreDataVocabularyProvider(persistenceController: .shared)
        case .aws:
            return AWSVocabularyProvider()
        case .mock:
            return MockVocabularyProvider()
        case .firebase:
            return FirebaseVocabularyProvider()
        }
    }
    
    static func createConfiguredProvider() -> VocabularyDataProvider {
        #if DEBUG
        if AppConfiguration.Debug.useMockProviderInDebug {
            return MockVocabularyProvider()
        }
        #endif
        
        return createProvider(type: AppConfiguration.dataProviderType)
    }
}
```

---

## Design Patterns Used

### 1. Protocol-Oriented Programming
- `VocabularyDataProvider` protocol defines contract
- Multiple concrete implementations
- Enables polymorphism and testability

### 2. Factory Pattern
- `DataProviderFactory` creates providers
- Centralizes provider instantiation
- Supports runtime configuration

### 3. Repository Pattern
- Providers abstract data access
- ViewModel doesn't know storage details
- Clean separation of concerns

### 4. Strategy Pattern
- Different providers = different strategies
- Swappable at runtime or compile time
- Same interface, different implementation

### 5. Observer Pattern (via Combine)
- ViewModel publishes changes
- Views observe and react
- Automatic UI updates

### 6. Singleton Pattern
- `PersistenceController.shared`
- `DataProviderFactory` static methods
- Single source of truth

---

## Error Handling Strategy

### Error Types

```swift
enum DataProviderError: Error {
    case notFound
    case invalidData
    case saveFailed
    case deleteFailed
    case networkError
    case unauthorized
    case unknown(String)
}
```

### Error Flow

```
Provider throws DataProviderError
    ↓
ViewModel catches error
    ↓
Sets errorMessage property
    ↓
View displays error to user
```

### Example

```swift
// Provider
func fetchWords(for category: CategoryType) async throws -> [VocabularyWord] {
    guard networkAvailable else {
        throw DataProviderError.networkError
    }
    // ...
}

// ViewModel
func loadData() async {
    do {
        await loadVocabulary()
    } catch {
        errorMessage = "Failed to load: \(error.localizedDescription)"
    }
}

// View
if let error = viewModel.errorMessage {
    Text(error)
        .foregroundColor(.red)
}
```

---

## Performance Considerations

### 1. Async Operations
All provider methods use `async/await` to avoid blocking UI

### 2. Batch Operations
Bulk insert/delete supported for efficiency

### 3. Caching Strategy
AWS provider caches data locally for offline access

### 4. Lazy Loading
Only load data when needed

### 5. Core Data Optimizations
- Fetch request predicates
- Sort descriptors
- Batch size limits
- Background contexts for heavy operations

---

## Security Considerations

### Core Data
- ✅ Local encryption (iOS default)
- ✅ Sandboxed storage
- ✅ No network exposure

### AWS
- ✅ HTTPS only
- ✅ JWT authentication
- ✅ API key validation
- ✅ DynamoDB encryption
- ⚠️ Requires IAM setup
- ⚠️ Secure key storage needed

### Mock
- ⚠️ In-memory only
- ⚠️ Data not persisted
- ✅ Safe for testing

---

## Testing Strategy

### Unit Tests
```swift
func testCreateWord() async throws {
    let provider = MockVocabularyProvider()
    let word = VocabularyWord(...)
    
    let created = try await provider.createWord(word, in: .business)
    
    XCTAssertEqual(created.word, word.word)
}
```

### Integration Tests
```swift
func testViewModelWithProvider() async throws {
    let provider = MockVocabularyProvider()
    let viewModel = VocabularyViewModel(dataProvider: provider)
    
    viewModel.addWord(word, to: .business)
    
    try await Task.sleep(nanoseconds: 200_000_000)
    
    XCTAssertTrue(viewModel.categories[0].words.contains { $0.id == word.id })
}
```

### UI Tests
```swift
func testAddWordFlow() throws {
    let app = XCUIApplication()
    app.launch()
    
    app.buttons["Add"].tap()
    // ... test UI flow
}
```

---

## Scalability

### Core Data
- **Capacity:** Thousands to tens of thousands of words
- **Performance:** Excellent for local storage
- **Limit:** Single device, single user

### AWS
- **Capacity:** Unlimited (DynamoDB auto-scales)
- **Performance:** Dependent on network
- **Limit:** Cost increases with usage

### Mock
- **Capacity:** Hundreds of words (memory-based)
- **Performance:** Fastest (in-memory)
- **Limit:** Not for production

---

## Future Enhancements

### Planned Features
1. **Firebase Implementation** - Real-time sync
2. **CloudKit Provider** - Native Apple cloud sync
3. **SQL Database Provider** - Direct SQL access
4. **GraphQL Provider** - GraphQL backend support
5. **Realm Provider** - Realm database support

### Potential Improvements
1. **Conflict Resolution** - For multi-device sync
2. **Delta Sync** - Only sync changes
3. **Background Sync** - Sync in background
4. **Offline Queue** - Queue operations when offline
5. **Data Compression** - Reduce network usage
6. **Encryption** - End-to-end encryption

---

## Summary

This architecture provides:

✅ **Flexibility** - Swap backends easily
✅ **Testability** - Mock provider for testing
✅ **Scalability** - Supports different use cases
✅ **Maintainability** - Clean separation of concerns
✅ **Extensibility** - Easy to add new providers
✅ **Production Ready** - Battle-tested patterns
✅ **Well Documented** - Comprehensive docs
✅ **Type Safe** - Full Swift type safety

**Result:** A robust, professional data layer that can grow with your app! 🚀
