//
//  ProgressView.swift
//  VocabMaster
//

import SwiftUI

struct ProgressTrackerView: View {
    @EnvironmentObject var viewModel: VocabularyViewModel
    let onBack: () -> Void
    
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
    
    var categoryStats: [(type: CategoryType, completed: Int, total: Int, percentage: Int)] {
        return viewModel.getAvailableCategories(for: viewModel.currentLanguage).map { categoryType in
            let words = viewModel.getCategoryWords(type: categoryType, language: viewModel.currentLanguage)
            let completed = words.filter { viewModel.completedWords.contains($0.id) }.count
            let percentage = words.count > 0 ? Int((Double(completed) / Double(words.count)) * 100) : 0
            return (categoryType, completed, words.count, percentage)
        }
    }
    
    var body: some View {
        ScrollView {
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
                    
                    Text("Your Progress")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    LanguageSelectorButton()
                }
                .padding(.horizontal, 16)
                .padding(.top, 60)
                .padding(.bottom, 32)
                
                // Overall Progress Card
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 48, height: 48)
                            
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Progress")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                            Text("\(completionPercentage)%")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                    }
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("\(completedCount) words learned")
                                .font(.subheadline)
                            Spacer()
                            Text("\(totalWords - completedCount) remaining")
                                .font(.subheadline)
                        }
                        .foregroundColor(.white)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white)
                                    .frame(width: geometry.size.width * CGFloat(completionPercentage) / 100, height: 8)
                                    .animation(.easeInOut, value: completionPercentage)
                            }
                        }
                        .frame(height: 8)
                    }
                }
                .padding(24)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.blue.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(24)
                .shadow(color: Color.blue.opacity(0.3), radius: 20, y: 10)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
                // Stats Grid
                HStack(spacing: 16) {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.1))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "target")
                                .foregroundColor(.green)
                        }
                        
                        Text("Words Mastered")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(completedCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, y: 4)
                    
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.purple.opacity(0.1))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundColor(.purple)
                        }
                        
                        Text("Total Words")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(totalWords)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
                // Category Breakdown
                VStack(alignment: .leading, spacing: 16) {
                    Text("Category Breakdown")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal, 24)
                    
                    if categoryStats.isEmpty {
                        Text("No vocabulary in this language yet")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(48)
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .padding(.horizontal, 24)
                    } else {
                        ForEach(categoryStats, id: \.type) { stat in
                            CategoryProgressCard(
                                categoryType: stat.type,
                                completed: stat.completed,
                                total: stat.total,
                                percentage: stat.percentage
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

struct CategoryProgressCard: View {
    let categoryType: CategoryType
    let completed: Int
    let total: Int
    let percentage: Int
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(categoryType.name)
                    .font(.body)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(completed)/\(total)")
                    .font(.body)
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(categoryType.color)
                            .frame(width: geometry.size.width * CGFloat(percentage) / 100, height: 8)
                            .animation(.easeInOut, value: percentage)
                    }
                }
                .frame(height: 8)
                
                Text("\(percentage)% complete")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 4)
    }
}
