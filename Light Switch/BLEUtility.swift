//
//  BLEUtility.swift
//  Light Switch
//
//  Created by 井川 雅央 on 2015/09/24.
//  Copyright © 2015年 井川 雅央. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEUtilitySwift: NSObject {
    
    class func writeCharacteristic(_ peripheral:CBPeripheral, sUUID: String, cUUID: String, data: Data){
        for service in (peripheral.services )! {
            if(service.uuid == CBUUID(string: sUUID)){
                print("service.characteristics:\(service.characteristics)")
                if (service.characteristics != nil) {
                    for characteristic in (service.characteristics )! {
                        if(characteristic.uuid == CBUUID(string: cUUID)){
                            /* Everything is found, WRITE characteristic ! */
                            peripheral.writeValue(data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                        }
                    }                    
                }else{
                    print("error service.characteristics nil.")
                }
            }
        }
    }
    
    class func readCharacteristic(_ peripheral:CBPeripheral, sUUID: String, cUUID: String){
        for service in (peripheral.services )! {
            if(service.uuid == CBUUID(string: sUUID)){
                for characteristic in (service.characteristics )!{
                    if(characteristic.uuid == CBUUID(string: cUUID)){
                        /* Everything is found, READ characteristic ! */
                        peripheral.readValue(for: characteristic)
                    }
                }
            }
        }
    }
    
    class func setNotificationForCharacteristic(_ peripheral:CBPeripheral, sUUID: String, cUUID: String, enable: Bool){
        for service in (peripheral.services )! {
            if(service.uuid == CBUUID(string: sUUID)){
                for characteristic in (service.characteristics )! {
                    if(characteristic.uuid == CBUUID(string: cUUID)){
                        /* Everything is found, SET notification ! */
                        peripheral.setNotifyValue(enable, for: characteristic)
                    }
                }
            }
        }
    }
    
    class func isCharacteristicNotifiable(_ peripheral:CBPeripheral, sUUID: CBUUID, cUUID: CBUUID) -> Bool{
        for service in (peripheral.services)!{
            if(service.uuid == sUUID){
                for characteristic in (service.characteristics)! {
                    if(characteristic.uuid == cUUID){
                        if(characteristic.properties == CBCharacteristicProperties.notify){
                            return true
                        }else{
                            return false
                        }
                    }
                }
            }
        }
        return false;
    }
}
