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

@main
struct MandelbrotExplorerApp: App {
    private static let logger = Logger()
    
    private var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "MandelbrotExplorer_iPad")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                MandelbrotExplorerApp.logger.log("Failed to save: \(error.localizedDescription)")
            }
            MandelbrotExplorerApp.logger.log("storeDescription=\(storeDescription)")
        }
        return container
    }()
    
    var body: some Scene {
        WindowGroup {
            MandelbrotListView()
                .environment(\.managedObjectContext, persistentContainer.viewContext)
                .environmentObject(MandelbrotExplorerViewModel())
        }
    }
}
