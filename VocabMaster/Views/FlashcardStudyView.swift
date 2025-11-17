//
//  FlashcardStudyView.swift
//  VocabMaster
//

import SwiftUI

struct FlashcardStudyView: View {
    @EnvironmentObject var viewModel: VocabularyViewModel
    let category: CategoryType
    let onBack: () -> Void
    
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var showResult = false
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    
    var words: [VocabularyWord] {
        viewModel.getCategoryWords(type: category, language: viewModel.currentLanguage)
    }
    
    var currentWord: VocabularyWord? {
        guard currentIndex < words.count else { return nil }
        return words[currentIndex]
    }
    
    var progress: Double {
        guard words.count > 0 else { return 0 }
        return Double(currentIndex + 1) / Double(words.count)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
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
                        Text(category.name)
                            .font(.title3)
                            .fontWeight(.bold)
                        Text("\(currentIndex + 1) of \(words.count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    LanguageSelectorButton()
                }
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(category.color)
                            .frame(width: geometry.size.width * CGFloat(progress), height: 6)
                            .animation(.easeInOut, value: progress)
                    }
                }
                .frame(height: 6)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .background(Color(.systemBackground).opacity(0.8))
            .overlay(
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 1),
                alignment: .bottom
            )
            
            if let word = currentWord {
                // Flashcard
                ScrollView {
                    VStack(spacing: 32) {
                        FlashcardView(word: word, isFlipped: $isFlipped)
                            .padding(.horizontal, 24)
                            .padding(.top, 32)
                        
                        if !isFlipped {
                            Button(action: { withAnimation(.spring()) { isFlipped = true } }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("Flip Card")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(24)
                            }
                        }
                        
                        if isFlipped && !showResult {
                            HStack(spacing: 16) {
                                Button(action: handleDontKnow) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "xmark")
                                        Text("Don't Know")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(16)
                                }
                                
                                Button(action: handleKnow) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark")
                                        Text("I Know")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(category.color)
                                    .cornerRadius(16)
                                }
                            }
                            .padding(.horizontal, 24)
                            .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .padding(.bottom, 32)
                }
            } else {
                // Completed
                VStack(spacing: 24) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(category.color)
                    
                    Text("All Done!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("You've reviewed all words in this category")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button(action: onBack) {
                        Text("Back to Home")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(category.color)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(32)
            }
            
            Spacer()
        }
        .background(
            LinearGradient(
                colors: [Color.gray.opacity(0.05), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
    
    func handleKnow() {
        if let word = currentWord {
            viewModel.completeWord(word.id)
        }
        moveToNext()
    }
    
    func handleDontKnow() {
        moveToNext()
    }
    
    func moveToNext() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showResult = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if currentIndex < words.count - 1 {
                currentIndex += 1
                isFlipped = false
                showResult = false
            } else {
                onBack()
            }
        }
    }
}

struct FlashcardView: View {
    let word: VocabularyWord
    @Binding var isFlipped: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 20, y: 10)
            
            VStack(spacing: 24) {
                if !isFlipped {
                    // Front - Word
                    VStack(spacing: 16) {
                        Text(word.word)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.primary)
                        
                        if let pronunciation = word.pronunciation {
                            HStack(spacing: 8) {
                                Button(action: {}) {
                                    Image(systemName: "speaker.wave.2.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.secondary)
                                        .frame(width: 32, height: 32)
                                        .background(Color.gray.opacity(0.1))
                                        .clipShape(Circle())
                                }
                                
                                Text(pronunciation)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Text("Tap to see definition")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 16)
                    }
                } else {
                    // Back - Definition & Example
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Definition")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(word.definition)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Example")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("\"\(word.example)\"")
                                .font(.body)
                                .italic()
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(32)
        }
        .frame(height: 400)
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .onTapGesture {
            withAnimation(.spring()) {
                isFlipped.toggle()
            }
        }
    }
}
