//
//  VocabularyHomeView.swift
//  VocabMaster
//

import SwiftUI

struct VocabularyHomeView: View {
    @EnvironmentObject var viewModel: VocabularyViewModel
    let onStartStudy: (CategoryType) -> Void
    let onViewProgress: () -> Void
    let onManageVocabulary: () -> Void
    
    var totalWords: Int {
        viewModel.getTotalWords(for: viewModel.currentLanguage)
    }
    
    var completedCount: Int {
        viewModel.getCompletedWordsCount(for: viewModel.currentLanguage)
    }
    
    var completionPercentage: Int {
        guard totalWords > 0 else { return 0 }
        return Int((Double(completedCount) / Double(totalWords)) * 100)
    }
    
    var availableCategories: [CategoryType] {
        viewModel.getAvailableCategories(for: viewModel.currentLanguage)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                HStack(alignment: .center) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 48, height: 48)
                            
                            Image(systemName: "book.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                        .shadow(radius: 8)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("VocabMaster")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Learn new words daily")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        LanguageSelectorButton()
                        
                        Button(action: onManageVocabulary) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.primary)
                                .frame(width: 40, height: 40)
                                .background(Color(.systemBackground))
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 32)
                
                // Progress Card
                Button(action: onViewProgress) {
                    VStack(spacing: 16) {
                        HStack {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .foregroundColor(.blue)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Your Progress")
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    Text("\(completedCount) of \(totalWords) words")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Text("\(completionPercentage)%")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(LinearGradient(
                                        colors: [Color.blue, Color.blue.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .frame(width: geometry.size.width * CGFloat(completionPercentage) / 100, height: 8)
                                    .animation(.easeInOut, value: completionPercentage)
                            }
                        }
                        .frame(height: 8)
                    }
                    .padding(24)
                    .background(Color(.systemBackground))
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, y: 4)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                
                // Categories
                VStack(alignment: .leading, spacing: 16) {
                    Text("Study Categories")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal, 24)
                    
                    if availableCategories.isEmpty {
                        VStack(spacing: 12) {
                            Text("No vocabulary available in this language")
                                .foregroundColor(.secondary)
                            Button(action: onManageVocabulary) {
                                Text("Add vocabulary")
                                    .foregroundColor(.blue)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(48)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                    } else {
                        ForEach(availableCategories, id: \.self) { categoryType in
                            CategoryCard(
                                categoryType: categoryType,
                                onTap: { onStartStudy(categoryType) }
                            )
                            .padding(.horizontal, 24)
                        }
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.05), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

struct CategoryCard: View {
    @EnvironmentObject var viewModel: VocabularyViewModel
    let categoryType: CategoryType
    let onTap: () -> Void
    
    var words: [VocabularyWord] {
        viewModel.getCategoryWords(type: categoryType, language: viewModel.currentLanguage)
    }
    
    var completedCount: Int {
        words.filter { viewModel.completedWords.contains($0.id) }.count
    }
    
    var progress: Int {
        guard words.count > 0 else { return 0 }
        return Int((Double(completedCount) / Double(words.count)) * 100)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(categoryType.color.opacity(0.15))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: categoryType.icon)
                            .font(.system(size: 22))
                            .foregroundColor(categoryType.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(categoryType.name)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Text("\(words.count) words")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(completedCount)/\(words.count)")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Text("\(progress)%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(categoryType.color)
                            .frame(width: geometry.size.width * CGFloat(progress) / 100, height: 6)
                            .animation(.easeInOut, value: progress)
                    }
                }
                .frame(height: 6)
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
