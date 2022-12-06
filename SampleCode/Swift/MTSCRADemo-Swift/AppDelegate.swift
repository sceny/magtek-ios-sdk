//
//  AppDelegate.swift
//  MTSCRADemo-Swift
//
//  Created by Tam Nguyen on 9/10/15.
//  Copyright © 2015 MagTek. All rights reserved.
//

import UIKit




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navController: UINavigationController?

       func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {


       // let titleDict: NSDictionary =;
        UITabBarItem.appearance().setTitleTextAttributes( [NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)], for: UIControl.State());
        UITabBarItem.appearance().setTitleTextAttributes( [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xcc3333), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)], for: UIControl.State.selected);
 
        

        self.window = UIWindow.init(frame: UIScreen.main.bounds);
        
        self.window?.backgroundColor = UIColor.white;
        
        let idVC = iDynamoController();
        let auVC = audioController();
        let dyVC = DynaMAXController();
        let eVC = eDynamoController();
        let kVC = kDynamoController();
        let tlvParser = TLVParserControllerViewController();

        
        let iNav = UINavigationController(rootViewController: idVC);
        iNav.navigationBar.isTranslucent = false;
        iNav.tabBarItem = UITabBarItem(title: "Lightning", image: nil, tag: 0);
        iNav.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -16) // UIOffsetMake(0, -16);
        
        let kNav = UINavigationController(rootViewController: kVC);
        kNav.navigationBar.isTranslucent = false;
        kNav.tabBarItem = UITabBarItem(title: "Lightning EMV", image: nil, tag: 0);
        kNav.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -16) //UIOffsetMake(0, -16);
        
        let auNav = UINavigationController(rootViewController: auVC);
        auNav.navigationBar.isTranslucent = false;
        auNav.tabBarItem = UITabBarItem(title: "Audio", image: nil, tag: 0);
        auNav.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -16) //UIOffsetMake(0, -16);
        
        
        let dyNav = UINavigationController(rootViewController: dyVC);
        dyNav.navigationBar.isTranslucent = false;
        dyNav.tabBarItem = UITabBarItem(title: "Bluetooth LE", image: nil, tag: 0);
        dyNav.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -16) //UIOffsetMake(0, -16);
        
        let evNav = UINavigationController(rootViewController: eVC);
        evNav.navigationBar.isTranslucent = false;
        evNav.tabBarItem = UITabBarItem(title: "Bluetooth LE EMV", image: nil, tag: 0);
        evNav.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -16) //UIOffsetMake(0, -16);
        
        let tlvNav = UINavigationController(rootViewController: tlvParser)
        tlvNav.navigationBar.isTranslucent = false
        tlvNav.tabBarItem = UITabBarItem(title: "TLV Parser", image: nil, tag: 0)
        tlvNav.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -16) //UIOffsetMake(0, -16);
        

        let tabBarController = UITabBarController();
        tabBarController.viewControllers = [iNav,kNav, auNav, dyNav, evNav,tlvNav];
        tabBarController.tabBar.isTranslucent = false;
        
        self.window?.rootViewController = tabBarController;
        self.window?.makeKeyAndVisible();
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

