//
//  ViewController.swift
//  Light Switch
//
//  Created by 井川 雅央 on 2015/06/04.
//  Copyright (c) 2015年 井川 雅央. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, DiscoveryDelegate {
    
    @IBOutlet weak var btnLabel: UIButton!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    internal var discovery: BLDiscovery!
    
    // MARK:delegate - ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        btnLabel.highlighted = true
        btnLabel.enabled = false
        temperatureLabel.text = "Now Starting."
        
        discovery = blDiscoverySharedInstance
        discovery.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK:delegate - Discovery
    
    func didConnect() {
        btnLabel.highlighted = false
        btnLabel.enabled = true
        temperatureLabel.text = "Connected"
    }
    
    func didDisconnect() {
        btnLabel.highlighted = true
        btnLabel.enabled = false
        temperatureLabel.text = "DisConnected"
    }
    
    func didUpdateState(message: String) {
        temperatureLabel.text = message
    }
    
    
    // MARK: @IBAction
    
    @IBAction func sendButton(sender: AnyObject) {
        
        if !discovery.switchState.boolValue {
            btnLabel.setTitle("Off", forState: .Normal)
            
            discovery.sendOn()
            discovery.switchState = true
            discovery.readState()
        } else {
            btnLabel.setTitle("On", forState: .Normal)
            
            discovery.sendOff()
            discovery.switchState = false
            discovery.readState()
        }
    }
    
}

