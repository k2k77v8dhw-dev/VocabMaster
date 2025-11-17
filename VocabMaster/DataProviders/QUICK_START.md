# Data Provider Quick Start Guide

## 🚀 Get Started in 60 Seconds

### Default Setup (Core Data)

The app works out of the box with Core Data! Just build and run.

```swift
// In AppConfiguration.swift (already configured)
static let dataProviderType: DataProviderType = .coreData
```

**That's it!** Your app is now using Core Data for local storage.

---

## 🔄 Switch to Different Provider

### Option 1: Mock Data (Testing)

Perfect for testing without setting up databases:

```swift
// In AppConfiguration.swift
static let dataProviderType: DataProviderType = .mock
```

**Rebuild app.** Now using in-memory mock data!

### Option 2: AWS Cloud Sync

For multi-device cloud sync:

**Step 1:** Set up AWS backend (see AWS_API_SPEC.md)

**Step 2:** Update configuration:
```swift
// In AppConfiguration.swift
static let dataProviderType: DataProviderType = .aws

struct AWS {
    static let baseURL = "https://YOUR-API-URL.com/v1"
    static let apiKey = "YOUR_API_KEY"
}
```

**Step 3:** Rebuild app. Now syncing to AWS!

---

## 📝 Common Tasks

### Add a New Word

```swift
// From anywhere in your app that has access to viewModel
let newWord = VocabularyWord(
    id: UUID().uuidString,
    word: "Innovation",
    definition: "The introduction of new ideas",
    example: "Innovation drives progress.",
    pronunciation: "/ˌɪnəˈveɪʃən/",
    language: .en,
    translationLanguage: .en
)

viewModel.addWord(newWord, to: .business)
```

### Fetch All Words

```swift
Task {
    let words = try await dataProvider.fetchWords(for: .business)
    print("Found \(words.count) business words")
}
```

### Delete Multiple Words

```swift
let idsToDelete = ["abc123", "def456", "ghi789"]
viewModel.deleteWords(ids: idsToDelete, from: .business)
```

### Mark Word as Completed

```swift
viewModel.completeWord("word-id-123")
```

### Get Progress

```swift
let (completed, total) = viewModel.getProgress(for: .business, language: .en)
print("\(completed)/\(total) words completed")
```

### Change Language

```swift
viewModel.setCurrentLanguage(.es) // Switch to Spanish
```

### Export All Vocabulary

```swift
Task {
    if let data = await viewModel.exportVocabulary() {
        for (category, words) in data {
            print("\(category.name): \(words.count) words")
        }
    }
}
```

### Import Vocabulary

```swift
let importedWords = [
    VocabularyWord(word: "Hello", definition: "A greeting", ...),
    VocabularyWord(word: "Goodbye", definition: "A farewell", ...),
]

viewModel.importVocabulary(importedWords, to: .daily, replaceExisting: false)
```

### Sync Data (Cloud Providers Only)

```swift
if viewModel.supportsSyncing {
    viewModel.syncData()
}
```

### Reset All Data

```swift
viewModel.resetAllData()
```

---

## 🧪 Testing

### Test with Mock Provider

```swift
// In your test file
class VocabularyTests: XCTestCase {
    
    func testWordCreation() async throws {
        let provider = MockVocabularyProvider()
        let viewModel = VocabularyViewModel(dataProvider: provider)
        
        let word = VocabularyWord(...)
        viewModel.addWord(word, to: .business)
        
        // Wait for async operation
        try await Task.sleep(nanoseconds: 200_000_000)
        
        let words = try await provider.fetchWords(for: .business)
        XCTAssertTrue(words.contains(where: { $0.id == word.id }))
    }
}
```

### SwiftUI Preview with Mock Data

```swift
struct VocabularyHomeView_Previews: PreviewProvider {
    static var previews: some View {
        VocabularyHomeView(...)
            .environmentObject(VocabularyViewModel(dataProvider: MockVocabularyProvider()))
    }
}
```

---

## 🔐 Environment-Specific Configuration

### Development

```swift
#if DEBUG
static let dataProviderType: DataProviderType = .mock
static let enableDebugLogging = true
#endif
```

### Staging

```swift
#if STAGING
static let dataProviderType: DataProviderType = .aws
struct AWS {
    static let baseURL = "https://staging-api.vocabmaster.com/v1"
}
#endif
```

### Production

```swift
#if !DEBUG && !STAGING
static let dataProviderType: DataProviderType = .coreData
static let enableAnalytics = true
#endif
```

---

## 🎯 Use Cases

### Use Case 1: Offline-First App

**Best choice:** Core Data

```swift
static let dataProviderType: DataProviderType = .coreData
```

**Benefits:**
- ✅ Works without internet
- ✅ Fast and reliable
- ✅ No backend costs

### Use Case 2: Multi-Device Sync

**Best choice:** AWS or Firebase

```swift
static let dataProviderType: DataProviderType = .aws
```

**Benefits:**
- ✅ Sync across devices
- ✅ Cloud backup
- ✅ User accounts
- ⚠️ Requires internet
- 💰 Backend costs

### Use Case 3: Rapid Prototyping

**Best choice:** Mock Provider

```swift
static let dataProviderType: DataProviderType = .mock
```

**Benefits:**
- ✅ No setup needed
- ✅ Pre-loaded data
- ✅ Fast development
- ⚠️ Data not persisted

---

## 🛠 Code Examples

### Create Custom Provider

```swift
class MyDatabaseProvider: VocabularyDataProvider {
    
    private let database: MyDatabase
    
    init(database: MyDatabase) {
        self.database = database
    }
    
    func fetchWords(for category: CategoryType) async throws -> [VocabularyWord] {
        return try await database.query("SELECT * FROM words WHERE category = ?", category.rawValue)
    }
    
    func createWord(_ word: VocabularyWord, in category: CategoryType) async throws -> VocabularyWord {
        try await database.insert(word, category: category)
        return word
    }
    
    // Implement other required methods...
}
```

### Use in App

```swift
// In VocabMasterApp.swift
init() {
    let myDatabase = MyDatabase()
    let provider = MyDatabaseProvider(database: myDatabase)
    _viewModel = StateObject(wrappedValue: VocabularyViewModel(dataProvider: provider))
}
```

---

## 📊 Performance Tips

### Batch Operations

```swift
// ❌ Slow - Multiple operations
for word in words {
    try await provider.createWord(word, in: category)
}

// ✅ Fast - Single batch operation
try await provider.createWords(words, in: category)
```

### Caching

```swift
// Cache expensive operations
private var cachedProgress: [CategoryType: (Int, Int)] = [:]

func getProgress(for category: CategoryType) -> (Int, Int) {
    if let cached = cachedProgress[category] {
        return cached
    }
    
    let progress = calculateProgress(for: category)
    cachedProgress[category] = progress
    return progress
}
```

---

## 🐛 Common Issues

### Issue: Data Not Saving

**Solution:** Check provider is initialized correctly

```swift
// Check which provider is being used
print("Using provider: \(type(of: viewModel.dataProvider))")
```

### Issue: App Crashes on Launch

**Solution:** Check Core Data model file exists

```swift
// Verify model file is included in target
// Xcode → File Inspector → Target Membership
```

### Issue: AWS Requests Failing

**Solution:** Verify configuration

```swift
print("API URL: \(AppConfiguration.AWS.baseURL)")
print("API Key: \(AppConfiguration.AWS.apiKey)")
```

### Issue: Changes Not Appearing

**Solution:** Ensure async operations complete

```swift
// Use Task to wait for completion
Task {
    await viewModel.addWord(word, to: category)
    // Word should now appear
}
```

---

## 📚 Next Steps

1. ✅ Choose your data provider
2. ✅ Update `AppConfiguration.swift`
3. ✅ Build and run
4. 📖 Read `IMPLEMENTATION_GUIDE.md` for deep dive
5. 📖 Read `AWS_API_SPEC.md` for AWS setup
6. 🚀 Build amazing features!

---

## 💡 Pro Tips

**Tip 1:** Use Mock provider during UI development
```swift
#if DEBUG
let provider = AppConfiguration.Debug.useMockProviderInDebug ? MockVocabularyProvider() : ...
#endif
```

**Tip 2:** Enable debug logging
```swift
struct Debug {
    static let logNetworkRequests = true
    static let logCoreDataOperations = true
}
```

**Tip 3:** Reset data for testing
```swift
#if DEBUG
if AppConfiguration.Debug.resetDataOnLaunch {
    await viewModel.resetAllData()
}
#endif
```

**Tip 4:** Test error scenarios
```swift
class FailingProvider: VocabularyDataProvider {
    func fetchWords(for category: CategoryType) async throws -> [VocabularyWord] {
        throw DataProviderError.networkError
    }
}

// Test error handling
let viewModel = VocabularyViewModel(dataProvider: FailingProvider())
```

---

## 🎉 You're Ready!

Your app now has a flexible, swappable data layer. Start building! 🚀

Need help? Check:
- `IMPLEMENTATION_GUIDE.md` - Complete guide
- `AWS_API_SPEC.md` - AWS backend setup
- `ARCHITECTURE.md` - System design
- `README.md` - Overview

Happy coding! 💻
