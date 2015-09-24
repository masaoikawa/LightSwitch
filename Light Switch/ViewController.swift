//
//  ViewController.swift
//  Light Switch
//
//  Created by 井川 雅央 on 2015/06/04.
//  Copyright (c) 2015年 井川 雅央. All rights reserved.
//

import UIKit
import CoreBluetooth
import WatchConnectivity

class ViewController: UIViewController, DiscoveryDelegate, WCSessionDelegate {
    
    @IBOutlet weak var btnLabel: UIButton!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    internal var discovery: BLDiscovery!
    
    // MARK:delegate - ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        dispatch_async(dispatch_get_main_queue(), { () in
            self.btnLabel.highlighted = true
            self.btnLabel.enabled = false
            self.temperatureLabel.text = "Now Starting."
        })
        
        discovery = blDiscoverySharedInstance
        discovery.delegate = self
        
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK:delegate - Discovery
    
    func didConnect() {
        dispatch_async(dispatch_get_main_queue(), { () in
            self.btnLabel.highlighted = false
            self.btnLabel.enabled = true
            self.temperatureLabel.text = "Connected"
        })
    }
    
    func didDisconnect() {
        dispatch_async(dispatch_get_main_queue(), { () in
            self.btnLabel.highlighted = true
            self.btnLabel.enabled = false
            self.temperatureLabel.text = "DisConnected"
        })
    }
    
    func didUpdateState(message: String) {
        dispatch_async(dispatch_get_main_queue(), { () in
            self.temperatureLabel.text = message
        })
    }
    
    
    // MARK: @IBAction
    
    @IBAction func sendButton(sender: AnyObject) {
        
        if !discovery.switchState.boolValue {
            dispatch_async(dispatch_get_main_queue(), { () in
                self.btnLabel.setTitle("Off", forState: .Normal)
            })
            
            discovery.sendOn()
            discovery.switchState = true
            discovery.readState()
        } else {
            dispatch_async(dispatch_get_main_queue(), { () in
                self.btnLabel.setTitle("On", forState: .Normal)
            })
            
            discovery.sendOff()
            discovery.switchState = false
            discovery.readState()
        }
    }
    
    //MARK: WCSession - delegate
    
    // UserInfo Message
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        /*
        dispatch_async(dispatch_get_main_queue(), { () in
        self.resultTextView!.text = String(format: "%s: %@", arguments: [ __FUNCTION__, message])
        })*/
/*        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let vc:ViewController? = appDel.window?.rootViewController as? ViewController
        vc?.sendButton(self)
        let title : String? = vc?.btnLabel.titleLabel?.text
*/
        sendButton(self)
        let title : String = self.btnLabel.titleLabel!.text!
        let applicationDict:[String:AnyObject]
        if (title == "On") {
            // 送信側
            applicationDict = ["fromApp": "Off"]
        }else{
            applicationDict = ["fromApp": "On"]
        }
        
        WCSession.defaultSession().transferUserInfo(applicationDict)
    }
    
}

