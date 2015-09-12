//
//  Discover.swift
//  BLETest
//
//  Created by 井川 雅央 on 2015/06/04.
//  Copyright (c) 2015年 井川 雅央. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

let blDiscoverySharedInstance = BLDiscovery()

private let DISCOVERD:String        =       "nRF5x" //"Biscuit" //
private let UUID_VSP_SERVICE:String =       "713D0000-503E-4C75-BA94-3148F18D941E" //VSP
private let UUID_RX:String          =       "713D0002-503E-4C75-BA94-3148F18D941E" //RX
private let UUID_TX:String          =		"713D0003-503E-4C75-BA94-3148F18D941E" //TX


@objc protocol DiscoveryDelegate{
    optional func didConnect()
    optional func didDisconnect()
    optional func didUpdateState(message : String)
}

class BLDiscovery: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    // MARK:property
    var delegate: DiscoveryDelegate?
    var centralManager:CBCentralManager!
    var peripheral:CBPeripheral!
    
    var results: [String]! = []
    var pauseUpdate: Bool! = false
    
    // MARK:init
    override init(){
        super.init()
        
        self.setupCentralManager()
    }
    
    func setupCentralManager() {
        //let centralQueue = dispatch_queue_create("nu.whiletrue", DISPATCH_QUEUE_SERIAL)
        let centralQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)
        let options: Dictionary = [
            CBCentralManagerOptionRestoreIdentifierKey: "myKey"
        ]
        println("Initializing central manager")
        centralManager = CBCentralManager(delegate: self, queue: centralQueue, options: options)
    }
    
    func centralManager(central: CBCentralManager!, willRestoreState dict: [NSObject : AnyObject]!) {
        if let peripherals:[CBPeripheral] = dict[CBCentralManagerRestoredStatePeripheralsKey] as! [CBPeripheral]! {
            println("willRestoreState")
            for peripheral in peripherals {
                if(peripheral.name != nil && peripheral.name == DISCOVERD){
                    central.stopScan()
                    println("Find " + DISCOVERD)
                    delegate?.didUpdateState?("Find " + DISCOVERD)
                    self.peripheral = peripheral;
                    central.connectPeripheral(self.peripheral, options: nil)
                }
            }
        }
        return
    }
    
    
    // MARK:Public Function
    
    func sendOn(){
        println("sendON")
        //	ONデータ
        var rawArray:[UInt8] = [0x01, 0x01]
        let dataOn = NSData(bytes: &rawArray, length: rawArray.count)
        BLEUtilitySwift.writeCharacteristic(peripheral, sUUID: UUID_VSP_SERVICE, cUUID: UUID_TX, data: dataOn)
    }
    func sendOff(){
        println("sendOff")
        // OFFデータ
        var rawArray = [0x01, 0x00]
        let dataOff = NSData(bytes: &rawArray, length: rawArray.count)
        BLEUtilitySwift.writeCharacteristic(peripheral, sUUID: UUID_VSP_SERVICE, cUUID: UUID_TX, data: dataOff)
    }
    
    // MARK:delegate - centralManager
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        println("centralManagerDidUpdateState")
        
        switch (central.state) {
        case .PoweredOff:
            println("CoreBluetooth BLE hardware is powered off")
            delegate?.didUpdateState?("CoreBluetooth BLE hardware is powered off")
            break
        case .PoweredOn:
            println("CoreBluetooth BLE hardware is powered on and ready")
            delegate?.didUpdateState?("CoreBluetooth BLE hardware is powered on and ready")
            self.startScanning()
            break
        case .Resetting:
            println("CoreBluetooth BLE hardware is resetting")
            delegate?.didUpdateState?("CoreBluetooth BLE hardware is resetting")
            break
        case .Unauthorized:
            println("CoreBluetooth BLE state is unauthorized")
            delegate?.didUpdateState?("CoreBluetooth BLE hardware is unauthorized")
            break
        case .Unknown:
            println("CoreBluetooth BLE state is unknown");
            delegate?.didUpdateState?("CoreBluetooth BLE hardware is unknown")
            break
        case .Unsupported:
            println("CoreBluetooth BLE hardware is unsupported on this platform");
            delegate?.didUpdateState?("CoreBluetooth BLE hardware is unsupported on this platform")
            break
        }
    }
    
    func startScanning(){
        println("Start scanning")
        delegate?.didUpdateState?("Start scanning")
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        println("Discovered \(peripheral.name)")
        println("identifier \(peripheral.identifier)")
        println("services \(peripheral.services)")
        println("RSSI \(RSSI)")
        
        delegate?.didUpdateState?("Discovered \(peripheral.name)")
        
        if(peripheral.name != nil && peripheral.name == DISCOVERD){
            central.stopScan()
            println("Find " + DISCOVERD)
            delegate?.didUpdateState?("Find " + DISCOVERD)
            self.peripheral = peripheral;
            central.connectPeripheral(self.peripheral, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        
        self.peripheral.delegate = self;
        let UUID = CBUUID(string: UUID_VSP_SERVICE)
        self.peripheral.discoverServices([UUID])
        println("Connected")
        delegate?.didConnect?()
    }
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("Disconnected")
        
        self.peripheral = nil;
        
        // Validate peripheral information
        if ((peripheral == nil) || (peripheral.name == nil) || (peripheral.name == "")) {
            return
        }
        
        // If not already connected to a peripheral, then connect to this one
        if ((self.peripheral == nil) || (self.peripheral?.state == CBPeripheralState.Disconnected)) {
            // Retain the peripheral before trying to connect
            self.peripheral = peripheral
            
            // Connect to peripheral
            central.connectPeripheral(peripheral, options: nil)
        }
        delegate?.didDisconnect!()
    }
    
    // MARK:delegate - peripheral
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        
        //println("Hello from deligate \(peripheral.name)");
        
        for aService in peripheral.services{
            println("Service UUID: \((aService as! CBService).UUID )")
            //delegate?.didUpdateState?("Service UUID: \((aService as! CBService).UUID )")
            peripheral.discoverCharacteristics(nil, forService: aService as! CBService)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        
        //println("Found Characteristics For Service: \(service.UUID)")
        for aChar in service.characteristics
        {
            //println("Characteristics UUID: \((aChar as CBCharacteristic).UUID)")
            if((aChar as! CBCharacteristic).UUID.isEqual(CBUUID(string: UUID_VSP_SERVICE))){
                
                var random = NSInteger(1)
                var data = NSData(bytes: &random, length: 1)
                //	ONデータ
                var rawArray:[UInt8] = [0x01, 0x01]
                let dataOn = NSData(bytes: &rawArray, length: rawArray.count)
                rawArray = [0x01, 0x00]
                let dataOff = NSData(bytes: &rawArray, length: rawArray.count)
                
                BLEUtilitySwift.writeCharacteristic(self.peripheral, sUUID: UUID_VSP_SERVICE, cUUID: UUID_TX, data: dataOn)
                BLEUtilitySwift.readCharacteristic(self.peripheral, sUUID: UUID_VSP_SERVICE, cUUID: UUID_RX)
                BLEUtilitySwift.setNotificationForCharacteristic(self.peripheral, sUUID: UUID_VSP_SERVICE, cUUID: UUID_RX, enable: true)
                
                println("Done with setting up TX-RX sensor")
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didWriteValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        println("didWriteValueForCharacteristic \(characteristic.UUID) error = \(error)");
    }
    
    var str: String! = "something"
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        if !pauseUpdate.boolValue {
            
            // ReadValue
            var temp = characteristic.value
            println("VAL: \(temp)")
            
            str = " \(temp) "
            
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd H:m:s"
            
            let date = dateFormatter.stringFromDate(NSDate()) as String!
            
            results.append("\(date),")
            results.append("\(str)\n")
            
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        println("didUpdateNotificationStateForCharacteristic \(characteristic.UUID), error = \(error)");
    }
    
    func aarrayToString() -> String {
        var str: String! = ""
        
        for var i = 0; i < results.count; ++i{
            
            str = str + String(results[i])
        }
        return str
    }
    
    
    
    
    
    
    
}