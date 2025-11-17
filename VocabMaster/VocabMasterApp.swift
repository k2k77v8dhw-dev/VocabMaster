//
//  VocabMasterApp.swift
//  VocabMaster
//

import SwiftUI

@main
struct VocabMasterApp: App {
    @StateObject private var viewModel: VocabularyViewModel
    
    init() {
        // Create the configured data provider
        let provider = DataProviderFactory.createConfiguredProvider()
        _viewModel = StateObject(wrappedValue: VocabularyViewModel(dataProvider: provider))
        
        // Debug: Reset data on launch if configured
        #if DEBUG
        if AppConfiguration.Debug.resetDataOnLaunch {
            Task {
                try? await provider.resetAllData()
            }
        }
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .onAppear {
                    // Optional: Sync on app launch if using cloud provider
                    if viewModel.supportsSyncing && AppConfiguration.Features.enableSync {
                        viewModel.syncData()
                    }
                }
        }
    }
}
