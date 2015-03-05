//
//  AppDelegate.swift
//  HobjectiveRecordDemo-Swift
//
//  Created by 洪明勲 on 2015/03/05.
//  Copyright (c) 2015年 hmhv. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        NSPersistentStoreCoordinator.setupDefaultStore()
        
        // Override point for customization after application launch.
        return true
    }


}

