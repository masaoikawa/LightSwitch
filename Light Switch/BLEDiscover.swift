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

private let DISCOVERD:String        =       "nRF5x"
private let DISCOVERD_F:String      =       "Biscuit"
private let UUID_DISCOVERD:String   =       "844BC615-70B2-D539-5C27-5E940A674FA1"
private let UUID_VSP_SERVICE:String =       "713D0000-503E-4C75-BA94-3148F18D941E" //VSP
private let UUID_RX:String          =       "713D0002-503E-4C75-BA94-3148F18D941E" //RX
private let UUID_TX:String          =		"713D0003-503E-4C75-BA94-3148F18D941E" //TX
private let UUID_nRF5x:String		=		"966C13EE-F4D0-0062-3FCA-E5DAE8FAC178"

private let UUID_Biscuit            =       "F39462F0-22AC-E387-EBE0-EC6870A32892"

// MARK:protcol DiscoveryDelegate
@objc protocol DiscoveryDelegate{
    @objc optional func didConnect()
    @objc optional func didDisconnect()
    @objc optional func didUpdateState(_ message : String)
}


// MARK:class BLEDiscovery
class BLEDiscovery: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate{
    
    
    // MARK:property
    var delegate: DiscoveryDelegate?
    var _centralManager:CBCentralManager!
    var _peripheral:CBPeripheral!
    
    var results: [String]! = []
    var pauseUpdate: Bool! = false
    var switchState: Bool! = true
    
    // MARK:init
    override init(){
        super.init()
        
        self.setupCentralManager()
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
        self._peripheral = dict[CBCentralManagerRestoredStatePeripheralsKey] as? CBPeripheral
        
        return
    }
    
    
    // MARK:Public Function
    
    func setupCentralManager() {
		print("setupCentralManager:")
        //let centralQueue = dispatch_queue_create("nu.whiletrue", DISPATCH_QUEUE_SERIAL)
        let centralQueue = DispatchQueue.global(qos: .default)
        let options: Dictionary = [
            CBCentralManagerOptionRestoreIdentifierKey: "myKey"
        ]
        print("Initializing central manager:")
        _centralManager = CBCentralManager(delegate: self, queue: centralQueue, options: options)
    }
    
    func sendOn(){
        print("sendON:")
        if(_centralManager == nil){
            for _ in 0 ..< 1000 {
                delegate?.didUpdateState?("wait centralManager setup")
                sleep(1)
            }
        }
        if(_peripheral == nil){
            self.startScanning()
            for _ in 0 ..< 1000 {
                delegate?.didUpdateState?("wait peripheral setup")
                sleep(1)
				if (_peripheral.services == nil) {
					sleep(1)
				}else{
					break
				}
            }
        }
		if(_peripheral.services == nil){
			print("wait peripheral services setup")
			for _ in 0 ..< 1000 {
				delegate?.didUpdateState?("wait peripheral services setup")
				if (_peripheral.services == nil) {
					sleep(1)
				}else{
					break
				}
			}
		}
		if(_peripheral.services![0].characteristics == nil){
			print("wait peripheral characteristics setup")
			for _ in 0 ..< 1000 {
				delegate?.didUpdateState?("wait peripheral characteristics setup")
				if (_peripheral.services![0].characteristics == nil) {
					sleep(1)
				}else{
					break
				}
			}
		}
        print("state:\(_peripheral.state.rawValue)")
        if(_peripheral.state != CBPeripheralState.connected){
            //centralManager.connectPeripheral(self.peripheral!, options: nil)
			
			delegate?.didUpdateState?("wait peripheral connected")
			sleep(1)
		}
        //	ONデータ
		delegate?.didUpdateState?("connected peripheral.")
        let rawArray:[UInt8] = [0x01, 0x01]
        let dataOn = Data(bytes: rawArray, count: rawArray.count)
        if(_peripheral.state == CBPeripheralState.connected) {
			if (_peripheral.services != nil) {
				BLEUtilitySwift.writeCharacteristic(_peripheral, sUUID: UUID_VSP_SERVICE, cUUID: UUID_TX, data: dataOn)
			}else{
				print("error (_peripheral.services nil.")
			}
        }else{
            delegate?.didUpdateState?("error connected")
            sleep(1)
        }
    }
    
    func sendOff(){
        print("sendOff:")
        //for(var i=0; self.centralManager == nil && i<1000;i += 1){
        if (_centralManager == nil) {
			for _ in 0 ..< 1000 {
				delegate?.didUpdateState?("wait centralManager serup")
				sleep(1)
			}
		}
		if (_peripheral == nil) {
			self.startScanning()
			//for(var i=0; self.peripheral == nil && i<1000; i += 1){
			for _ in 0 ..< 1000 {
				delegate?.didUpdateState?("wait peripheral serup")
				sleep(1)
				if (_peripheral.services == nil) {
					sleep(1)
				}else{
					break
				}
			}
		}
		if(_peripheral.services == nil){
			print("wait peripheral services setup")
			for _ in 0 ..< 1000 {
				delegate?.didUpdateState?("wait peripheral services setup")
				if (_peripheral.services == nil) {
					sleep(1)
				}else{
					break
				}
			}
		}
		if(_peripheral.services![0].characteristics == nil){
			print("wait peripheral characteristics setup")
			for _ in 0 ..< 1000 {
				delegate?.didUpdateState?("wait peripheral characteristics setup")
				if (_peripheral.services![0].characteristics == nil) {
					sleep(1)
				}else{
					break
				}
			}
		}
		print("state:\(_peripheral.state.rawValue)")
		if(_peripheral.state != CBPeripheralState.connected){
			//self.centralManager.connectPeripheral(self.peripheral!, options: nil)
			//for(var i=0; self.peripheral.state != CBPeripheralState.Connected && i<1000; i += 1){
			delegate?.didUpdateState?("wait peripheral connected")
			sleep(1)
		}
		// OFFデータ
		delegate?.didUpdateState?("connected perileral.")
		let rawArray = [0x01, 0x00]
		let dataOff = Data(bytes: rawArray, count: rawArray.count)
		if(_peripheral.state == CBPeripheralState.connected) {
			BLEUtilitySwift.writeCharacteristic(_peripheral!, sUUID: UUID_VSP_SERVICE, cUUID: UUID_TX, data: dataOff)
		}else{
			delegate?.didUpdateState?("error connected")
			sleep(1)
		}
	}
	
	
    func readState() {
        print("readStat:")
        
        BLEUtilitySwift.readCharacteristic(_peripheral!, sUUID: UUID_VSP_SERVICE, cUUID: UUID_RX)
    }
    
    func startScanning() {
        print("Start scanning:")
        delegate?.didUpdateState?("Start scanning")
        //_centralManager.scanForPeripherals(withServices: nil, options:nil)
		_centralManager.scanForPeripherals(withServices: [CBUUID(string: UUID_VSP_SERVICE),CBUUID(string: UUID_DISCOVERD),CBUUID(string: UUID_nRF5x),CBUUID(string: UUID_Biscuit)], options: [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: true as Bool)])
    }
	
	func disConnect() {
		print("End Connection:")
		_centralManager.cancelPeripheralConnection(_peripheral)
	}
    
    // MARK:delegate - centralManager
		
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("centralManagerDidUpdateState:")
        
        switch (central.state) {
        case .poweredOff:
            print("CoreBluetooth BLE hardware is powered off")
            delegate?.didUpdateState?("CoreBluetooth BLE hardware is powered off")
            break
        case .poweredOn:
            print("CoreBluetooth BLE hardware is powered on and ready")
            delegate?.didUpdateState?("CoreBluetooth BLE hardware is powered on and ready")
            self.startScanning()
            break
        case .resetting:
            print("CoreBluetooth BLE hardware is resetting")
            delegate?.didUpdateState?("CoreBluetooth BLE hardware is resetting")
            break
        case .unauthorized:
            print("CoreBluetooth BLE state is unauthorized")
            delegate?.didUpdateState?("CoreBluetooth BLE hardware is unauthorized")
            break
        case .unknown:
            print("CoreBluetooth BLE state is unknown");
            delegate?.didUpdateState?("CoreBluetooth BLE hardware is unknown")
            break
        case .unsupported:
            print("CoreBluetooth BLE hardware is unsupported on this platform");
            delegate?.didUpdateState?("CoreBluetooth BLE hardware is unsupported on this platform")
            break
        }
    }
		
    
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		print("Discovered \(peripheral.name)")
		print("identifier \(peripheral.identifier)")
		print("services \(peripheral.services)")
		print("RSSI \(RSSI)")
        
		delegate?.didUpdateState?("Discovered \(peripheral.name)")
	
		if(peripheral.name != nil && (peripheral.name == DISCOVERD || peripheral.name == DISCOVERD_F)){
			central.stopScan()
			print("Find " + peripheral.name!)
			delegate?.didUpdateState?("Find " + peripheral.name!)
			_peripheral = peripheral;
			central.connect(_peripheral!, options: nil)
		}
	}

    func centralManager(_: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        
		print("didConnectedPeripheral:")
        _peripheral!.delegate = self;
        let UUID = CBUUID(string: UUID_VSP_SERVICE)
        _peripheral!.discoverServices([UUID])
        delegate?.didConnect?()
    }
    
        
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        print("didDisconnectPeripheral:")
		
		central.stopScan()
		
        _peripheral = nil;
        
        // Validate peripheral information
        if ((peripheral.name == nil) || (peripheral.name == "")) {
            return
        }
        
        // If not already connected to a peripheral, then connect to this one
        if ((_peripheral == nil) || (_peripheral?.state == CBPeripheralState.disconnected)) {
            // Retain the peripheral before trying to connect
            _peripheral = peripheral
            
            // Connect to peripheral 再接続
            //central.connectPeripheral(peripheral, options: nil)
        }
        delegate?.didDisconnect!()
    }
//

    
    // MARK:delegate - peripheral
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: Error?) {
        
        //println("Hello from deligate \(peripheral.name)");
        
        for aService in peripheral.services!{
            print("didDiscoverService UUID: \((aService ).uuid )")
            //delegate?.didUpdateState?("Service UUID: \((aService as! CBService).UUID )")
            peripheral.discoverCharacteristics(nil, for: aService )
        }
    }
		
	
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("Found Characteristics For Service: \(service.uuid)")
        for aChar in service.characteristics!
        {
            //println("Characteristics UUID: \((aChar as CBCharacteristic).UUID)")
            if((aChar ).uuid.isEqual(CBUUID(string: UUID_TX))){
                
                let random:[UInt8] = [0x01]
                _ = Data(bytes: random, count: 1)
                //	ONデータ
                var rawArray:[UInt8] = [0x01, 0x01]
                _ = Data(bytes: rawArray, count: rawArray.count)
                rawArray = [0x01, 0x00]
                _ = Data(bytes: rawArray, count: rawArray.count)
                
                print("Done with setting up TX")
                //BLEUtilitySwift.writeCharacteristic(self.peripheral, sUUID: UUID_VSP_SERVICE, cUUID: UUID_TX, data: dataOn)
            }else if( (aChar ).uuid.isEqual((CBUUID(string: UUID_RX)))) {
                BLEUtilitySwift.readCharacteristic(_peripheral!, sUUID: UUID_VSP_SERVICE, cUUID: UUID_RX)
                BLEUtilitySwift.setNotificationForCharacteristic(_peripheral!, sUUID: UUID_VSP_SERVICE, cUUID: UUID_RX, enable: true)
                
                print("Done with setting up RX sensor")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        print("didWriteValueForCharacteristic \(characteristic.uuid) error = \(error)");
        
    }
    
    var str: String! = "something"
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if !pauseUpdate {
            
            // ReadValue
            let temp = characteristic.value
            print("Update VAL: \(temp)")
            
            str = " \(temp) "
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd H:m:s"
            
            let date = dateFormatter.string(from: Date()) as String!
            
            results.append("\(date),")
            results.append("\(str)\n")
            
        }
        //delegate?.didUpdateState!("updateStat")
        
    }


    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        print("didUpdateNotificationStateForCharacteristic \(characteristic.uuid), error = \(error)");
        
        // ReadValue
        let temp = characteristic.value
        print("Notification VAL: \(temp)")
        
        str = " \(temp) "
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd H:m:s"
        
        let date = dateFormatter.string(from: Date()) as String!
        
        results.append("\(date),")
        results.append("\(str)\n")
        
        //delegate?.didUpdateState!("updateNotification")
        
    }


    
    func aarrayToString() -> String {
        var str: String! = ""
        
 //     for (var i=0; i < results.count; i += 1) {
        for i in 0 ..< results.count {
            str = str + String(results[i])
        }
        return str
    }
    
}



