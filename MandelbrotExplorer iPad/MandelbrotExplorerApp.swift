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
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @AppStorage("HasLaunchedBefore", store: UserDefaults.standard) var hasLaunchedBefore: Bool = false
    
    private static let logger = Logger()
    
    var body: some Scene {
        WindowGroup {
            if !hasLaunchedBefore {
                FirstLaunchView()
                    .environment(\.managedObjectContext, appDelegate.persistence.container.viewContext)
                    .environmentObject(appDelegate.viewModel)
            } else {
                MandelbrotListView()
                    .environment(\.managedObjectContext, appDelegate.persistence.container.viewContext)
                    .environmentObject(appDelegate.viewModel)
            }
        }
    }
}
