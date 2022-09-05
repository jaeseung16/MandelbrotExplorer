//
//  MandelbrotExplorerApp.swift
//  MandelbrotExplorer iPad
//
//  Created by Jae Seung Lee on 8/13/22.
//  Copyright © 2022 Jae Seung Lee. All rights reserved.
//

import SwiftUI
import OSLog
import CoreData
import Persistence

@main
struct MandelbrotExplorerApp: App {
    @AppStorage("HasLaunchedBefore", store: UserDefaults.standard) var hasLaunchedBefore: Bool = false
    
    private static let logger = Logger()
    
    var body: some Scene {
        let viewModel = MandelbrotExplorerViewModel(persistence: persistence)
        
        WindowGroup {
            if !hasLaunchedBefore {
                FirstLaunchView()
                    .environment(\.managedObjectContext, viewModel.persistenceContainer.viewContext)
                    .environmentObject(viewModel)
            } else {
                MandelbrotListView()
                    .environment(\.managedObjectContext, viewModel.persistenceContainer.viewContext)
                    .environmentObject(viewModel)
            }
        }
    }
}
