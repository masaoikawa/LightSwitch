//
//  InterfaceController.swift
//  BLETest WatchKit Extension
//
//  Created by 井川 雅央 on 2015/06/04.
//  Copyright (c) 2015年 井川 雅央. All rights reserved.
//

import WatchKit
import Foundation
import CoreBluetooth


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
        WKInterfaceController.openParentApplication(["countValue": "\(1)"],
            reply: {replyInfo, error in
                if let error = error {
                    println("Error.")
                }
                if let replyInfo = replyInfo {
                    var title: String? = replyInfo["fromApp"] as? String
                    self.btnLabel?.setTitle( title )
                }
        })
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
