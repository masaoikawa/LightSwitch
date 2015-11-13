//
//  Discover.swift
//  Light Switch
//
//  Created by 井川 雅央 on 2015/09/24.
//  Copyright © 2015年 井川 雅央. All rights reserved.
//

import Foundation
import CoreBluetooth

let BLEDiscoverySharedInstance = BLEDiscovery()

private let DISCOVERD:String        =       "nRF5x" //"Biscuit" //
private let DISCOVERD_F:String      =       "Biscuit" //"nRF5x" //
private let UUID_DISCOVERD:String   =       "844BC615-70B2-D539-5C27-5E940A674FA1"
private let UUID_VSP_SERVICE:String =       "713D0000-503E-4C75-BA94-3148F18D941E" //VSP
private let UUID_RX:String          =       "713D0002-503E-4C75-BA94-3148F18D941E" //RX
private let UUID_TX:String          =		"713D0003-503E-4C75-BA94-3148F18D941E" //TX

private let UUID_Biscuit            =       "F39462F0-22AC-E387-EBE0-EC6870A32892"

// MARK:protcol DiscoveryDelegate
@objc protocol DiscoveryDelegate{
    optional func didConnect()
    optional func didDisconnect()
    optional func didUpdateState(message : String)
}

// MARK:class BLEDiscovery
class BLEDiscovery: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    // MARK:property
    var delegate: DiscoveryDelegate?
    var centralManager:CBCentralManager!
    var peripheral:CBPeripheral!
    
    var results: [String]! = []
    var pauseUpdate: Bool! = false
    var switchState: Bool! = true
    
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
        print("Initializing central manager", terminator: "")
        centralManager = CBCentralManager(delegate: self, queue: centralQueue, options: options)
    }
    
    func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
        
        self.peripheral = dict[CBCentralManagerRestoredStatePeripheralsKey] as? CBPeripheral
        
        return
    }
    
    
    // MARK:Public Function
    
    func sendOn(){
        print("sendON", terminator: "")
        //	ONデータ
        var rawArray:[UInt8] = [0x01, 0x01]
        let dataOn = NSData(bytes: &rawArray, length: rawArray.count)
        BLEUtilitySwift.writeCharacteristic(peripheral!, sUUID: UUID_VSP_SERVICE, cUUID: UUID_TX, data: dataOn)
    }
    
    func sendOff(){
        print("sendOff", terminator: "")
        // OFFデータ
        var rawArray = [0x01, 0x00]
        let dataOff = NSData(bytes: &rawArray, length: rawArray.count)
        BLEUtilitySwift.writeCharacteristic(peripheral!, sUUID: UUID_VSP_SERVICE, cUUID: UUID_TX, data: dataOff)
    }
    
    func readState(){
        print("readStat", terminator: "")
        
        BLEUtilitySwift.readCharacteristic(peripheral!, sUUID: UUID_VSP_SERVICE, cUUID: UUID_RX)
    }
    
    // MARK:delegate - centralManager
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        print("centralManagerDidUpdateState", terminator: "")
        
        switch (central.state) {
        case .PoweredOff:
            print("CoreBluetooth BLE hardware is powered off", terminator: "")
            delegate?.didUpdateState?("CoreBluetooth BLE hardware is powered off")
            break
        case .PoweredOn:
            print("CoreBluetooth BLE hardware is powered on and ready", terminator: "")
            delegate?.didUpdateState?("CoreBluetooth BLE hardware is powered on and ready")
            self.startScanning()
            break
        case .Resetting:
            print("CoreBluetooth BLE hardware is resetting", terminator: "")
            delegate?.didUpdateState?("CoreBluetooth BLE hardware is resetting")
            break
        case .Unauthorized:
            print("CoreBluetooth BLE state is unauthorized", terminator: "")
            delegate?.didUpdateState?("CoreBluetooth BLE hardware is unauthorized")
            break
        case .Unknown:
            print("CoreBluetooth BLE state is unknown", terminator: "");
            delegate?.didUpdateState?("CoreBluetooth BLE hardware is unknown")
            break
        case .Unsupported:
            print("CoreBluetooth BLE hardware is unsupported on this platform", terminator: "");
            delegate?.didUpdateState?("CoreBluetooth BLE hardware is unsupported on this platform")
            break
        }
    }
    
    func startScanning(){
        print("Start scanning", terminator: "")
        delegate?.didUpdateState?("Start scanning")
        //centralManager.scanForPeripheralsWithServices(nil, options:nil)
        centralManager.scanForPeripheralsWithServices([CBUUID(string: UUID_VSP_SERVICE),CBUUID(string: UUID_DISCOVERD)], options: [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(bool: true)])
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("Discovered \(peripheral.name)", terminator: "")
        print("identifier \(peripheral.identifier)", terminator: "")
        print("services \(peripheral.services)", terminator: "")
        print("RSSI \(RSSI)", terminator: "")
        
        delegate?.didUpdateState?("Discovered \(peripheral.name)")
        
        if(peripheral.name != nil && (peripheral.name == DISCOVERD || peripheral.name == DISCOVERD_F)){
            central.stopScan()
            print("Find " + peripheral.name!, terminator: "")
            delegate?.didUpdateState?("Find " + peripheral.name!)
            self.peripheral = peripheral;
            central.connectPeripheral(self.peripheral!, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        self.peripheral!.delegate = self;
        let UUID = CBUUID(string: UUID_VSP_SERVICE)
        self.peripheral!.discoverServices([UUID])
        print("Connected", terminator: "")
        delegate?.didConnect?()
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Disconnected", terminator: "")
        
        self.peripheral = nil;
        
        // Validate peripheral information
        if ((peripheral.name == nil) || (peripheral.name == "")) {
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
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        //println("Hello from deligate \(peripheral.name)");
        
        for aService in peripheral.services!{
            print("Service UUID: \((aService ).UUID )", terminator: "")
            //delegate?.didUpdateState?("Service UUID: \((aService as! CBService).UUID )")
            peripheral.discoverCharacteristics(nil, forService: aService )
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        //println("Found Characteristics For Service: \(service.UUID)")
        for aChar in service.characteristics!
        {
            //println("Characteristics UUID: \((aChar as CBCharacteristic).UUID)")
            if((aChar ).UUID.isEqual(CBUUID(string: UUID_TX))){
                
                var random = NSInteger(1)
                _ = NSData(bytes: &random, length: 1)
                //	ONデータ
                var rawArray:[UInt8] = [0x01, 0x01]
                _ = NSData(bytes: &rawArray, length: rawArray.count)
                rawArray = [0x01, 0x00]
                _ = NSData(bytes: &rawArray, length: rawArray.count)
                
                print("Done with setting up TX")
                //BLEUtilitySwift.writeCharacteristic(self.peripheral, sUUID: UUID_VSP_SERVICE, cUUID: UUID_TX, data: dataOn)
            }else if( (aChar ).UUID.isEqual((CBUUID(string: UUID_RX)))) {
                BLEUtilitySwift.readCharacteristic(self.peripheral!, sUUID: UUID_VSP_SERVICE, cUUID: UUID_RX)
                BLEUtilitySwift.setNotificationForCharacteristic(self.peripheral!, sUUID: UUID_VSP_SERVICE, cUUID: UUID_RX, enable: true)
                
                print("Done with setting up RX sensor")
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("didWriteValueForCharacteristic \(characteristic.UUID) error = \(error)", terminator: "");
    }
    
    var str: String! = "something"
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if !pauseUpdate.boolValue {
            
            // ReadValue
            let temp = characteristic.value
            print("VAL: \(temp)", terminator: "")
            
            str = " \(temp) "
            
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd H:m:s"
            
            let date = dateFormatter.stringFromDate(NSDate()) as String!
            
            results.append("\(date),")
            results.append("\(str)\n")
            
        }
        //delegate?.didUpdateState!("updateStat")
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("didUpdateNotificationStateForCharacteristic \(characteristic.UUID), error = \(error)", terminator: "");
        
        // ReadValue
        let temp = characteristic.value
        print("VAL: \(temp)", terminator: "")
        
        str = " \(temp) "
        
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd H:m:s"
        
        let date = dateFormatter.stringFromDate(NSDate()) as String!
        
        results.append("\(date),")
        results.append("\(str)\n")
        
        //delegate?.didUpdateState!("updateNotification")
        
    }
    
    func aarrayToString() -> String {
        var str: String! = ""
        
        for var i = 0; i < results.count; ++i{
            
            str = str + String(results[i])
        }
        return str
    }
    
}


