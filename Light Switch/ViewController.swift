//
//  ViewController.swift
//  Light Switch
//
//  Created by 井川 雅央 on 2015/09/24.
//  Copyright © 2015年 井川 雅央. All rights reserved.
//

import UIKit
import CoreBluetooth
import WatchConnectivity

class ViewController: UIViewController, DiscoveryDelegate {

    @IBOutlet weak var btnLabel: UIButton!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    internal var discovery: BLEDiscovery!
    
    // MARK:delegate - ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        dispatch_async(dispatch_get_main_queue(), { () in
            self.btnLabel.highlighted = true
            self.btnLabel.enabled = false
            self.temperatureLabel.text = "Now Starting."
        })
        
        discovery = BLEDiscoverySharedInstance
        discovery.delegate = self
        
        /*
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }*/
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
        

}

