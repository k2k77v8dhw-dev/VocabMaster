# VocabMaster Data Provider System

## 🎯 Overview

This directory contains a **pluggable data provider architecture** that allows you to easily switch between different data backends (Core Data, AWS, Firebase, Mock, etc.) without changing any UI code.

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   VocabularyViewModel                   │
│              (Business Logic Layer)                     │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ VocabularyDataProvider Protocol
                     │
        ┌────────────┴─────────────┐
        │                          │
        ▼                          ▼
┌───────────────┐          ┌──────────────┐
│  Core Data    │          │  AWS REST    │
│  Provider     │          │  Provider    │
└───────────────┘          └──────────────┘
        │                          │
        ▼                          ▼
┌───────────────┐          ┌──────────────┐
│   SQLite      │          │  AWS API     │
│   Database    │          │  Gateway     │
└───────────────┘          └──────────────┘
```

## 📁 Files

### Core Protocol
- **`VocabularyDataProvider.swift`** - Protocol defining all CRUD operations
  - 40+ methods for complete vocabulary management
  - Async/await based API
  - Error handling with custom errors
  - Optional sync support

### Implementations
- **`CoreDataVocabularyProvider.swift`** - ✅ Local SQLite storage
  - Production-ready
  - Offline-first
  - Fast and reliable
  
- **`AWSVocabularyProvider.swift`** - ☁️ Cloud sync via AWS
  - REST API integration
  - JWT authentication
  - Offline caching
  - Multi-device sync
  
- **`MockVocabularyProvider.swift`** - 🧪 Testing and development
  - In-memory storage
  - Pre-loaded sample data
  - Network delay simulation
  - No setup required

- **`FirebaseVocabularyProvider.swift`** - 🚧 Stub (not implemented)
  - Template for Firebase integration
  - Real-time sync potential

### Configuration
- **`AppConfiguration.swift`** - Central configuration
  - Switch providers in one line
  - Environment-based configuration
  - Feature flags
  - API settings

### Documentation
- **`README.md`** - This file
- **`QUICK_START.md`** - Get started in 60 seconds
- **`IMPLEMENTATION_GUIDE.md`** - Complete implementation guide
- **`AWS_API_SPEC.md`** - REST API specification for AWS backend
- **`ARCHITECTURE.md`** - System architecture and design decisions

## 🚀 Quick Start

### 1. Choose Your Provider

Edit `/ios/Configuration/AppConfiguration.swift`:

```swift
// Change this single line to switch providers!
static let dataProviderType: DataProviderType = .coreData
```

Options:
- `.coreData` - Local database (default) ✅
- `.aws` - Cloud sync via AWS ☁️
- `.mock` - Testing/development 🧪
- `.firebase` - Firebase (requires implementation) 🚧

### 2. Build and Run

That's it! Your app now uses the selected provider.

## 📖 Documentation

### For Quick Setup
👉 **[QUICK_START.md](QUICK_START.md)** - Get running in 60 seconds

### For Complete Guide
👉 **[IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)** - Everything you need to know

### For AWS Backend
👉 **[AWS_API_SPEC.md](AWS_API_SPEC.md)** - REST API specification

### For Architecture Details
👉 **[ARCHITECTURE.md](ARCHITECTURE.md)** - Design decisions

## 🎯 Use Cases

### Local-Only App
```swift
static let dataProviderType: DataProviderType = .coreData
```
**Perfect for:** Single device, offline-first, privacy-focused apps

### Multi-Device Sync
```swift
static let dataProviderType: DataProviderType = .aws
```
**Perfect for:** Cloud backup, cross-device sync, user accounts

### Development/Testing
```swift
static let dataProviderType: DataProviderType = .mock
```
**Perfect for:** UI testing, demos, rapid prototyping

## 🔧 API Overview

### CRUD Operations

```swift
// Create
let word = try await provider.createWord(newWord, in: .business)

// Read
let words = try await provider.fetchWords(for: .business)
let word = try await provider.fetchWord(id: "abc123")

// Update
let updated = try await provider.updateWord(modifiedWord, in: .business)

// Delete
try await provider.deleteWord(id: "abc123")
try await provider.deleteWords(ids: ["abc", "def", "ghi"])
```

### Progress Tracking

```swift
// Mark completed
try await provider.markWordCompleted(id: "abc123")

// Get progress
let (completed, total) = try await provider.fetchProgress(for: .business, language: .en)

// Get all completed
let completedIds = try await provider.fetchCompletedWordIds()
```

### Settings

```swift
// Get/Set language
let language = try await provider.getCurrentLanguage()
try await provider.setCurrentLanguage(.es)

// Get/Update settings
let settings = try await provider.getSettings()
try await provider.updateSettings(updatedSettings)
```

### Batch Operations

```swift
// Bulk create
let created = try await provider.createWords(multipleWords, in: .business)

// Import
try await provider.importVocabulary(words, category: .business, replaceExisting: true)

// Export
let allData = try await provider.exportVocabulary()

// Sync (cloud providers only)
if provider.supportsSyncing {
    try await provider.syncData()
}
```

## 🎨 Custom Provider Example

Create your own provider in 3 steps:

### Step 1: Implement Protocol
```swift
class MyCustomProvider: VocabularyDataProvider {
    func fetchWords(for category: CategoryType) async throws -> [VocabularyWord] {
        // Your implementation
    }
    
    func createWord(_ word: VocabularyWord, in category: CategoryType) async throws -> VocabularyWord {
        // Your implementation
    }
    
    // ... implement all methods
}
```

### Step 2: Add to Factory
```swift
enum DataProviderType {
    case myCustom
    // ... existing cases
}

class DataProviderFactory {
    static func createProvider(type: DataProviderType) -> VocabularyDataProvider {
        switch type {
        case .myCustom:
            return MyCustomProvider()
        // ... existing cases
        }
    }
}
```

### Step 3: Use It
```swift
static let dataProviderType: DataProviderType = .myCustom
```

## 📊 Feature Comparison

| Feature | Core Data | AWS | Mock | Firebase |
|---------|-----------|-----|------|----------|
| Offline Support | ✅ | ⚠️ Cache | ✅ | ⚠️ Cache |
| Cloud Sync | ❌ | ✅ | ❌ | ✅ |
| Multi-Device | ❌ | ✅ | ❌ | ✅ |
| Setup Required | ✅ Done | 🔧 AWS Setup | ✅ Done | 🔧 Firebase Setup |
| Cost | Free | ~$20/mo | Free | Free tier |
| Performance | ⚡ Fast | 🌐 Network | ⚡ Fast | 🌐 Network |
| Data Ownership | ✅ Local | ☁️ Cloud | 💾 Memory | ☁️ Cloud |
| Authentication | ❌ | ✅ Cognito | ❌ | ✅ Firebase Auth |

## 🔒 Error Handling

All providers use consistent error types:

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

Handle errors gracefully:

```swift
do {
    let words = try await provider.fetchWords(for: .business)
} catch DataProviderError.networkError {
    print("Check internet connection")
} catch DataProviderError.unauthorized {
    print("Please log in again")
} catch {
    print("Something went wrong: \(error)")
}
```

## 🧪 Testing

### Unit Tests
```swift
func testProvider() async throws {
    let provider = MockVocabularyProvider()
    
    let word = VocabularyWord(...)
    let created = try await provider.createWord(word, in: .business)
    
    XCTAssertEqual(created.word, word.word)
}
```

### Integration Tests
```swift
func testViewModel() async throws {
    let provider = MockVocabularyProvider()
    let viewModel = VocabularyViewModel(dataProvider: provider)
    
    viewModel.addWord(word, to: .business)
    
    // Wait for async
    try await Task.sleep(nanoseconds: 100_000_000)
    
    XCTAssertFalse(viewModel.categories.isEmpty)
}
```

### Preview Support
```swift
struct MyView_Previews: PreviewProvider {
    static var previews: some View {
        MyView()
            .environmentObject(VocabularyViewModel(
                dataProvider: MockVocabularyProvider()
            ))
    }
}
```

## 🚀 Performance

### Batch Operations
```swift
// ❌ Slow - 10 network calls
for word in words {
    try await provider.createWord(word, in: category)
}

// ✅ Fast - 1 network call
try await provider.createWords(words, in: category)
```

### Caching
All cloud providers implement caching for offline support:
- Words cached per category
- Completed IDs cached
- Settings cached
- Cache updated on successful fetch

### Async Operations
All operations use async/await for:
- Non-blocking UI
- Easy error handling
- Clean code structure

## 📈 Scalability

### Core Data
- ✅ Thousands of words: Fast
- ✅ Tens of thousands: Good
- ⚠️ Hundreds of thousands: May need optimization

### AWS
- ✅ Unlimited words (DynamoDB scales automatically)
- ✅ Supports millions of users
- 💰 Cost increases with usage

### Mock
- ✅ Good for hundreds of words
- ⚠️ Memory-based, not for production

## 🛡 Security

### Core Data
- ✅ Data encrypted on device (iOS default)
- ✅ No network exposure
- ✅ User's data stays on device

### AWS
- ✅ HTTPS only
- ✅ JWT authentication
- ✅ API key validation
- ✅ DynamoDB encryption at rest
- ⚠️ Requires proper AWS IAM configuration

## 🔄 Migration

### Export from One Provider
```swift
let coreDataProvider = CoreDataVocabularyProvider(...)
let data = try await coreDataProvider.exportVocabulary()
```

### Import to Another Provider
```swift
let awsProvider = AWSVocabularyProvider()

for (category, words) in data {
    try await awsProvider.importVocabulary(
        words, 
        category: category, 
        replaceExisting: true
    )
}
```

### Switch Configuration
```swift
// Change from Core Data to AWS
static let dataProviderType: DataProviderType = .aws
```

## 📝 Best Practices

1. **Always use async/await** for provider methods
2. **Handle errors gracefully** - show user-friendly messages
3. **Use batch operations** when available
4. **Cache expensive operations** in ViewModel
5. **Test with Mock provider** during development
6. **Implement offline support** for cloud providers
7. **Validate data** before saving
8. **Monitor performance** with Instruments

## 🎓 Learning Resources

### Beginner
- Start with Core Data provider
- Read QUICK_START.md
- Try Mock provider for testing

### Intermediate
- Implement custom provider
- Read IMPLEMENTATION_GUIDE.md
- Optimize performance

### Advanced
- Set up AWS backend
- Read AWS_API_SPEC.md
- Implement Firebase provider
- Build custom sync logic

## 🤝 Contributing

Want to add a new provider?

1. Implement `VocabularyDataProvider` protocol
2. Add to `DataProviderFactory`
3. Update documentation
4. Add tests
5. Submit PR!

## 📞 Support

- **Quick questions:** Check QUICK_START.md
- **Implementation:** Read IMPLEMENTATION_GUIDE.md
- **AWS setup:** See AWS_API_SPEC.md
- **Architecture:** Review ARCHITECTURE.md

## 🎉 Summary

You now have a **production-ready, flexible data layer** that:

- ✅ Supports multiple backends
- ✅ Switches with one line of code
- ✅ Handles all CRUD operations
- ✅ Includes progress tracking
- ✅ Manages settings
- ✅ Provides batch operations
- ✅ Supports offline mode
- ✅ Enables cloud sync
- ✅ Ready for testing
- ✅ Scales to production

**Ready to build something amazing!** 🚀

