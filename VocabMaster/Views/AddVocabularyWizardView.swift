//
//  AddVocabularyWizardView.swift
//  VocabMaster
//

import SwiftUI

enum InputMethod {
    case text, image, scan
}

enum WizardStep {
    case method, input, review
}

struct AddVocabularyWizardView: View {
    @EnvironmentObject var viewModel: VocabularyViewModel
    let onBack: () -> Void
    
    @State private var step: WizardStep = .method
    @State private var inputMethod: InputMethod = .text
    @State private var sourceLanguage: Language = .en
    @State private var targetLanguage: Language = .es
    @State private var selectedCategory: CategoryType = .daily
    @State private var title = ""
    @State private var inputText = ""
    @State private var sentences: [Sentence] = []
    @State private var isProcessing = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 16) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 40, height: 40)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Add Vocabulary")
                        .font(.system(size: 20, weight: .bold))
                    Text(stepDescription)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 60)
            .padding(.bottom, 24)
            .background(Color(.systemBackground).opacity(0.8))
            .overlay(
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 1),
                alignment: .bottom
            )
            
            // Content
            switch step {
            case .method:
                MethodSelectionView(onSelect: { method in
                    inputMethod = method
                    step = .input
                })
                
            case .input:
                InputView(
                    inputMethod: inputMethod,
                    sourceLanguage: $sourceLanguage,
                    targetLanguage: $targetLanguage,
                    inputText: $inputText,
                    isProcessing: $isProcessing,
                    onProcess: processText
                )
                
            case .review:
                ReviewView(
                    title: $title,
                    selectedCategory: $selectedCategory,
                    sentences: $sentences,
                    onSave: saveVocabulary
                )
            }
        }
        .background(
            LinearGradient(
                colors: [Color.gray.opacity(0.05), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear {
            sourceLanguage = viewModel.currentLanguage
        }
    }
    
    var stepDescription: String {
        switch step {
        case .method: return "Choose input method"
        case .input: return "Enter or capture text"
        case .review: return "Review & save"
        }
    }
    
    func processText() {
        isProcessing = true
        
        let sentenceArray = breakIntoSentences(inputText)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            sentences = sentenceArray.map { original in
                Sentence(
                    original: original,
                    translation: mockTranslate(original, from: sourceLanguage, to: targetLanguage),
                    selected: true
                )
            }
            isProcessing = false
            step = .review
        }
    }
    
    func breakIntoSentences(_ text: String) -> [String] {
        return text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    func mockTranslate(_ text: String, from: Language, to: Language) -> String {
        // Mock translation
        return "[\(to.rawValue.uppercased())] \(text)"
    }
    
    func saveVocabulary() {
        let selectedSentences = sentences.filter { $0.selected }
        let words = selectedSentences.map { sentence in
            VocabularyWord(
                word: sentence.original,
                definition: sentence.translation,
                example: "From: \(title.isEmpty ? "Custom Import" : title)",
                pronunciation: nil,
                language: sourceLanguage,
                translationLanguage: targetLanguage
            )
        }
        
        viewModel.addWords(words, to: selectedCategory)
        onBack()
    }
}

struct MethodSelectionView: View {
    let onSelect: (InputMethod) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("How would you like to add vocabulary?")
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.top, 24)
                    .padding(.horizontal, 24)
                
                VStack(spacing: 12) {
                    MethodButton(
                        icon: "doc.text.fill",
                        title: "Paste Text",
                        description: "Copy and paste text passages",
                        color: .blue,
                        onTap: { onSelect(.text) }
                    )
                    
                    MethodButton(
                        icon: "photo.fill",
                        title: "Search Image",
                        description: "Find and extract text from images",
                        color: .purple,
                        onTap: { onSelect(.image) }
                    )
                    
                    MethodButton(
                        icon: "camera.fill",
                        title: "Live Scan",
                        description: "Scan text with your camera",
                        color: .green,
                        onTap: { onSelect(.scan) }
                    )
                }
                .padding(24)
            }
        }
    }
}

struct MethodButton: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct InputView: View {
    let inputMethod: InputMethod
    @Binding var sourceLanguage: Language
    @Binding var targetLanguage: Language
    @Binding var inputText: String
    @Binding var isProcessing: Bool
    let onProcess: () -> Void
    
    @State private var showSourcePicker = false
    @State private var showTargetPicker = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Language Selection
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Source Language")
                            .font(.system(size: 14, weight: .semibold))
                        
                        Button(action: { showSourcePicker = true }) {
                            HStack {
                                Text(sourceLanguage.flag)
                                Text(sourceLanguage.name)
                                    .font(.system(size: 14))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding(12)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Target Language")
                            .font(.system(size: 14, weight: .semibold))
                        
                        Button(action: { showTargetPicker = true }) {
                            HStack {
                                Text(targetLanguage.flag)
                                Text(targetLanguage.name)
                                    .font(.system(size: 14))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding(12)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                }
                
                // Input Area
                VStack(alignment: .leading, spacing: 8) {
                    Text(inputMethod == .text ? "Paste your text" : inputMethod == .image ? "Extracted text" : "Scanned text")
                        .font(.system(size: 14, weight: .semibold))
                    
                    TextEditor(text: $inputText)
                        .frame(height: 200)
                        .padding(12)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                }
                
                // Process Button
                Button(action: onProcess) {
                    HStack {
                        if isProcessing {
                            ProgressTrackerView(onBack: {})
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("Processing...")
                                .font(.system(size: 16, weight: .semibold))
                        } else {
                            Text("Process Text")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(inputText.isEmpty || isProcessing ? Color.gray : Color.blue)
                    .cornerRadius(16)
                }
                .disabled(inputText.isEmpty || isProcessing)
            }
            .padding(24)
        }
        .sheet(isPresented: $showSourcePicker) {
            SimpleLanguagePickerView(selectedLanguage: $sourceLanguage)
        }
        .sheet(isPresented: $showTargetPicker) {
            SimpleLanguagePickerView(selectedLanguage: $targetLanguage)
        }
    }
}

struct ReviewView: View {
    @Binding var title: String
    @Binding var selectedCategory: CategoryType
    @Binding var sentences: [Sentence]
    let onSave: () -> Void
    
    var selectedCount: Int {
        sentences.filter { $0.selected }.count
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(.system(size: 14, weight: .semibold))
                    
                    TextField("e.g., Business Meeting Notes", text: $title)
                        .padding(16)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                }
                
                // Category
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.system(size: 14, weight: .semibold))
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(CategoryType.allCases, id: \.self) { category in
                            Text(category.name).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
                
                // Sentences
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select sentences (\(selectedCount)/\(sentences.count))")
                        .font(.system(size: 14, weight: .semibold))
                    
                    ForEach(sentences) { sentence in
                        SentenceCard(
                            sentence: sentence,
                            onToggle: {
                                if let index = sentences.firstIndex(where: { $0.id == sentence.id }) {
                                    sentences[index].selected.toggle()
                                }
                            }
                        )
                    }
                }
                
                // Save Button
                Button(action: onSave) {
                    Text("Save \(selectedCount) Sentence(s)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(title.isEmpty || selectedCount == 0 ? Color.gray : Color.blue)
                        .cornerRadius(16)
                }
                .disabled(title.isEmpty || selectedCount == 0)
            }
            .padding(24)
        }
    }
}

struct SentenceCard: View {
    let sentence: Sentence
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: sentence.selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(sentence.selected ? .blue : .gray)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(sentence.original)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(sentence.translation)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(sentence.selected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 10, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Simple Language Picker (for wizard only)

struct SimpleLanguagePickerView: View {
    @Binding var selectedLanguage: Language
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List(Language.allCases, id: \.self) { language in
                Button(action: {
                    selectedLanguage = language
                    dismiss()
                }) {
                    HStack(spacing: 12) {
                        Text(language.flag)
                            .font(.system(size: 24))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(language.name)
                                .foregroundColor(.primary)
                            Text(language.nativeName)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if language == selectedLanguage {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Select Language")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct AddVocabularyWizardView_Previews: PreviewProvider {
    static var previews: some View {
        AddVocabularyWizardView(
            onBack: { }
        )
        .environmentObject(VocabularyViewModel())
    }
}
