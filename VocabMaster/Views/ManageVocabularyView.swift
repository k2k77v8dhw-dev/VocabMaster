//
//  ManageVocabularyView.swift
//  VocabMaster
//

import SwiftUI

struct ManageVocabularyView: View {
    @EnvironmentObject var viewModel: VocabularyViewModel
    let onBack: () -> Void
    let onAddVocabulary: () -> Void
    
    @State private var selectedCategory: CategoryType = .business
    @State private var editingWord: VocabularyWord?
    @State private var isAddingNew = false
    @State private var selectionMode = false
    @State private var selectedWords: Set<String> = []
    @State private var showingDeleteAlert = false
    
    var words: [VocabularyWord] {
        viewModel.getCategoryWords(type: selectedCategory, language: viewModel.currentLanguage)
    }
    
    var availableCategories: [CategoryType] {
        viewModel.getAvailableCategories(for: viewModel.currentLanguage)
    }
    
    var body: some View {
        ZStack {
            if editingWord != nil || isAddingNew {
                EditWordFormView(
                    word: editingWord,
                    category: selectedCategory,
                    isNew: isAddingNew,
                    onSave: { word in
                        if isAddingNew {
                            viewModel.addWord(word, to: selectedCategory)
                        } else if let editing = editingWord {
                            viewModel.updateWord(word, in: selectedCategory)
                        }
                        editingWord = nil
                        isAddingNew = false
                    },
                    onCancel: {
                        editingWord = nil
                        isAddingNew = false
                    }
                )
            } else {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            Button(action: selectionMode ? { selectionMode = false; selectedWords = [] } : onBack) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .frame(width: 40, height: 40)
                                    .background(Color.gray.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Manage Vocabulary")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Text("\(words.count) words")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            LanguageSelectorButton()
                        }
                        
                        // Action Buttons
                        HStack(spacing: 12) {
                            if !selectionMode {
                                Button(action: { selectionMode = true }) {
                                    Text("Select")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(20)
                                }
                                
                                Spacer()
                                
                                Button(action: onAddVocabulary) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "plus")
                                        Text("Import")
                                    }
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.purple)
                                    .cornerRadius(20)
                                }
                                
                                Button(action: handleAddNew) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40)
                                        .background(Color.blue)
                                        .clipShape(Circle())
                                }
                            } else {
                                Button(action: {
                                    if selectedWords.count == words.count {
                                        selectedWords = []
                                    } else {
                                        selectedWords = Set(words.map { $0.id })
                                    }
                                }) {
                                    Text(selectedWords.count == words.count ? "Deselect All" : "Select All")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(20)
                                }
                                
                                Spacer()
                                
                                if !selectedWords.isEmpty {
                                    Button(action: { showingDeleteAlert = true }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "trash")
                                            Text("Delete (\(selectedWords.count))")
                                        }
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.red)
                                        .cornerRadius(20)
                                    }
                                }
                            }
                        }
                        
                        // Category Tabs
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(availableCategories, id: \.self) { categoryType in
                                    Button(action: {
                                        selectedCategory = categoryType
                                        selectedWords = []
                                    }) {
                                        Text(categoryType.name)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(selectedCategory == categoryType ? .white : .secondary)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(selectedCategory == categoryType ? categoryType.color : Color.gray.opacity(0.1))
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                    .background(Color(.systemBackground).opacity(0.8))
                    .overlay(
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 1),
                        alignment: .bottom
                    )
                    
                    // Word List
                    if words.isEmpty {
                        VStack(spacing: 16) {
                            Text("No words in this category for this language yet")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button(action: handleAddNew) {
                                Text("Add First Word")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .cornerRadius(24)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(48)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(words) { word in
                                    WordCard(
                                        word: word,
                                        categoryColor: selectedCategory.color,
                                        isSelected: selectedWords.contains(word.id),
                                        selectionMode: selectionMode,
                                        onSelect: {
                                            if selectedWords.contains(word.id) {
                                                selectedWords.remove(word.id)
                                            } else {
                                                selectedWords.insert(word.id)
                                            }
                                        },
                                        onEdit: {
                                            editingWord = word
                                        }
                                    )
                                }
                            }
                            .padding(16)
                        }
                    }
                }
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
        .alert("Delete Words", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deleteWords(ids: Array(selectedWords), from: selectedCategory)
                selectedWords = []
                selectionMode = false
            }
        } message: {
            Text("Are you sure you want to delete \(selectedWords.count) word(s)?")
        }
    }
    
    func handleAddNew() {
        editingWord = VocabularyWord(
            word: "",
            definition: "",
            example: "",
            pronunciation: "",
            language: viewModel.currentLanguage,
            translationLanguage: viewModel.currentLanguage
        )
        isAddingNew = true
    }
}

struct WordCard: View {
    let word: VocabularyWord
    let categoryColor: Color
    let isSelected: Bool
    let selectionMode: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            if selectionMode {
                Button(action: onSelect) {
                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? categoryColor : .gray)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(word.word)
                            .font(.body)
                            .fontWeight(.semibold)
                        
                        if let pronunciation = word.pronunciation, !pronunciation.isEmpty {
                            Text(pronunciation)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if !selectionMode {
                        Button(action: onEdit) {
                            Image(systemName: "pencil")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .frame(width: 32, height: 32)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                }
                
                Text(word.definition)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Text("\"\(word.example)\"")
                    .font(.subheadline)
                    .italic()
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? categoryColor : Color.clear, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 4)
    }
}
