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
    
    @IBOutlet weak var btnLabel: WKInterfaceButton?

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
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
        let data:[String : AnyObject] = ["countValue": "\(1)"]   //This is the data you will send
        
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
        if (WCSession.defaultSession().reachable) {
            WCSession.defaultSession().sendMessage(data,
                replyHandler: { userInfo in
                    print("Info Received: \(userInfo)")
                    self.btnLabel?.setTitle( userInfo["fromApp"] as? String )
                },
                errorHandler: { (error:NSError) -> Void in
                    print("WatchKit communication error: \(error.localizedDescription)")
            })
            
        }
    }
    
    

}
