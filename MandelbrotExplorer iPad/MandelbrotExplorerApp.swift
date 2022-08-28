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
    private static let logger = Logger()
    
    var body: some Scene {
        let persistence = Persistence(name: "MandelbrotExplorer_iPad", identifier: "", isCloud: false)
        let viewModel = MandelbrotExplorerViewModel(persistence: persistence)
        
        WindowGroup {
            MandelbrotListView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .environmentObject(viewModel)
        }
    }
}
