//
//  AppDelegate.swift
//  Light Switch
//
//  Created by 井川 雅央 on 2015/09/24.
//  Copyright © 2015年 井川 雅央. All rights reserved.
//

import UIKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    @available(iOS 9.3, *)
    public func sessionDidDeactivate(_ session: WCSession) {
    
    }

    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    
    }

    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    @available(iOS 9.3, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {
    }


    var window: UIWindow?

    // MARK:(デリゲート アプリケーション 起動直後)
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        print("didFinishLaunchingWithOptions")
        
        self.createShortcutItemsWithIcons()
        
        // Override point for customization after application launch.
        // ビューコントローラー生成
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let viewController:ViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        
        BLEDiscoverySharedInstance.setupCentralManager()
        
        if (WCSession.isSupported()) {
            let session = WCSession.default()
            session.delegate = self
            session.activate()
        }

        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        print("Call Shortcut\(shortcutItem)")
        if (shortcutItem.type=="Switch"){
            BLEDiscoverySharedInstance.startScanning()
            BLEDiscoverySharedInstance.sendOn()
        }else{
            BLEDiscoverySharedInstance.startScanning()
            BLEDiscoverySharedInstance.sendOff()
        }
        
        completionHandler(true)
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        let request:String = (message["countValue"] as? String)!
        
        print("countValue: \(request)")
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let vc:ViewController? = appDel.window?.rootViewController as? ViewController
        vc?.sendButton(self)
        let title : String? = vc?.btnLabel.titleLabel?.text
        let applicationDict:[String:AnyObject]
        if (title == "On") {
            // 送信側
            BLEDiscoverySharedInstance.startScanning()
            BLEDiscoverySharedInstance.sendOn()
            applicationDict = ["fromApp": "Off" as AnyObject]
        }else{
            BLEDiscoverySharedInstance.startScanning()
            BLEDiscoverySharedInstance.sendOff()
            applicationDict = ["fromApp": "On" as AnyObject]
        }
        replyHandler(applicationDict)
        
    }

    // MARK:
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        print("WillResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("applicationDidEnterBackground")
        BLEDiscoverySharedInstance.disConnect()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        print("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("applicationDidBecomeActive")
        //BLEDiscoverySharedInstance.startScanning()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("WillTerminate")
    }
    
    // MARK: Springboard Shortcut Items (dynamic)
    
    func createShortcutItemsWithIcons() {
        
        // create some icons with my own images
        let icon1 = UIApplicationShortcutIcon.init(type: .play)
        let icon2 = UIApplicationShortcutIcon.init(type: .pause)
        let icon3 = UIApplicationShortcutIcon.init(type: .compose)
        
        // create dynamic shortcut items
        let item1 = UIMutableApplicationShortcutItem(type: "Switch", localizedTitle: "On", localizedSubtitle: "turn switch on", icon: icon1, userInfo: nil)
        let item2 = UIMutableApplicationShortcutItem.init(type: "com.test.deep1", localizedTitle: "Off", localizedSubtitle: "turn switch off", icon: icon2, userInfo: nil)
        let item3 = UIMutableApplicationShortcutItem.init(type: "com.test.deep2", localizedTitle: "Launch 2nd", localizedSubtitle: "Launch 2nd Level", icon: icon3, userInfo: nil)
        
        // add all items to an array
        let items = [item1, item2] as Array
        
        // add this array to the potentially existing static UIApplicationShortcutItems
        //let existingItems: Array = UIApplication.shared.shortcutItems! as Array
        let updatedItems: Array = /*existingItems +*/ items
        UIApplication.shared.shortcutItems = updatedItems
        
    }
    
}

