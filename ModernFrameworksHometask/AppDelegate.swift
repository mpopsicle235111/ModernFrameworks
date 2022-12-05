//
//  AppDelegate.swift
//  ModernFrameworksHometask
//
//  Created by Anton Lebedev on 17.10.2022.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    //Added to use the CoreData
    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "MapTrackerLoginStorage")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {

                fatalError("Unresolved error, \((error as NSError).userInfo)")
            }
        })
        return container
    }()
    
    //Added to use the Coordinator
    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //Added to use the Coordinator
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController()
        appCoordinator = AppCoordinator(navigationController: navigationController)
        appCoordinator?.start()
        window?.rootViewController = navigationController //Define root controller
        window?.makeKeyAndVisible() //A command to show root controller
        
        //Added for local push notifications
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        requestPermissionForPushMessages(center: center)
        
        return true
    }
    
    //Added for local push notifications
    func requestPermissionForPushMessages(center: UNUserNotificationCenter) {
        let center = UNUserNotificationCenter.current() //Singleton detected!
        //Badge is a little red dot with a number of notifications
        //Permission can be granted, can not be granted, and there can be an error
        center.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            guard granted else {
                print("WARNING: user permission is not granted!")
                return
            }
            //Guard here so we do not have to unwrap content and trigger below
            guard let self = self else { return }
                
            //If all is OK (user granted us them rights), we send the notification
            //with specified content, triggered by the specified trigger
            let content = self.createPushMessageContent()
            let trigger = self.createPushMessageTrigger()
                
            self.sendNotificationRequest(content: content, trigger: trigger)
        }
    }
    
    
    //Added for local push notifications
    func createPushMessageContent() -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Knock, knock, Neo."
        content.subtitle = "We have our eye on you."
        content.body = "Please, activate the Map Tracker. Do we make ourselves clear?"
            
        //The above will already work. However, we can add a badge (counter)
        //This is a number in the red circle
        content.badge = 101
            
        //The information and data is inserted into the Notification here.
        //For example, if we need to notify of a chat message, the sender info
        //will be embedded here. Also we have to know, which screen to open
        //if the user decides to perform some action based upon the notification -
        //this info should be here, too.
        //It is a dictionary [key : data]
        content.userInfo = ["message": "Listen to me, coppertop. Right now there is only one rule. Our way or the highway."]
            
        return content
    }
    
    
    //Added for local push notifications
    func createPushMessageTrigger() -> UNNotificationTrigger {
        //Triggers in 30 minutes (1800 seconds), not repeating
        //Since Swift 4.2 one-string funcs do not require a return:
        UNTimeIntervalNotificationTrigger(timeInterval: 1800, repeats: false)
    }
    
    
    //Added for local push notifications
    func sendNotificationRequest(content: UNNotificationContent, trigger: UNNotificationTrigger) {
            let request = UNNotificationRequest(identifier: "timeNotification", content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            center.add(request) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
            
        }

    // MARK: UISceneSession Lifecycle
        // MARK: These are deleted because we deleted the SceneDelegate file AND ALSO THE REFERENCE TO IT IN info.plist
        //    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        //        // Called when a new scene session is being created.
        //        // Use this method to select a configuration to create the new scene with.
        //        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        //    }
        //
        //    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        //        // Called when the user discards a scene session.
        //        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        //        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        //    }


}

//Added for local push notifications
//If we receive a responce (tap) from the user, we perform the following actions:
extension AppDelegate: UNUserNotificationCenterDelegate {
   func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
       
        print("How about I just give you the finger, and you give me my phone call?")
       
        let title = response.notification.request.content.title
        let userInfo = response.notification.request.content.userInfo
        print(title)
   
        //If the message exists, we print it
        if let message = userInfo["message"] as? String {
            print("message: \(message)")
        }
       //Similarly we can use a Coordinator to navigate to the necessary View from here
    }
}

