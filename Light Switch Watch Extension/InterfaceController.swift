//
//  InterfaceController.swift
//  Light Switch Watch Extension
//
//  Created by 井川 雅央 on 2015/09/24.
//  Copyright © 2015年 井川 雅央. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
   // @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }

    
    @IBOutlet weak var btnLabel: WKInterfaceButton?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        if (WCSession.isSupported()) {
            let session = WCSession.default()
            session.delegate = self
            session.activate()
        }

    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func sendOn() {
        //Send count to parent application
        let data:[String : AnyObject] = ["countValue": "\(1)" as AnyObject]   //This is the data you will send
        
        // 送信側
        //WCSession.defaultSession().transferUserInfo( data )
        
        /*
        WKInterfaceController.openParentApplication(["countValue": "\(1)"]) {
        (reply, error) -> Void in
        if let replyInfo = reply as? [String: String], title = replyInfo["fromApp"] {
        self.btnLabel?.setTitle( title )
        }
        }
        */
        if (WCSession.default().isReachable) {
            WKInterfaceDevice.current().play(WKHapticType.click)
            WCSession.default().sendMessage(data,
                replyHandler: { (userInfo) -> Void in
                    print("Info Received: \(userInfo)")
                    self.btnLabel?.setTitle( userInfo["fromApp"] as? String )
                    WKInterfaceDevice.current().play(WKHapticType.success)
                },
                errorHandler: { (error:Error) -> Void in
                    print("WatchKit communication error: \(error.localizedDescription)")
                    WKInterfaceDevice.current().play(WKHapticType.failure)
            })
        }else{
            WKInterfaceDevice.current().play(WKHapticType.failure)
        }
    }
    
    

}
