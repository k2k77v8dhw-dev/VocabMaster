# Setting Up Core Data Model in Xcode

## Quick Setup Guide

### Step 1: Create the Data Model File

1. In Xcode, select your project folder in the Navigator
2. Go to **File** → **New** → **File** (or press Cmd+N)
3. In the template chooser, select **Core Data** section
4. Choose **Data Model**
5. Click **Next**
6. Name it: `VocabMaster`
7. Make sure it's added to your app target
8. Click **Create**

You should now see `VocabMaster.xcdatamodel` in your project.

### Step 2: Add Entities

#### Add WordEntity

1. Click the `VocabMaster.xcdatamodel` file to open it
2. At the bottom left, click **"Add Entity"** button
3. Rename "Entity" to `WordEntity`
4. With WordEntity selected, in the **Attributes** section, click **+** to add each attribute:

| Attribute Name | Type | Optional |
|---|---|---|
| id | String | ❌ |
| word | String | ❌ |
| definition | String | ❌ |
| example | String | ❌ |
| pronunciation | String | ✅ |
| language | String | ✅ |
| translationLanguage | String | ✅ |
| categoryType | String | ❌ |

#### Add CompletedWordEntity

1. Click **"Add Entity"** button again
2. Rename to `CompletedWordEntity`
3. Add attributes:

| Attribute Name | Type | Optional |
|---|---|---|
| wordId | String | ❌ |
| completedDate | Date | ❌ |

#### Add SettingsEntity

1. Click **"Add Entity"** button again
2. Rename to `SettingsEntity`
3. Add attributes:

| Attribute Name | Type | Optional |
|---|---|---|
| currentLanguage | String | ❌ |

### Step 3: Configure Code Generation

For each entity (WordEntity, CompletedWordEntity, SettingsEntity):

1. Select the entity
2. Open the **Data Model Inspector** (right sidebar, 3rd tab)
3. Set **Codegen**: `Manual/None`
4. Set **Module**: `Current Product Module`

This is important because we have custom implementations in `CoreDataEntities.swift`.

### Step 4: Verify Your Setup

Your Core Data model should look like this in the graph view:

```
┌─────────────────────┐
│   WordEntity        │
├─────────────────────┤
│ id: String          │
│ word: String        │
│ definition: String  │
│ example: String     │
│ pronunciation: Str? │
│ language: String?   │
│ translationLang: S? │
│ categoryType: Str   │
└─────────────────────┘

┌─────────────────────┐
│CompletedWordEntity  │
├─────────────────────┤
│ wordId: String      │
│ completedDate: Date │
└─────────────────────┘

┌─────────────────────┐
│  SettingsEntity     │
├─────────────────────┤
│ currentLanguage: S  │
└─────────────────────┘
```

### Step 5: Build and Run

1. Build the project (Cmd+B) to ensure there are no errors
2. Run the app (Cmd+R)
3. On first launch, the app will automatically populate Core Data with default vocabulary

## Troubleshooting

### "Could not find a model named 'VocabMaster'"

**Solution:**
- Ensure the file is named exactly `VocabMaster.xcdatamodel`
- Check that it's included in your app target (File Inspector → Target Membership)
- Clean build folder (Shift+Cmd+K) and rebuild

### Build errors about NSManagedObject

**Solution:**
- Verify Codegen is set to "Manual/None" for all entities
- Make sure `CoreDataEntities.swift` is in your project
- Clean and rebuild

### App crashes on launch

**Solution:**
- Check the console for Core Data errors
- Verify all entity names match exactly (case-sensitive)
- Ensure all required attributes are not marked as optional
- Delete the app from simulator and reinstall

### Data not persisting

**Solution:**
- Check that `PersistenceController.swift` is in your project
- Verify the container name matches: `NSPersistentContainer(name: "VocabMaster")`
- Make sure `save()` is called after making changes

## Testing Your Setup

To verify Core Data is working:

1. Run the app
2. Add a new word in the Manage Vocabulary section
3. Kill the app completely (swipe up in app switcher)
4. Relaunch the app
5. The word you added should still be there

If the word persists, Core Data is working correctly! 🎉

## Visual Editor Tips

### Graph View
- Click **Editor** → **Editor Style** → **Graph** for visual representation
- Drag entities around to organize
- Option-drag to duplicate entities

### Table View
- Click **Editor** → **Editor Style** → **Table** for detailed view
- Easier for adding many attributes
- Better for seeing all properties at once

### Quick Actions
- **Add Attribute**: Click **+** in Attributes section or right-click entity → Add Attribute
- **Delete**: Select and press Delete key
- **Rename**: Double-click name to edit
- **Duplicate**: Option-drag an attribute to copy it

## File Location

After creation, the file structure should be:

```
YourProject/
├── VocabMaster.xcdatamodel/
│   └── contents  (XML file - don't edit manually)
├── CoreData/
│   ├── PersistenceController.swift
│   ├── CoreDataEntities.swift
│   └── README.md
```

The `.xcdatamodel` can be in the root or in the CoreData folder - your choice!

## Next Steps

Once Core Data is set up:
- ✅ Vocabulary words persist automatically
- ✅ Progress tracking saved across sessions
- ✅ Language preference remembered
- ✅ All CRUD operations working
- ✅ Data survives app updates

Your app now has full data persistence! 🚀
