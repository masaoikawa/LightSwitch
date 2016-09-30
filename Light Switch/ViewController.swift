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
    // MARK: (DidLoadイベント)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        DispatchQueue.main.async(execute: { () in
            self.btnLabel.isHighlighted = true
            self.btnLabel.isEnabled = true//false
            self.temperatureLabel.text = "Now Starting."
        })
        
        discovery = BLEDiscoverySharedInstance
        discovery.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK:delegate - Discovery
    
    func didConnect() {
        DispatchQueue.main.async(execute: { () in
            self.btnLabel.isHighlighted = false
            self.btnLabel.isEnabled = true
            self.temperatureLabel.text = "Connected"
        })
    }
    
    func didDisconnect() {
        DispatchQueue.main.async(execute: { () in
            self.btnLabel.isHighlighted = true
            self.btnLabel.isEnabled = false
            self.temperatureLabel.text = "DisConnected"
        })
    }
    
    func didUpdateState(_ message: String) {
        DispatchQueue.main.async(execute: { () in
            self.temperatureLabel.text = message
        })
    }
    
    
    // MARK: @IBAction
    
    @IBAction func sendButton(_ sender: AnyObject) {
        
        if !discovery.switchState {
            DispatchQueue.main.async(execute: { () in
                self.btnLabel.setTitle("Off", for: UIControlState())
            })
            
            discovery.sendOn()
            discovery.switchState = true
            //discovery.readState()
        } else {
            DispatchQueue.main.async(execute: { () in
                self.btnLabel.setTitle("On", for: UIControlState())
            })
            
            discovery.sendOff()
            discovery.switchState = false
            //discovery.readState()
        }
    }
        

}

