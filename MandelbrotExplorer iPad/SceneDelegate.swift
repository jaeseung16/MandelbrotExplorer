//
//  SceneDelegate.swift
//  MandelbrotExplorer iPad
//
//  Created by Jae Seung Lee on 10/4/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let dataController = DataController(modelName: "MandelbrotExplorer_iPad")

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        checkIfFirstLaunch()
        if let splitViewController = window?.rootViewController as? UISplitViewController {
            configure(splitViewController)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        saveData()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        //(UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        saveData()
    }


}

extension SceneDelegate {
    func configure(_ splitViewController: UISplitViewController) {
        let viewControllers = splitViewController.viewControllers
        
        print("viewControllers=\(viewControllers)")
        
        guard let navigationViewController = viewControllers.first as? UINavigationController else {
            return
        }
        
        print("navigationViewController=\(navigationViewController)")
        
        guard let topViewController = navigationViewController.topViewController as? MandelbrotExplorerRootViewControllerTableViewController else {
            return
        }
        
        print("topViewController=\(topViewController)")
        
        topViewController.dataController = dataController
        
        //guard let topViewController = navigationViewController.topViewController as? iPadMasterTableViewController else {
        //    return
        //}
        
        //print("topViewController=\(topViewController)")
        
        //topViewController.dataController = dataController
    }
    
    func checkIfFirstLaunch() {
        if !UserDefaults.standard.bool(forKey: "HasLaunchedBefore") {
            print("here")
            preloadData()
            saveData()
            UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
            UserDefaults.standard.synchronize()
        }
    }
    
    func preloadData() {
        do {
            try dataController.dropAllData()
        } catch {
            NSLog("Error while dropping all objects in DB")
        }
        
        let mandelbrotEntity = MandelbrotEntity(context: dataController.viewContext)
        mandelbrotEntity.minReal = -2.1
        mandelbrotEntity.maxReal = 0.9
        mandelbrotEntity.minImaginary = -1.5
        mandelbrotEntity.maxImaginary = 1.5
        mandelbrotEntity.red = 0.0
        mandelbrotEntity.green = 1.0
        mandelbrotEntity.blue = 0.0
        
    }
    
    func saveData() {
        do {
            try dataController.viewContext.save()
        } catch {
            NSLog("Error while saving by AppDelegate")
        }
    }
}
