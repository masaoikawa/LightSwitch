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
            }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    @IBAction func sendOn() {
        //Send count to parent application
        let data:[String : AnyObject] = ["countValue": "\(1)"]   //This is the data you will send
        
        // 送信側
        WCSession.defaultSession().transferUserInfo( data )
        
        /*
        WKInterfaceController.openParentApplication(["countValue": "\(1)"]) {
            (reply, error) -> Void in
            if let replyInfo = reply as? [String: String], title = replyInfo["fromApp"] {
                    self.btnLabel?.setTitle( title )
            }
        }
        */
        
    }
    /*
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        let title = userInfo["fromApp"] as! String
        self.btnLabel?.setTitle( title )
    }*/
    
    
}
