//
//  EditWordFormView.swift
//  VocabMaster
//

import SwiftUI

struct EditWordFormView: View {
    @EnvironmentObject var viewModel: VocabularyViewModel
    let word: VocabularyWord?
    let category: CategoryType
    let isNew: Bool
    let onSave: (VocabularyWord) -> Void
    let onCancel: () -> Void
    
    @State private var wordText = ""
    @State private var pronunciation = ""
    @State private var definition = ""
    @State private var example = ""
    
    var isValid: Bool {
        !wordText.trimmingCharacters(in: .whitespaces).isEmpty &&
        !definition.trimmingCharacters(in: .whitespaces).isEmpty &&
        !example.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 16) {
                Button(action: onCancel) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 40, height: 40)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Text(isNew ? "Add New Word" : "Edit Word")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: handleSave) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark")
                        Text("Save")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(isValid ? category.color : Color.gray)
                    .cornerRadius(20)
                }
                .disabled(!isValid)
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
            
            // Form
            ScrollView {
                VStack(spacing: 24) {
                    // Word
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Word")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("*")
                            .foregroundColor(.red)
                        
                        TextField("Enter word", text: $wordText)
                            .padding(16)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    // Pronunciation
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pronunciation (IPA)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        TextField("/example/", text: $pronunciation)
                            .padding(16)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        
                        Text("e.g., /ˈeksəmpəl/")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Definition
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Definition")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Text("*")
                                .foregroundColor(.red)
                        }
                        
                        TextEditor(text: $definition)
                            .frame(height: 100)
                            .padding(12)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    // Example
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Example Sentence")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Text("*")
                                .foregroundColor(.red)
                        }
                        
                        TextEditor(text: $example)
                            .frame(height: 100)
                            .padding(12)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    // Info Box
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("*")
                                .foregroundColor(.red)
                            Text("Required fields")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        Text("Make sure to provide clear definitions and relevant examples to help with learning.")
                            .font(.caption)
                            .foregroundColor(.blue.opacity(0.8))
                    }
                    .padding(16)
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.1), lineWidth: 1)
                    )
                }
                .padding(24)
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
            if let word = word {
                wordText = word.word
                pronunciation = word.pronunciation ?? ""
                definition = word.definition
                example = word.example
            }
        }
    }
    
    func handleSave() {
        guard isValid else { return }
        
        let savedWord = VocabularyWord(
            id: word?.id ?? UUID().uuidString,
            word: wordText.trimmingCharacters(in: .whitespaces),
            definition: definition.trimmingCharacters(in: .whitespaces),
            example: example.trimmingCharacters(in: .whitespaces),
            pronunciation: pronunciation.isEmpty ? nil : pronunciation,
            language: viewModel.currentLanguage,
            translationLanguage: viewModel.currentLanguage
        )
        
        onSave(savedWord)
    }
}
