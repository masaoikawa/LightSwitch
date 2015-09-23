//
//  AppDelegate.swift
//  Light Switch
//
//  Created by 井川 雅央 on 2015/06/04.
//  Copyright (c) 2015年 井川 雅央. All rights reserved.
//

import UIKit
import CoreBluetooth
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
    
    var window: UIWindow?
    //var viewController: UIViewController?
    var session: WCSession?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        print("didFinishLaunchingWithOptions")
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let viewController:ViewController = storyboard.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
        //self.window?.backgroundColor = UIColor.whiteColor()
        
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        
        blDiscoverySharedInstance.setupCentralManager()
        
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session!.delegate = self
            session!.activateSession()
        }
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        print("WillResignActive")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        print("applicationDidEnterBackground")
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        print("applicationWillEnterForeground")
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        print("WillTerminate")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func session(session: WCSession, didReceiveMessageData messageData: NSData, replyHandler: (NSData) -> Void) {


    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        _ = applicationContext 
        //var _counterValue = info["countValue"] as! String
        
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let vc:ViewController? = appDel.window?.rootViewController as? ViewController
        vc?.sendButton(self)
        let title : String? = vc?.btnLabel.titleLabel?.text
        
        
        let applicationDict:[String:AnyObject]
        if (title == "On") {
            // 送信側
            applicationDict = ["fromApp": "Off"]
        }else{
            applicationDict = ["fromApp": "On"]
        }
        try! WCSession.defaultSession().updateApplicationContext(applicationDict)
    }
    
}

