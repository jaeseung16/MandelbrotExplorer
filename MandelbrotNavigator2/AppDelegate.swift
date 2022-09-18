//
//  AppDelegate.swift
//  SearchPubChem
//
//  Created by Jae Seung Lee on 6/20/22.
//  Copyright © 2022 Jae Seung Lee. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import CloudKit
import os
import Persistence

class AppDelegate: NSObject {
    private let logger = Logger()
    
    private let subscriptionID = "mandelbrotentity-updated"
    private let didCreateMandelbrotEntitySubscription = "didCreateMandelbrotEntitySubscription"
    private let recordType = "CD_MandelbrotEntity"
    private let maxIterValueKey = "CD_maxIter"
    private let generatorValueKey = "CD_generator"
    private let minRealValueKey = "CD_minReal"
    private let maxRealValueKey = "CD_maxReal"
    private let minImaginaryValueKey = "CD_minImaginary"
    private let maxImaginaryValueKey = "CD_maxImaginary"
    
    private let databaseOperationHelper = DatabaseOperationHelper(appName: MandelbrotExplorerConstants.modelName.rawValue)
    
    private var database: CKDatabase {
        CKContainer(identifier: MandelbrotExplorerConstants.containerIdentifier.rawValue).privateCloudDatabase
    }
    
    let persistence: Persistence
    let viewModel: MandelbrotExplorerViewModel
    
    override init() {
        self.persistence = Persistence(name: MandelbrotExplorerConstants.modelName.rawValue, identifier: MandelbrotExplorerConstants.containerIdentifier.rawValue, isCloud: true)
        self.viewModel = MandelbrotExplorerViewModel(persistence: persistence)
        
        super.init()
    }
    
    private func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
                guard granted else {
                    return
                }
                self?.getNotificationSettings()
            }
    }

    private func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                return
            }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    private func subscribe() {
        guard !UserDefaults.standard.bool(forKey: didCreateMandelbrotEntitySubscription) else {
            logger.log("alredy true: didCreateMandelbrotEntitySubscription=\(UserDefaults.standard.bool(forKey: self.didCreateMandelbrotEntitySubscription))")
            return
        }
        
        let subscriber = Subscriber(database: database, subscriptionID: subscriptionID, recordType: recordType)
        subscriber.subscribe { result in
            switch result {
            case .success(let subscription):
                self.logger.log("Subscribed to \(subscription, privacy: .public)")
                UserDefaults.standard.setValue(true, forKey: self.didCreateMandelbrotEntitySubscription)
                self.logger.log("set: didCreateMandelbrotEntitySubscription=\(UserDefaults.standard.bool(forKey: self.didCreateMandelbrotEntitySubscription))")
            case .failure(let error):
                self.logger.log("Failed to modify subscription: \(error.localizedDescription, privacy: .public)")
                UserDefaults.standard.setValue(false, forKey: self.didCreateMandelbrotEntitySubscription)
            }
        }
    }
    
    private func processRemoteNotification() {
        databaseOperationHelper.addDatabaseChangesOperation(database: database) { result in
            switch result {
            case .success(let record):
                self.processRecord(record)
            case .failure(let error):
                self.logger.log("Failed to process remote notification: error=\(error.localizedDescription, privacy: .public)")
            }
        }
    }
    
    private func processRecord(_ record: CKRecord) {
        logger.log("Processing \(record, privacy: .public)")
        
        guard record.recordType == recordType else {
            return
        }
        
        let maxIter = record.value(forKey: maxIterValueKey) as? Int
        let generator = record.value(forKey: generatorValueKey) as? String
        
        let minReal = record.value(forKey: minRealValueKey) as? Double
        let maxReal = record.value(forKey: maxRealValueKey) as? Double
        let minImaginary = record.value(forKey: minImaginaryValueKey) as? Double
        let maxImaginary = record.value(forKey: maxImaginaryValueKey) as? Double
        
        logger.log("minReal=\(String(describing: minReal), privacy: .public)")
        logger.log("maxReal=\(String(describing: maxReal), privacy: .public)")
        logger.log("minImaginary=\(String(describing: minImaginary), privacy: .public)")
        logger.log("maxImaginary=\(String(describing: maxImaginary), privacy: .public)")
        
        let avgReal = (minReal != nil && maxReal != nil) ? 0.5 * (minReal! + maxReal!) : nil
        let avgImaginary = (minImaginary != nil && maxImaginary != nil) ? 0.5 * (minImaginary! + maxImaginary!) : nil
        
        let format = "%.3f"
        let centerDescription = (avgReal != nil && avgImaginary != nil) ? "(\(String(format: format, avgReal!)), \(String(format: format, avgImaginary!)))" : "N/A"
        
        let originalRange = 3.0
        let scale = (minReal != nil && maxReal != nil) ? originalRange / (maxReal! - minReal!) : nil
        let scaleDescription = scale == nil ? "N/A" : (scale! < 100000 ? String(format: "%.2f", scale!) : formatter.string(from: scale! as NSNumber))
        
        var body = "center: \(centerDescription)\n"
        if let scaleDescription = scaleDescription {
            body += "scale: \(scaleDescription)\n"
        }
        if let maxIter = maxIter {
            body += "iterations: \(maxIter)\n"
        }
        if let generator = generator {
            body += "device: \(generator)"
        }
        
        let content = UNMutableNotificationContent()
        content.title = MandelbrotExplorerConstants.appName.rawValue
        content.body = body
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
        
        logger.log("Processed \(record, privacy: .public)")
    }
    
    private var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .scientific
        formatter.minimumSignificantDigits = 2
        formatter.maximumSignificantDigits = 5
        return formatter
    }
    
}

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        logger.log("didFinishLaunchingWithOptions")
        UNUserNotificationCenter.current().delegate = self
        
        registerForPushNotifications()
        
        // TODO: - Remove or comment out after testing
        //UserDefaults.standard.setValue(false, forKey: didCreateCompoundSubscription)
        
        subscribe()

        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }
        let token = tokenParts.joined()
        logger.log("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        logger.log("Failed to register: \(String(describing: error))")
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) else {
            logger.log("notification=failed")
            completionHandler(.failed)
            return
        }
        logger.log("notification=\(String(describing: notification))")
        if !notification.isPruned && notification.notificationType == .database {
            if let databaseNotification = notification as? CKDatabaseNotification, databaseNotification.subscriptionID == subscriptionID {
                logger.log("databaseNotification=\(String(describing: databaseNotification.subscriptionID))")
                processRemoteNotification()
            }
        }
        
        completionHandler(.newData)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        logger.info("userNotificationCenter: notification=\(notification)")
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
