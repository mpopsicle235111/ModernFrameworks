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
        
        return true
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

