# Quick Start: OpenAI Integration

Get OpenAI running in VocabMaster in 5 minutes! ⚡

## Step 1: Get Your API Key (2 minutes)

1. Go to https://platform.openai.com/api-keys
2. Click "Create new secret key"
3. Copy the key (starts with `sk-`)

## Step 2: Add API Key (1 minute)

Open `/ios/Configuration/AppConfiguration.swift` and replace:

```swift
#if DEBUG
return "YOUR_OPENAI_API_KEY_HERE"  // ← REPLACE THIS
#else
```

With your actual key:

```swift
#if DEBUG
return "sk-proj-abc123..."  // ← YOUR KEY HERE
#else
```

## Step 3: Rename the File (1 minute)

In Xcode:

1. Right-click `AddVocabularyWizardView.swift` → Rename to `AddVocabularyWizardView-OLD.swift`
2. Right-click `AddVocabularyWizardView-OpenAI.swift` → Rename to `AddVocabularyWizardView.swift`
3. Update the struct name inside from `AddVocabularyWizardViewWithAI` to `AddVocabularyWizardView`

## Step 4: Build & Run (1 minute)

1. Clean build folder: Cmd+Shift+K
2. Build: Cmd+B
3. Run: Cmd+R

## ✅ Test It!

1. Tap "Manage Vocabulary"
2. Tap "Import" button
3. Select "Paste Text"
4. Paste some text
5. Select languages
6. Tap "Translate with AI" ✨

You should see AI-powered translations!

---

## Troubleshooting

### "API key not configured"
→ Double-check you added your key to `AppConfiguration.swift`

### Build errors
→ Make sure you renamed the files correctly in Xcode

### "Rate limit exceeded"
→ Wait a minute and try again (free tier has limits)

---

## What's Next?

Read the full guide: `OPENAI_INTEGRATION_GUIDE.md`

## Features You Now Have:

✅ AI-powered translation (10 languages)
✅ Automatic sentence breakdown
✅ OCR from images (extract text from photos)
✅ Smart vocabulary extraction
✅ Definitions, examples, and pronunciation

---

**Enjoy your AI-powered vocabulary app! 🚀**
