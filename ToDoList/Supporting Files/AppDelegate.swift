//
//  AppDelegate.swift
//  ToDoList
//
//  Created by Sidany Walker on 11/4/20.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    //LifeCycle: app launched -> app visible -> app recedes into background -> resources reclaimed by operating sys


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //this gets called when your app gets loaded up, the first thing that happens before the ViewDidLoad inside the initial ViewController
        print("didFinishLaunchingWithOptions")
        
        //write the code to print out the file path for our user defaults file (getting into our sandbox):
        //print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)

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
        print("didDiscardSceneSessions")
    }


}

