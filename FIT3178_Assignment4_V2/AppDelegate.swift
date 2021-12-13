//
//  AppDelegate.swift
//  FIT3178_Assignment4_V2
//
//  Created by Yushu Guo on 4/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//




import UIKit
import Firebase


enum Mode: String, CaseIterable{
    case Smart = "Smart"
    case Normal = "Normal"
    case NoAlarm = "NoAlarm"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    var databaseController: DatabaseProtocol?
    var user: User?                     // Application user, Shared between view controller
    
    // Alarm status data
    var alarmMode: Mode = Mode.Smart    // Default alarm mode
    var alarmSound = "storybook"         // Default alarm sound
    
    // Sleep status data
    var extraSleep: Int?                                // Speated from yesterday
    var todaySleep: Int         = 0                     // Today total sleep time
    var lastSleep: Int          = 0                     // The time of last sleep
    var sleepSpeed: Double      = 3.0
    var sleepAtTime: Double     = 10.0 / 12.0 * 6.0     // Default time is 10
    var neeedSleepTime: Double  = 7.0 / 12.0 * 6.0      // Default time is 7
    

    static let CATEGORY_IDENTIFIER = "edu.monash.fit3178.category1"
    var notificationsEnabled = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
    
        databaseController = FirebaseController()
        
        // Used to set up notification
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (granted, error) in
//            self.notificationsEnabled = granted
//            print("User allows notifcations: \(granted)")
//
//            if self.notificationsEnabled {
//                let acceptAction  = UNNotificationAction(identifier: "accept", title: "Accept", options: .foreground)
//                let declineAction = UNNotificationAction(identifier: "decline", title: "Decline", options: .destructive)
//                let commentAction = UNTextInputNotificationAction(identifier: "comment", title: "Comment", options: .authenticationRequired, textInputButtonTitle: "Send", textInputPlaceholder: "Share your thoughts..")
//
//                // Set up the category
//                let appCategory = UNNotificationCategory(identifier: AppDelegate.CATEGORY_IDENTIFIER, actions: [acceptAction, declineAction, commentAction], intentIdentifiers: [], options: UNNotificationCategoryOptions(rawValue: 0))
//
//                // Register the category just created with the notification centre
//                UNUserNotificationCenter.current().setNotificationCategories([appCategory])
//            }
//        }
        return true
    }

    // MARK: UISceneSession Lifecycle

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


}

