# OpenAI Integration Guide

Complete guide for integrating OpenAI API into VocabMaster iOS app.

## 📋 Table of Contents

- [Overview](#overview)
- [Setup](#setup)
- [Features](#features)
- [Usage](#usage)
- [API Reference](#api-reference)
- [Error Handling](#error-handling)
- [Best Practices](#best-practices)

---

## Overview

The OpenAI integration provides powerful AI capabilities for VocabMaster:

- **Automatic Translation**: GPT-4 powered translation between 10 languages
- **Sentence Breakdown**: Intelligent text parsing and translation
- **OCR (Image to Text)**: Extract text from images using GPT-4 Vision
- **Vocabulary Generation**: Auto-generate definitions, examples, and pronunciation
- **Smart Extraction**: Extract key vocabulary words from passages

## Setup

### 1. Get Your OpenAI API Key

1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Sign up or log in
3. Navigate to [API Keys](https://platform.openai.com/api-keys)
4. Click "Create new secret key"
5. Copy your API key (starts with `sk-`)

### 2. Configure the App

**Option A: Environment Variable (Recommended for Development)**

```bash
# Add to your ~/.zshrc or ~/.bash_profile
export OPENAI_API_KEY="sk-your-api-key-here"
```

**Option B: Direct Configuration (For Testing Only)**

Edit `/ios/Configuration/AppConfiguration.swift`:

```swift
struct OpenAI {
    static var apiKey: String {
        #if DEBUG
        return "sk-your-api-key-here"  // Replace with your key
        #else
        return ""
        #endif
    }
}
```

**Option C: Keychain (Recommended for Production)**

Implement the `KeychainHelper` methods in `AppConfiguration.swift`:

```swift
class KeychainHelper {
    static func getOpenAIKey() -> String? {
        // Implement keychain retrieval
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "OpenAIAPIKey",
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return key
    }
    
    static func setOpenAIKey(_ key: String) -> Bool {
        guard let data = key.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "OpenAIAPIKey",
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        
        return status == errSecSuccess
    }
}
```

### 3. Enable Features

In `AppConfiguration.swift`, ensure these are set to `true`:

```swift
struct OpenAI {
    static let enableTranslation = true
    static let enableOCR = true
    static let enableVocabularyGeneration = true
}
```

### 4. Replace the Wizard View

**Method 1: Replace Completely**

Rename your current `AddVocabularyWizardView.swift` and rename `AddVocabularyWizardView-OpenAI.swift` to `AddVocabularyWizardView.swift`.

**Method 2: Gradual Integration**

Add AI features to your existing view by copying the relevant functions from `AddVocabularyWizardView-OpenAI.swift`.

---

## Features

### 1. Text Translation

Translate text from one language to another:

```swift
let translation = try await OpenAIService.shared.translate(
    text: "Hello, how are you?",
    from: .en,
    to: .es
)
// Result: "Hola, ¿cómo estás?"
```

### 2. Sentence Breakdown & Translation

Break text into sentences and translate each:

```swift
let results = try await OpenAIService.shared.breakdownAndTranslate(
    text: "Hello. How are you? I'm learning Spanish.",
    from: .en,
    to: .es
)
// Results:
// [
//   (original: "Hello", translation: "Hola"),
//   (original: "How are you?", translation: "¿Cómo estás?"),
//   (original: "I'm learning Spanish", translation: "Estoy aprendiendo español")
// ]
```

### 3. OCR (Image to Text)

Extract text from images:

```swift
let extractedText = try await OpenAIService.shared.extractTextFromImage(
    uiImage,
    sourceLanguage: .en
)
```

### 4. OCR + Translation

Extract and translate in one step:

```swift
let results = try await OpenAIService.shared.extractAndTranslateFromImage(
    uiImage,
    sourceLanguage: .en,
    targetLanguage: .es
)
```

### 5. Vocabulary Word Generation

Generate complete vocabulary entries:

```swift
let vocabWord = try await OpenAIService.shared.generateVocabularyWord(
    word: "serendipity",
    sourceLanguage: .en,
    targetLanguage: .es
)
// Result includes:
// - translation
// - definition
// - example sentence
// - pronunciation (IPA)
```

### 6. Smart Vocabulary Extraction

Extract important words from a passage:

```swift
let vocabulary = try await OpenAIService.shared.extractVocabulary(
    from: longTextPassage,
    sourceLanguage: .en,
    targetLanguage: .es,
    difficulty: .intermediate
)
```

---

## Usage

### In the Vocabulary Wizard

1. **Select Import Method**: Choose "Paste Text" or "Search Image"
2. **For Text**: Paste your content and select languages
3. **For Images**: 
   - Select an image from your library
   - OCR will automatically extract text
4. **Process**: Click "Translate with AI"
5. **Review**: Check translations and select sentences to save
6. **Save**: Add to your chosen category

### Programmatic Usage

```swift
// Initialize the service (singleton)
let openAI = OpenAIService.shared

// Translate text
Task {
    do {
        let translation = try await openAI.translate(
            text: sourceText,
            from: .en,
            to: .es
        )
        print("Translation: \(translation)")
    } catch {
        print("Error: \(error.localizedDescription)")
    }
}
```

---

## API Reference

### OpenAIService

#### Methods

##### `translate(text:from:to:)`

Translate text between languages.

**Parameters:**
- `text`: String to translate
- `from`: Source `Language` enum
- `to`: Target `Language` enum

**Returns:** Translated string

**Throws:** `OpenAIError`

---

##### `breakdownAndTranslate(text:from:to:)`

Break text into sentences and translate each.

**Parameters:**
- `text`: Multi-sentence text
- `from`: Source `Language`
- `to`: Target `Language`

**Returns:** Array of `(original: String, translation: String)` tuples

**Throws:** `OpenAIError`

---

##### `generateVocabularyWord(word:sourceLanguage:targetLanguage:)`

Generate complete vocabulary entry.

**Parameters:**
- `word`: Word to generate entry for
- `sourceLanguage`: Source `Language`
- `targetLanguage`: Target `Language`

**Returns:** `TranslationResult` with full details

**Throws:** `OpenAIError`

---

##### `extractTextFromImage(_:sourceLanguage:)`

Extract text from image using OCR.

**Parameters:**
- Image: `UIImage` to process
- `sourceLanguage`: Expected language in image

**Returns:** Extracted text string

**Throws:** `OpenAIError`

---

##### `extractAndTranslateFromImage(_:sourceLanguage:targetLanguage:)`

Extract text from image and translate.

**Parameters:**
- Image: `UIImage` to process
- `sourceLanguage`: Source language
- `targetLanguage`: Target language

**Returns:** Array of sentence pairs

**Throws:** `OpenAIError`

---

##### `extractVocabulary(from:sourceLanguage:targetLanguage:difficulty:)`

Extract important vocabulary words from text.

**Parameters:**
- `from`: Text passage
- `sourceLanguage`: Source language
- `targetLanguage`: Target language
- `difficulty`: `.beginner`, `.intermediate`, or `.advanced`

**Returns:** Array of `TranslationResult`

**Throws:** `OpenAIError`

---

### Models

#### `TranslationResult`

```swift
struct TranslationResult {
    let original: String
    let translation: String
    let definition: String?
    let example: String?
    let pronunciation: String?
}
```

#### `OpenAIError`

```swift
enum OpenAIError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case noContent
    case apiError(statusCode: Int)
    case imageProcessingFailed
}
```

---

## Error Handling

### Common Errors

1. **Missing API Key**
   ```
   OpenAI API key is not configured
   ```
   **Solution**: Add your API key to `AppConfiguration.swift`

2. **Rate Limit Exceeded**
   ```
   OpenAI API error (status code: 429)
   ```
   **Solution**: Wait a moment and try again, or upgrade your OpenAI plan

3. **Invalid Response**
   ```
   Invalid response from OpenAI API
   ```
   **Solution**: Check your internet connection

4. **Image Processing Failed**
   ```
   Failed to process image
   ```
   **Solution**: Ensure image is valid and not corrupted

### Handling Errors in Your Code

```swift
func translateText() {
    Task {
        do {
            let result = try await OpenAIService.shared.translate(
                text: inputText,
                from: sourceLanguage,
                to: targetLanguage
            )
            // Success
            handleSuccess(result)
        } catch let error as OpenAIError {
            // Handle specific OpenAI errors
            switch error {
            case .missingAPIKey:
                showAlert("Please configure your OpenAI API key")
            case .apiError(let statusCode):
                if statusCode == 429 {
                    showAlert("Too many requests. Please try again in a moment.")
                } else {
                    showAlert("API error: \(statusCode)")
                }
            default:
                showAlert(error.localizedDescription)
            }
        } catch {
            // Handle other errors
            showAlert("Unexpected error: \(error.localizedDescription)")
        }
    }
}
```

---

## Best Practices

### 1. Error Fallbacks

Always provide a fallback when OpenAI fails:

```swift
do {
    let aiTranslation = try await OpenAIService.shared.translate(...)
    return aiTranslation
} catch {
    // Fall back to basic translation or mock
    return mockTranslation(...)
}
```

### 2. User Feedback

Show processing status to users:

```swift
@State private var isProcessing = false
@State private var errorMessage: String?

// While processing
if isProcessing {
    ProgressView()
    Text("Translating with AI...")
}

// Show errors
if let error = errorMessage {
    Text(error)
        .foregroundColor(.red)
}
```

### 3. Rate Limiting

Implement delays between requests:

```swift
private var lastRequestTime: Date?
private let minimumRequestInterval: TimeInterval = 1.0

func makeRequest() async throws {
    if let last = lastRequestTime {
        let elapsed = Date().timeIntervalSince(last)
        if elapsed < minimumRequestInterval {
            try await Task.sleep(nanoseconds: UInt64((minimumRequestInterval - elapsed) * 1_000_000_000))
        }
    }
    
    lastRequestTime = Date()
    // Make actual request
}
```

### 4. Caching

Cache translations to reduce API calls:

```swift
private var translationCache: [String: String] = [:]

func cachedTranslate(text: String, from: Language, to: Language) async throws -> String {
    let cacheKey = "\(text)_\(from.rawValue)_\(to.rawValue)"
    
    if let cached = translationCache[cacheKey] {
        return cached
    }
    
    let result = try await OpenAIService.shared.translate(text: text, from: from, to: to)
    translationCache[cacheKey] = result
    
    return result
}
```

### 5. API Key Security

**Never commit API keys to version control!**

- Use environment variables
- Use Keychain for production
- Add `AppConfiguration.swift` to `.gitignore` if it contains keys
- Rotate keys regularly

### 6. Cost Management

Monitor your OpenAI usage:

- GPT-4 Turbo: ~$0.01 per 1K input tokens, ~$0.03 per 1K output tokens
- GPT-4 Vision: ~$0.01 per image
- Set up billing alerts in OpenAI dashboard
- Use GPT-3.5-Turbo for less critical tasks (cheaper)

```swift
// Use GPT-3.5 for simple translations
struct OpenAI {
    static let defaultModel = "gpt-3.5-turbo"  // Cheaper
    static let advancedModel = "gpt-4-turbo-preview"  // More accurate
}
```

---

## Testing

### Unit Tests

```swift
class OpenAIServiceTests: XCTestCase {
    func testTranslation() async throws {
        let result = try await OpenAIService.shared.translate(
            text: "Hello",
            from: .en,
            to: .es
        )
        
        XCTAssertFalse(result.isEmpty)
        XCTAssertNotEqual(result, "Hello")
    }
    
    func testMissingAPIKey() async {
        // Temporarily remove API key
        // Test should throw missingAPIKey error
    }
}
```

### Mock Service for Testing

```swift
class MockOpenAIService: OpenAIService {
    override func translate(text: String, from: Language, to: Language) async throws -> String {
        return "[MOCK] \(text)"
    }
}
```

---

## Troubleshooting

### Issue: "API key not configured"

**Solution:**
1. Check `AppConfiguration.swift` has correct key
2. Ensure environment variable is set
3. Restart Xcode

### Issue: "Invalid response from OpenAI"

**Solution:**
1. Check internet connection
2. Verify API key is valid
3. Check OpenAI status page

### Issue: High latency

**Solution:**
1. Use GPT-3.5-Turbo instead of GPT-4
2. Reduce `maxTokens` parameter
3. Batch multiple requests

### Issue: Rate limits

**Solution:**
1. Implement request queuing
2. Add delays between requests
3. Upgrade OpenAI plan

---

## Additional Resources

- [OpenAI API Documentation](https://platform.openai.com/docs)
- [GPT-4 Guide](https://platform.openai.com/docs/guides/gpt)
- [GPT-4 Vision Guide](https://platform.openai.com/docs/guides/vision)
- [Pricing](https://openai.com/pricing)

---

## Support

For issues or questions:
1. Check this guide
2. Review OpenAI documentation
3. Check OpenAI community forum
4. File an issue in the repository

---

**Happy translating! 🌍✨**
