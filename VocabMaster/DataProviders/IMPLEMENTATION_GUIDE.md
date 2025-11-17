# Data Provider Implementation Guide

## Overview

This guide explains how to implement and switch between different data backends for VocabMaster.

## Architecture

```
┌─────────────────────────────────┐
│     VocabularyViewModel         │
│  (SwiftUI @ObservableObject)    │
└────────────┬────────────────────┘
             │
             │ uses
             ▼
┌─────────────────────────────────┐
│  VocabularyDataProvider         │
│      (Protocol)                 │
└────────────┬────────────────────┘
             │
             │ implements
             ▼
┌────────────────────────────────────────────────┐
│   ┌──────────────────┐  ┌──────────────────┐  │
│   │ CoreData Provider│  │   AWS Provider   │  │
│   └──────────────────┘  └──────────────────┘  │
│   ┌──────────────────┐  ┌──────────────────┐  │
│   │  Mock Provider   │  │Firebase Provider │  │
│   └──────────────────┘  └──────────────────┘  │
└────────────────────────────────────────────────┘
```

## Quick Start

### 1. Choose Your Provider

Edit `/ios/Configuration/AppConfiguration.swift`:

```swift
struct AppConfiguration {
    // Change this to switch providers
    static let dataProviderType: DataProviderType = .coreData  // or .aws, .mock, .firebase
}
```

### 2. Provider Options

| Provider | Use Case | Setup Required |
|----------|----------|----------------|
| **CoreData** | Local storage, offline-first | ✅ Ready to use |
| **AWS** | Cloud sync, multi-device | AWS account + API setup |
| **Mock** | Testing, development | ✅ Ready to use |
| **Firebase** | Rapid prototyping | Firebase project setup |

## Detailed Implementation

### Option 1: Core Data (Default) ✅

**Best for:** Single device, offline-first apps

**Setup:**
1. Already configured! Just use it.
2. Data stored locally in SQLite database
3. No internet required
4. Fast and reliable

**Configuration:**
```swift
// In AppConfiguration.swift
static let dataProviderType: DataProviderType = .coreData
```

**Features:**
- ✅ Full CRUD operations
- ✅ Offline support
- ✅ Fast performance
- ❌ No cloud sync
- ❌ Single device only

---

### Option 2: AWS REST API

**Best for:** Multi-device sync, cloud backup

**Step 1: Set up AWS Backend**

Follow the complete AWS setup in `AWS_API_SPEC.md`. Summary:

1. Create AWS account
2. Set up DynamoDB tables
3. Create Lambda functions
4. Configure API Gateway
5. Set up Cognito authentication

**Step 2: Configure the Provider**

```swift
// In AppConfiguration.swift
static let dataProviderType: DataProviderType = .aws

struct AWS {
    static let baseURL = "https://YOUR-API-ID.execute-api.us-east-1.amazonaws.com/v1"
    static let apiKey = "YOUR_AWS_API_KEY"
}
```

**Step 3: Handle Authentication**

```swift
// In AWSVocabularyProvider
func authenticate(username: String, password: String) async throws {
    // Implement Cognito authentication
    // Store JWT token
}
```

**Features:**
- ✅ Cloud sync
- ✅ Multi-device support
- ✅ Automatic backups
- ✅ User accounts
- ❌ Requires internet
- ⚠️ Costs money (see AWS_API_SPEC.md for pricing)

---

### Option 3: Mock Provider (Testing)

**Best for:** Development, testing, demos

**Setup:**
```swift
// In AppConfiguration.swift
static let dataProviderType: DataProviderType = .mock

// Or in Debug configuration:
struct Debug {
    static let useMockProviderInDebug = true
}
```

**Features:**
- ✅ No setup required
- ✅ Pre-loaded with sample data
- ✅ Simulates network delays
- ✅ Perfect for UI testing
- ❌ Data lost on app restart
- ❌ In-memory only

**Usage:**
```swift
// Create with custom data
let mockProvider = MockVocabularyProvider()
let viewModel = VocabularyViewModel(dataProvider: mockProvider)
```

---

### Option 4: Firebase (Future)

**Best for:** Rapid prototyping, real-time sync

**Setup:**
1. Create Firebase project
2. Add iOS app in Firebase console
3. Download `GoogleService-Info.plist`
4. Install Firebase SDK via SPM
5. Implement `FirebaseVocabularyProvider`

**Configuration:**
```swift
// In AppConfiguration.swift
static let dataProviderType: DataProviderType = .firebase

struct Firebase {
    static let projectId = "vocabmaster-app"
}
```

**Status:** 🚧 Stub implementation provided, needs completion

---

## How to Switch Providers

### Method 1: Static Configuration (Recommended)

**When to use:** Production apps, single backend

```swift
// In AppConfiguration.swift
static let dataProviderType: DataProviderType = .coreData
```

Rebuild the app and all data operations will use the new provider.

### Method 2: Runtime Selection

**When to use:** Testing, feature flags, A/B testing

```swift
// In VocabMasterApp.swift
init() {
    let providerType: DataProviderType
    
    if UserDefaults.standard.bool(forKey: "useCloudSync") {
        providerType = .aws
    } else {
        providerType = .coreData
    }
    
    let provider = DataProviderFactory.createProvider(type: providerType)
    _viewModel = StateObject(wrappedValue: VocabularyViewModel(dataProvider: provider))
}
```

### Method 3: Environment-Based

**When to use:** Different backends for dev/staging/production

```swift
// In AppConfiguration.swift
static var dataProviderType: DataProviderType {
    #if DEBUG
    return .mock
    #elseif STAGING
    return .aws
    #else
    return .coreData
    #endif
}
```

---

## Creating a Custom Provider

### Step 1: Implement the Protocol

```swift
class MyCustomProvider: VocabularyDataProvider {
    
    // MARK: - Required Methods
    
    func fetchWords(for category: CategoryType) async throws -> [VocabularyWord] {
        // Your implementation
    }
    
    func createWord(_ word: VocabularyWord, in category: CategoryType) async throws -> VocabularyWord {
        // Your implementation
    }
    
    // ... implement all protocol methods
}
```

### Step 2: Add to Factory

```swift
// In VocabularyDataProvider.swift
enum DataProviderType {
    case coreData
    case aws
    case myCustomProvider  // Add this
}

class DataProviderFactory {
    static func createProvider(type: DataProviderType) -> VocabularyDataProvider {
        switch type {
        case .coreData:
            return CoreDataVocabularyProvider(persistenceController: .shared)
        case .aws:
            return AWSVocabularyProvider()
        case .myCustomProvider:
            return MyCustomProvider()  // Add this
        }
    }
}
```

### Step 3: Use It

```swift
// In AppConfiguration.swift
static let dataProviderType: DataProviderType = .myCustomProvider
```

---

## API Reference

### Core CRUD Operations

All providers must implement these methods:

#### Fetch Operations
```swift
// Fetch words by category
func fetchWords(for category: CategoryType) async throws -> [VocabularyWord]

// Fetch all words
func fetchAllWords() async throws -> [VocabularyWord]

// Fetch words with language filter
func fetchWords(for category: CategoryType, language: Language) async throws -> [VocabularyWord]

// Fetch single word
func fetchWord(id: String) async throws -> VocabularyWord
```

#### Create Operations
```swift
// Create single word
func createWord(_ word: VocabularyWord, in category: CategoryType) async throws -> VocabularyWord

// Bulk create
func createWords(_ words: [VocabularyWord], in category: CategoryType) async throws -> [VocabularyWord]
```

#### Update Operations
```swift
// Update word
func updateWord(_ word: VocabularyWord, in category: CategoryType) async throws -> VocabularyWord
```

#### Delete Operations
```swift
// Delete single word
func deleteWord(id: String) async throws

// Bulk delete
func deleteWords(ids: [String]) async throws

// Delete all in category
func deleteAllWords(in category: CategoryType) async throws
```

#### Progress Operations
```swift
// Mark completed
func markWordCompleted(id: String) async throws

// Mark incomplete
func markWordIncomplete(id: String) async throws

// Check completion
func isWordCompleted(id: String) async throws -> Bool

// Get all completed IDs
func fetchCompletedWordIds() async throws -> Set<String>

// Get progress stats
func fetchProgress(for category: CategoryType, language: Language) async throws -> (completed: Int, total: Int)
```

#### Settings Operations
```swift
// Get current language
func getCurrentLanguage() async throws -> Language

// Set language
func setCurrentLanguage(_ language: Language) async throws

// Get all settings
func getSettings() async throws -> AppSettings

// Update settings
func updateSettings(_ settings: AppSettings) async throws
```

#### Batch Operations
```swift
// Import vocabulary
func importVocabulary(_ words: [VocabularyWord], category: CategoryType, replaceExisting: Bool) async throws

// Export all
func exportVocabulary() async throws -> [CategoryType: [VocabularyWord]]

// Reset everything
func resetAllData() async throws
```

#### Sync Operations (Optional)
```swift
// Check if syncing is supported
var supportsSyncing: Bool { get }

// Sync data with remote
func syncData() async throws
```

---

## Testing

### Unit Testing

```swift
import XCTest

class VocabularyProviderTests: XCTestCase {
    
    func testCoreDataProvider() async throws {
        let provider = CoreDataVocabularyProvider(persistenceController: .preview)
        
        // Create word
        let word = VocabularyWord(...)
        let created = try await provider.createWord(word, in: .business)
        
        XCTAssertEqual(created.word, word.word)
        
        // Fetch word
        let fetched = try await provider.fetchWord(id: created.id)
        XCTAssertEqual(fetched.id, created.id)
    }
    
    func testMockProvider() async throws {
        let provider = MockVocabularyProvider()
        
        let words = try await provider.fetchWords(for: .business)
        XCTAssertFalse(words.isEmpty)
    }
}
```

### Integration Testing

```swift
func testProviderWithViewModel() async throws {
    let provider = MockVocabularyProvider()
    let viewModel = VocabularyViewModel(dataProvider: provider)
    
    // Wait for data to load
    try await Task.sleep(nanoseconds: 500_000_000)
    
    XCTAssertFalse(viewModel.categories.isEmpty)
}
```

---

## Error Handling

All providers throw `DataProviderError`:

```swift
do {
    let words = try await provider.fetchWords(for: .business)
} catch DataProviderError.notFound {
    print("No words found")
} catch DataProviderError.networkError {
    print("Network error - check connection")
} catch DataProviderError.unauthorized {
    print("Authentication failed")
} catch {
    print("Unknown error: \(error)")
}
```

### Common Error Scenarios

| Error | Cause | Solution |
|-------|-------|----------|
| `.notFound` | Word/data doesn't exist | Check ID is correct |
| `.invalidData` | Malformed data | Validate before saving |
| `.saveFailed` | Couldn't save to storage | Check permissions, disk space |
| `.networkError` | Network unavailable | Check internet, retry |
| `.unauthorized` | Invalid credentials | Re-authenticate |

---

## Performance Optimization

### Caching Strategy

```swift
class CachedProvider: VocabularyDataProvider {
    private var cache: [CategoryType: [VocabularyWord]] = [:]
    private let underlying: VocabularyDataProvider
    
    func fetchWords(for category: CategoryType) async throws -> [VocabularyWord] {
        // Check cache first
        if let cached = cache[category] {
            return cached
        }
        
        // Fetch from underlying provider
        let words = try await underlying.fetchWords(for: category)
        
        // Update cache
        cache[category] = words
        
        return words
    }
}
```

### Batch Operations

Always prefer batch operations when available:

```swift
// ❌ Slow - Multiple network calls
for word in words {
    try await provider.createWord(word, in: category)
}

// ✅ Fast - Single network call
try await provider.createWords(words, in: category)
```

---

## Migration Guide

### From Core Data to AWS

**Step 1: Export existing data**
```swift
let coreDataProvider = CoreDataVocabularyProvider(persistenceController: .shared)
let allData = try await coreDataProvider.exportVocabulary()
```

**Step 2: Import to AWS**
```swift
let awsProvider = AWSVocabularyProvider()

for (category, words) in allData {
    try await awsProvider.importVocabulary(words, category: category, replaceExisting: true)
}
```

**Step 3: Update configuration**
```swift
// In AppConfiguration.swift
static let dataProviderType: DataProviderType = .aws
```

### From AWS to Core Data (Backup)

Same process in reverse - use export/import methods.

---

## Best Practices

### 1. Always Use Async/Await
```swift
// ✅ Correct
Task {
    do {
        let words = try await provider.fetchWords(for: .business)
        // Update UI
    } catch {
        // Handle error
    }
}
```

### 2. Handle Errors Gracefully
```swift
// ✅ Show user-friendly messages
catch {
    viewModel.errorMessage = "Couldn't load vocabulary. Please try again."
}
```

### 3. Use Batch Operations
```swift
// ✅ Delete multiple at once
try await provider.deleteWords(ids: selectedIds)

// ❌ Don't delete one by one
for id in selectedIds {
    try await provider.deleteWord(id: id)
}
```

### 4. Test with Mock Provider
```swift
#if DEBUG
let provider = MockVocabularyProvider()
#else
let provider = DataProviderFactory.createConfiguredProvider()
#endif
```

### 5. Implement Offline Support for Cloud Providers
```swift
class AWSVocabularyProvider {
    private var cache: [CategoryType: [VocabularyWord]] = [:]
    
    func fetchWords(for category: CategoryType) async throws -> [VocabularyWord] {
        do {
            let words = try await makeRequest(...)
            cache[category] = words
            return words
        } catch DataProviderError.networkError {
            // Return cached data if available
            if let cached = cache[category] {
                return cached
            }
            throw DataProviderError.networkError
        }
    }
}
```

---

## Troubleshooting

### Provider Not Working

**Check 1: Correct type in configuration**
```swift
print(AppConfiguration.dataProviderType)  // Should show your intended provider
```

**Check 2: Provider initialized correctly**
```swift
// In VocabMasterApp
init() {
    let provider = DataProviderFactory.createConfiguredProvider()
    print("Using provider: \(type(of: provider))")  // Check which provider
}
```

**Check 3: Network configuration (for AWS)**
```swift
print(AppConfiguration.AWS.baseURL)
print(AppConfiguration.AWS.apiKey)
```

### Data Not Syncing

**For AWS Provider:**
1. Check internet connection
2. Verify API key is valid
3. Check authentication token
4. Enable network logging:
   ```swift
   AppConfiguration.Debug.logNetworkRequests = true
   ```

### Performance Issues

1. **Use batch operations** for multiple items
2. **Enable caching** for cloud providers
3. **Implement pagination** for large datasets
4. **Profile with Instruments** to find bottlenecks

---

## Summary

| Task | Command |
|------|---------|
| **Switch provider** | Edit `AppConfiguration.dataProviderType` |
| **Use Core Data** | `.coreData` (default) |
| **Use AWS** | `.aws` + configure AWS settings |
| **Use Mock** | `.mock` or set debug flag |
| **Create custom** | Implement `VocabularyDataProvider` protocol |
| **Test provider** | Use `MockVocabularyProvider()` |
| **Export data** | `provider.exportVocabulary()` |
| **Import data** | `provider.importVocabulary()` |

---

## Next Steps

1. ✅ Review `VocabularyDataProvider.swift` protocol
2. ✅ Check `CoreDataVocabularyProvider.swift` implementation
3. 📖 Read `AWS_API_SPEC.md` for AWS setup
4. 📖 Read `QUICK_START.md` for quick examples
5. 🚀 Build your app and test!

