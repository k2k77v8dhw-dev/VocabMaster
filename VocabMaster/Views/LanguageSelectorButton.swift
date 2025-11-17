//
//  LanguageSelectorButton.swift
//  VocabMaster
//

import SwiftUI

struct LanguageSelectorButton: View {
    @EnvironmentObject var viewModel: VocabularyViewModel
    @State private var showingPicker = false
    
    var body: some View {
        Button(action: { showingPicker = true }) {
            HStack(spacing: 6) {
                Image(systemName: "globe")
                    .font(.system(size: 16))
                Text(viewModel.currentLanguage.flag)
                    .font(.system(size: 18))
                Text(viewModel.currentLanguage.name)
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                Image(systemName: "chevron.down")
                    .font(.system(size: 12))
            }
            .foregroundColor(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .sheet(isPresented: $showingPicker) {
            LanguagePickerView(viewModel: viewModel)
        }
    }
}

struct LanguagePickerView: View {
    @ObservedObject var viewModel: VocabularyViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List(Language.allCases, id: \.self) { language in
                Button(action: {
                    viewModel.setCurrentLanguage(language)
                    dismiss()
                }) {
                    HStack(spacing: 12) {
                        Text(language.flag)
                            .font(.system(size: 24))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(language.name)
                                .foregroundColor(.primary)
                            Text(language.nativeName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if language == viewModel.currentLanguage {
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