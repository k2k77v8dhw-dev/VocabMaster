//
//  ContentView.swift
//  VocabMaster
//

import SwiftUI

enum AppView {
    case home, study, progress, manage, add
}

struct ContentView: View {
    @EnvironmentObject var viewModel: VocabularyViewModel
    @State private var currentView: AppView = .home
    @State private var selectedCategory: CategoryType?
    
    var body: some View {
        NavigationView {
            ZStack {
                switch currentView {
                case .home:
                    VocabularyHomeView(
                        onStartStudy: { category in
                            selectedCategory = category
                            currentView = .study
                        },
                        onViewProgress: {
                            currentView = .progress
                        },
                        onManageVocabulary: {
                            currentView = .manage
                        }
                    )
                    
                case .study:
                    if let category = selectedCategory {
                        FlashcardStudyView(
                            category: category,
                            onBack: {
                                currentView = .home
                                selectedCategory = nil
                            }
                        )
                    }
                    
                case .progress:
                    ProgressTrackerView(
                        onBack: { currentView = .home }
                    )
                    
                case .manage:
                    ManageVocabularyView(
                        onBack: { currentView = .home },
                        onAddVocabulary: { currentView = .add }
                    )
                    
                case .add:
                    AddVocabularyWizardView(
                        onBack: { currentView = .manage }
                    )
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(VocabularyViewModel())
    }
}
