//
//  AWSVocabularyProvider.swift
//  VocabMaster
//
//  AWS implementation of VocabularyDataProvider
//  This is a template/example for AWS integration
//

import Foundation

class AWSVocabularyProvider: VocabularyDataProvider {
    
    // MARK: - Configuration
    
    private let baseURL: String
    private let apiKey: String
    private var authToken: String?
    
    // Local cache for offline support
    private var cachedWords: [CategoryType: [VocabularyWord]] = [:]
    private var cachedCompletedIds: Set<String> = []
    private var cachedSettings: AppSettings?
    
    init(baseURL: String = "https://api.vocabmaster.example.com",
         apiKey: String = "YOUR_AWS_API_KEY") {
        self.baseURL = baseURL
        self.apiKey = apiKey
    }
    
    var supportsSyncing: Bool { true }
    
    // MARK: - Network Helper
    
    private func makeRequest<T: Codable>(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw DataProviderError.invalidData
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DataProviderError.networkError
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return try JSONDecoder().decode(T.self, from: data)
        case 401:
            throw DataProviderError.unauthorized
        case 404:
            throw DataProviderError.notFound
        default:
            throw DataProviderError.unknown("HTTP \(httpResponse.statusCode)")
        }
    }
    
    // MARK: - Word CRUD Operations
    
    func fetchWords(for category: CategoryType) async throws -> [VocabularyWord] {
        struct Response: Codable {
            let words: [VocabularyWord]
        }
        
        let response: Response = try await makeRequest(
            endpoint: "/api/v1/words?category=\(category.rawValue)"
        )
        
        // Update cache
        cachedWords[category] = response.words
        
        return response.words
    }
    
    func fetchAllWords() async throws -> [VocabularyWord] {
        struct Response: Codable {
            let words: [VocabularyWord]
        }
        
        let response: Response = try await makeRequest(endpoint: "/api/v1/words")
        
        // Update cache
        for category in CategoryType.allCases {
            cachedWords[category] = response.words.filter { word in
                // Assuming the word has a category field
                true // Filter by category in real implementation
            }
        }
        
        return response.words
    }
    
    func fetchWords(for category: CategoryType, language: Language) async throws -> [VocabularyWord] {
        let words = try await fetchWords(for: category)
        return words.filter { $0.language == nil || $0.language == language }
    }
    
    func fetchWord(id: String) async throws -> VocabularyWord {
        return try await makeRequest(endpoint: "/api/v1/words/\(id)")
    }
    
    func createWord(_ word: VocabularyWord, in category: CategoryType) async throws -> VocabularyWord {
        struct Request: Codable {
            let word: VocabularyWord
            let category: String
        }
        
        let request = Request(word: word, category: category.rawValue)
        let body = try JSONEncoder().encode(request)
        
        let created: VocabularyWord = try await makeRequest(
            endpoint: "/api/v1/words",
            method: "POST",
            body: body
        )
        
        // Update cache
        cachedWords[category, default: []].append(created)
        
        return created
    }
    
    func createWords(_ words: [VocabularyWord], in category: CategoryType) async throws -> [VocabularyWord] {
        struct Request: Codable {
            let words: [VocabularyWord]
            let category: String
        }
        
        struct Response: Codable {
            let words: [VocabularyWord]
        }
        
        let request = Request(words: words, category: category.rawValue)
        let body = try JSONEncoder().encode(request)
        
        let response: Response = try await makeRequest(
            endpoint: "/api/v1/words/batch",
            method: "POST",
            body: body
        )
        
        // Update cache
        cachedWords[category, default: []].append(contentsOf: response.words)
        
        return response.words
    }
    
    func updateWord(_ word: VocabularyWord, in category: CategoryType) async throws -> VocabularyWord {
        let body = try JSONEncoder().encode(word)
        
        let updated: VocabularyWord = try await makeRequest(
            endpoint: "/api/v1/words/\(word.id)",
            method: "PUT",
            body: body
        )
        
        // Update cache
        if var categoryWords = cachedWords[category],
           let index = categoryWords.firstIndex(where: { $0.id == word.id }) {
            categoryWords[index] = updated
            cachedWords[category] = categoryWords
        }
        
        return updated
    }
    
    func deleteWord(id: String) async throws {
        struct EmptyResponse: Codable {}
        
        let _: EmptyResponse = try await makeRequest(
            endpoint: "/api/v1/words/\(id)",
            method: "DELETE"
        )
        
        // Update cache
        for category in CategoryType.allCases {
            cachedWords[category]?.removeAll { $0.id == id }
        }
        cachedCompletedIds.remove(id)
    }
    
    func deleteWords(ids: [String]) async throws {
        struct Request: Codable {
            let ids: [String]
        }
        
        struct EmptyResponse: Codable {}
        
        let request = Request(ids: ids)
        let body = try JSONEncoder().encode(request)
        
        let _: EmptyResponse = try await makeRequest(
            endpoint: "/api/v1/words/batch",
            method: "DELETE",
            body: body
        )
        
        // Update cache
        for category in CategoryType.allCases {
            cachedWords[category]?.removeAll { ids.contains($0.id) }
        }
        cachedCompletedIds.subtract(ids)
    }
    
    func deleteAllWords(in category: CategoryType) async throws {
        struct EmptyResponse: Codable {}
        
        let _: EmptyResponse = try await makeRequest(
            endpoint: "/api/v1/words?category=\(category.rawValue)",
            method: "DELETE"
        )
        
        // Update cache
        cachedWords[category] = []
    }
    
    // MARK: - Progress CRUD Operations
    
    func markWordCompleted(id: String) async throws {
        struct Request: Codable {
            let wordId: String
            let completedDate: Date
        }
        
        struct EmptyResponse: Codable {}
        
        let request = Request(wordId: id, completedDate: Date())
        let body = try JSONEncoder().encode(request)
        
        let _: EmptyResponse = try await makeRequest(
            endpoint: "/api/v1/progress",
            method: "POST",
            body: body
        )
        
        // Update cache
        cachedCompletedIds.insert(id)
    }
    
    func markWordIncomplete(id: String) async throws {
        struct EmptyResponse: Codable {}
        
        let _: EmptyResponse = try await makeRequest(
            endpoint: "/api/v1/progress/\(id)",
            method: "DELETE"
        )
        
        // Update cache
        cachedCompletedIds.remove(id)
    }
    
    func isWordCompleted(id: String) async throws -> Bool {
        struct Response: Codable {
            let completed: Bool
        }
        
        let response: Response = try await makeRequest(
            endpoint: "/api/v1/progress/\(id)"
        )
        
        return response.completed
    }
    
    func fetchCompletedWordIds() async throws -> Set<String> {
        struct Response: Codable {
            let completedIds: [String]
        }
        
        let response: Response = try await makeRequest(
            endpoint: "/api/v1/progress"
        )
        
        // Update cache
        cachedCompletedIds = Set(response.completedIds)
        
        return cachedCompletedIds
    }
    
    func fetchProgress(for category: CategoryType, language: Language) async throws -> (completed: Int, total: Int) {
        struct Response: Codable {
            let completed: Int
            let total: Int
        }
        
        let response: Response = try await makeRequest(
            endpoint: "/api/v1/progress/stats?category=\(category.rawValue)&language=\(language.rawValue)"
        )
        
        return (response.completed, response.total)
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
        if let cached = cachedSettings {
            return cached
        }
        
        let settings: AppSettings = try await makeRequest(
            endpoint: "/api/v1/settings"
        )
        
        // Update cache
        cachedSettings = settings
        
        return settings
    }
    
    func updateSettings(_ settings: AppSettings) async throws {
        let body = try JSONEncoder().encode(settings)
        
        let updated: AppSettings = try await makeRequest(
            endpoint: "/api/v1/settings",
            method: "PUT",
            body: body
        )
        
        // Update cache
        cachedSettings = updated
    }
    
    // MARK: - Batch Operations
    
    func importVocabulary(_ words: [VocabularyWord], category: CategoryType, replaceExisting: Bool) async throws {
        struct Request: Codable {
            let words: [VocabularyWord]
            let category: String
            let replaceExisting: Bool
        }
        
        struct EmptyResponse: Codable {}
        
        let request = Request(words: words, category: category.rawValue, replaceExisting: replaceExisting)
        let body = try JSONEncoder().encode(request)
        
        let _: EmptyResponse = try await makeRequest(
            endpoint: "/api/v1/import",
            method: "POST",
            body: body
        )
        
        // Clear cache for this category
        cachedWords[category] = nil
    }
    
    func exportVocabulary() async throws -> [CategoryType: [VocabularyWord]] {
        struct Response: Codable {
            let vocabulary: [String: [VocabularyWord]]
        }
        
        let response: Response = try await makeRequest(
            endpoint: "/api/v1/export"
        )
        
        var result: [CategoryType: [VocabularyWord]] = [:]
        for (key, value) in response.vocabulary {
            if let category = CategoryType(rawValue: key) {
                result[category] = value
            }
        }
        
        return result
    }
    
    func resetAllData() async throws {
        struct EmptyResponse: Codable {}
        
        let _: EmptyResponse = try await makeRequest(
            endpoint: "/api/v1/reset",
            method: "POST"
        )
        
        // Clear all cache
        cachedWords = [:]
        cachedCompletedIds = []
        cachedSettings = nil
    }
    
    // MARK: - Sync Operations
    
    func syncData() async throws {
        struct EmptyResponse: Codable {}
        
        let _: EmptyResponse = try await makeRequest(
            endpoint: "/api/v1/sync",
            method: "POST"
        )
        
        // Refresh all cached data
        cachedWords = [:]
        cachedCompletedIds = []
        cachedSettings = nil
        
        _ = try await fetchAllWords()
        _ = try await fetchCompletedWordIds()
        _ = try await getSettings()
    }
}
