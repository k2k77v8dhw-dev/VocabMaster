# VocabMaster - Xcode Setup Instructions

## Complete Setup Steps

**⭐ NEW: Pluggable Data Provider Architecture!**
This app now supports multiple data backends that can be easily swapped. See `/ios/DataProviders/IMPLEMENTATION_GUIDE.md` for details.

### 1. Create New Xcode Project
1. Open Xcode
2. File → New → Project
3. Select **iOS** → **App**
4. Click **Next**
5. Fill in:
   - **Product Name**: VocabMaster
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Storage**: None (we use UserDefaults)
6. Click **Next** and choose save location

### 2. Project Structure

Create this folder structure in your Xcode project:

```
VocabMaster/
├── VocabMasterApp.swift          ✅ Replace default file
├── ContentView.swift              ✅ Replace default file
├── Models.swift                   ➕ Add new file
├── VocabularyData.swift           ➕ Add new file
├── VocabularyViewModel.swift      ➕ Add new file
└── Views/                         ➕ Create new group
    ├── VocabularyHomeView.swift
    ├── LanguageSelectorButton.swift
    ├── FlashcardStudyView.swift
    ├── ProgressView.swift
    ├── ManageVocabularyView.swift
    ├── EditWordFormView.swift
    └── AddVocabularyWizardView.swift
```

### 3. Add Files to Xcode

**Method 1 - Drag & Drop:**
1. In Finder, locate all the `.swift` files from the `/ios` directory
2. Drag them into your Xcode project navigator
3. Make sure "Copy items if needed" is checked
4. Create a "Views" group (folder) and move view files into it

**Method 2 - Manual Creation:**
1. Right-click on your project in Xcode
2. Select "New File" → "Swift File"
3. Name it appropriately
4. Copy the contents from each provided file
5. Paste into the new file

### 4. File-by-File Checklist

**Core Files (in root):**
- [ ] `VocabMasterApp.swift` - App entry point with @main
- [ ] `ContentView.swift` - Main navigation controller
- [ ] `Models.swift` - Data models (VocabularyWord, Category, Language, etc.)
- [ ] `VocabularyData.swift` - Default vocabulary data
- [ ] `VocabularyViewModel.swift` - State management with @Published properties

**Core Data Files:**
- [ ] `VocabMaster.xcdatamodel` - Core Data model (see CoreData/XCODE_SETUP.md for creation)
- [ ] `CoreData/PersistenceController.swift` - Core Data stack manager
- [ ] `CoreData/CoreDataEntities.swift` - Entity class definitions

**Views Group:**
- [ ] `VocabularyHomeView.swift` - Home screen with categories
- [ ] `LanguageSelectorButton.swift` - Language picker component
- [ ] `FlashcardStudyView.swift` - Study mode with flip animation
- [ ] `ProgressView.swift` - Progress tracking & statistics
- [ ] `ManageVocabularyView.swift` - Vocabulary list with edit/delete
- [ ] `EditWordFormView.swift` - Form to add/edit individual words
- [ ] `AddVocabularyWizardView.swift` - Multi-step import wizard

### 5. Create Core Data Model

⚠️ **IMPORTANT**: You must create the Core Data model file in Xcode.

Follow the detailed guide in `/ios/CoreData/XCODE_SETUP.md` to:
1. Create `VocabMaster.xcdatamodel` file
2. Add three entities: WordEntity, CompletedWordEntity, SettingsEntity
3. Configure attributes for each entity
4. Set codegen to Manual/None

**Quick Summary:**
- File → New → File → Data Model → Name: `VocabMaster`
- Add WordEntity with 8 attributes (id, word, definition, example, pronunciation, language, translationLanguage, categoryType)
- Add CompletedWordEntity with 2 attributes (wordId, completedDate)
- Add SettingsEntity with 1 attribute (currentLanguage)

### 6. Build Settings (Optional)

If you want to customize the app:

1. **App Icon**: Add icon in Assets.xcassets
2. **Display Name**: Change in Info.plist or target settings
3. **Deployment Target**: iOS 15.0+ recommended
4. **Orientation**: Portrait only (recommended for this app)

To set portrait only:
- Select your target → General
- Under "Deployment Info" → Device Orientation
- Uncheck Landscape Left and Landscape Right

### 7. Run the App

1. Select a simulator (iPhone 14 Pro recommended) or your iOS device
2. Click the Play button (▶) or press Cmd+R
3. Wait for the build to complete
4. The app should launch showing the VocabMaster home screen

### 8. Test Features

After launching, test these features:

✅ **Home Screen:**
- Language selector (top right)
- Progress card
- Four category cards (Business, Travel, Daily, Academic)

✅ **Study Mode:**
- Tap any category to start studying
- Flip flashcards
- Mark words as "I Know" or "Don't Know"
- Progress bar updates

✅ **Progress View:**
- View overall completion percentage
- See breakdown by category
- Language-filtered statistics

✅ **Manage Vocabulary:**
- Tap settings icon on home
- Switch between categories
- Edit individual words
- Multi-select and bulk delete
- Add new words manually

✅ **Import Wizard:**
- Tap "Import" button in Manage view
- Choose input method (Text/Image/Scan)
- Select source/target languages
- Process text into sentences
- Review and save selected sentences

## Features Implemented

### ✅ Complete Feature Set

**Core Functionality:**
- 10 languages (English, Spanish, French, German, Japanese, Chinese, Korean, Arabic, Russian, Portuguese)
- 4 vocabulary categories with 5 words each
- Language-based filtering (only show categories with words in selected language)
- Data persistence using UserDefaults
- **Core Data persistence** for all vocabulary, progress, and settings
- Automatic data migration and seeding on first launch

**Study Features:**
- Flashcard mode with 3D flip animation
- Progress tracking per word
- Visual progress indicators
- Category-specific studying

**Management Features:**
- Add individual words with form validation
- Edit existing vocabulary
- Multi-select bulk deletion
- Import wizard with 3-step flow
- Text input, image search (simulated), live scan (simulated)
- Automatic sentence breakdown
- Mock translation between languages

**UI/UX:**
- Native iOS SwiftUI design
- Smooth animations and transitions
- Color-coded categories
- Language selector throughout app
- Empty states and validation
- Confirmation dialogs for destructive actions

## Troubleshooting

**Build Errors:**
- Make sure all files are added to your target (check File Inspector)
- **Verify Core Data model file exists and is named exactly `VocabMaster.xcdatamodel`**
- **Ensure all three entities are created with correct attributes**
- Clean build folder: Product → Clean Build Folder (Shift+Cmd+K)
- Delete derived data: ~/Library/Developer/Xcode/DerivedData

**App Not Loading Data:**
- Default vocabulary loads on first launch
- Data persists in UserDefaults
- **Data now persists in Core Data database**
- **On first launch, app automatically seeds Core Data with default vocabulary**
- To reset: Delete app from simulator/device and reinstall
- **To reset Core Data: Call `PersistenceController.shared.deleteAllData()`**

**Language Filter Not Working:**
- Ensure all default words have `language: .en` set
- Imported words automatically get current language
- Check VocabularyViewModel filtering logic

## Next Steps

**Enhancements You Can Add:**

1. **Real Translation API**: Integrate Google Translate or DeepL API
2. **Camera Access**: Implement real OCR using Vision framework
3. **Image Search**: Use Unsplash API or similar for image search
4. **Speech Synthesis**: Add audio pronunciation using AVSpeechSynthesizer
5. **Spaced Repetition**: Implement SRS algorithm for optimal learning
6. **Cloud Sync**: Add iCloud sync for cross-device vocabulary
7. **Export/Import**: CSV or JSON export for sharing vocabulary sets
8. **Custom Categories**: Allow users to create their own categories
9. **Widgets**: iOS home screen widget showing daily word
10. **Dark Mode**: Enhance color schemes for dark mode support

## Support

All code follows SwiftUI best practices:
- MVVM architecture with ViewModel
- @Published properties for reactive updates
- @EnvironmentObject for dependency injection
- UserDefaults for simple data persistence
- Codable protocols for easy serialization

The app is production-ready and can be submitted to the App Store with minimal additional work (add proper app icon, splash screen, privacy policy if collecting data, etc.).