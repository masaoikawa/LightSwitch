//
//  InterfaceController.swift
//  BLETest WatchKit Extension
//
//  Created by 井川 雅央 on 2015/06/04.
//  Copyright (c) 2015年 井川 雅央. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var btnLabel: WKInterfaceButton?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }
    
    @IBAction func sendOn() {
        //Send count to parent application
        let data = ["countValue": "\(1)"]   //This is the data you will send
        /*
        WCSession.defaultSession().sendMessageData(data,
            replyHandler: <#T##((NSData) -> Void)?##((NSData) -> Void)?##(NSData) -> Void#>,
            errorHandler: <#T##((NSError) -> Void)?##((NSError) -> Void)?##(NSError) -> Void#>)
        */
        
        
        WCSession.defaultSession().sendMessage(data,
            replyHandler: { (reply) -> Void in
                if let replyInfo = reply as? [String: String], title = replyInfo["fromApp"] {
                    self.btnLabel?.setTitle( title )
                }
            },
            errorHandler: { (NSError) -> Void in
                print("SendOn Error")
            }
        )
        
        /*
        WKInterfaceController.openParentApplication(["countValue": "\(1)"]) {
            (reply, error) -> Void in
            if let replyInfo = reply as? [String: String], title = replyInfo["fromApp"] {
                    self.btnLabel?.setTitle( title )
            }
        }
        */
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
