//
//  AppConfiguration.swift
//  VocabMaster
//
//  Central configuration for the app
//

import Foundation

struct AppConfiguration {
    
    // MARK: - Data Provider Configuration
    
    /// The active data provider type
    /// Change this to switch between Core Data, AWS, Firebase, etc.
    static let dataProviderType: DataProviderType = .coreData
    
    // MARK: - OpenAI Configuration
    
    struct OpenAI {
        /// OpenAI API Key
        /// Get your API key from: https://platform.openai.com/api-keys
        /// IMPORTANT: In production, use Keychain or environment variables
        static var apiKey: String {
            // Try to get from environment first
            if let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
                return key
            }
            
            // Try to get from keychain
            if let key = KeychainHelper.getOpenAIKey() {
                return key
            }
            
            // Fallback for development (REPLACE WITH YOUR KEY)
            #if DEBUG
            return "YOUR_OPENAI_API_KEY_HERE"
            #else
            return ""
            #endif
        }
        
        /// Default model for translation and text processing
        static let defaultModel = "gpt-4-turbo-preview"
        
        /// Default model for vision/OCR
        static let visionModel = "gpt-4-vision-preview"
        
        /// Enable OpenAI features
        static let enableTranslation = true
        static let enableOCR = true
        static let enableVocabularyGeneration = true
        
        /// Request timeout (in seconds)
        static let timeoutInterval: TimeInterval = 60
        
        /// Max retries for failed requests
        static let maxRetries = 2
    }
    
    // MARK: - AWS Configuration
    
    struct AWS {
        /// AWS API Base URL
        static let baseURL = "https://api.vocabmaster.example.com/v1"
        
        /// AWS API Key
        /// In production, load from environment or secure storage
        static var apiKey: String {
            // Try to get from environment first
            if let key = ProcessInfo.processInfo.environment["AWS_API_KEY"] {
                return key
            }
            
            // Try to get from keychain
            if let key = KeychainHelper.getAPIKey() {
                return key
            }
            
            // Fallback for development (REMOVE IN PRODUCTION)
            #if DEBUG
            return "development-api-key"
            #else
            return ""
            #endif
        }
        
        /// Enable offline caching
        static let enableOfflineCache = true
        
        /// Cache expiration time (in seconds)
        static let cacheExpirationTime: TimeInterval = 3600 // 1 hour
    }
    
    // MARK: - Firebase Configuration
    
    struct Firebase {
        /// Firebase Project ID
        static let projectId = "vocabmaster-app"
        
        /// Firestore collection names
        static let wordsCollection = "words"
        static let progressCollection = "progress"
        static let settingsCollection = "settings"
        
        /// Enable persistence
        static let enablePersistence = true
    }
    
    // MARK: - Core Data Configuration
    
    struct CoreData {
        /// Model name
        static let modelName = "VocabMaster"
        
        /// Enable automatic migration
        static let enableAutomaticMigration = true
    }
    
    // MARK: - Feature Flags
    
    struct Features {
        /// Enable sync feature
        static let enableSync = true
        
        /// Enable export/import
        static let enableExportImport = true
        
        /// Enable mock data in debug mode
        static let enableMockData = false
        
        /// Auto-initialize with default vocabulary
        static let autoInitializeDefaultData = true
        
        /// Enable analytics
        static let enableAnalytics = false
    }
    
    // MARK: - App Settings
    
    struct Settings {
        /// Default language
        static let defaultLanguage: Language = .en
        
        /// Available languages
        static let availableLanguages: [Language] = Language.allCases
        
        /// Default categories
        static let defaultCategories: [CategoryType] = CategoryType.allCases
    }
    
    // MARK: - API Settings
    
    struct API {
        /// Request timeout (in seconds)
        static let timeoutInterval: TimeInterval = 30
        
        /// Max retry attempts
        static let maxRetryAttempts = 3
        
        /// Retry delay (in seconds)
        static let retryDelay: TimeInterval = 2
    }
    
    // MARK: - Debug Settings
    
    struct Debug {
        /// Print network requests
        static let logNetworkRequests = true
        
        /// Print Core Data operations
        static let logCoreDataOperations = false
        
        /// Use mock provider in debug
        static let useMockProviderInDebug = false
        
        /// Reset data on every launch (for testing)
        static let resetDataOnLaunch = false
    }
}

// MARK: - Keychain Helper (Placeholder)

class KeychainHelper {
    static func getAPIKey() -> String? {
        // TODO: Implement actual keychain access
        // For now, return nil
        return nil
    }
    
    static func setAPIKey(_ key: String) -> Bool {
        // TODO: Implement actual keychain storage
        return false
    }
    
    static func getOpenAIKey() -> String? {
        // TODO: Implement actual keychain access for OpenAI
        // For now, return nil
        return nil
    }
    
    static func setOpenAIKey(_ key: String) -> Bool {
        // TODO: Implement actual keychain storage for OpenAI
        return false
    }
}

// MARK: - Environment Detection

extension AppConfiguration {
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    static var isProduction: Bool {
        return !isDebug
    }
    
    static var isTesting: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}

// MARK: - Provider Factory with Configuration

extension DataProviderFactory {
    /// Create provider based on app configuration
    static func createConfiguredProvider() -> VocabularyDataProvider {
        let providerType = AppConfiguration.dataProviderType
        
        // Override with mock in debug if configured
        #if DEBUG
        if AppConfiguration.Debug.useMockProviderInDebug {
            return MockVocabularyProvider()
        }
        #endif
        
        return createProvider(type: providerType)
    }
}