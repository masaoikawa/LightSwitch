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
    
    class func writeCharacteristic(peripheral:CBPeripheral, sUUID: String, cUUID: String, data: NSData){
        for service in (peripheral.services )! {
            if(service.UUID == CBUUID(string: sUUID)){
                for characteristic in (service.characteristics )! {
                    if(characteristic.UUID == CBUUID(string: cUUID)){
                        /* Everything is found, WRITE characteristic ! */
                        peripheral.writeValue(data, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithResponse)
                    }
                }
            }
        }
    }
    
    class func readCharacteristic(peripheral:CBPeripheral, sUUID: String, cUUID: String){
        for service in (peripheral.services )! {
            if(service.UUID == CBUUID(string: sUUID)){
                for characteristic in (service.characteristics )!{
                    if(characteristic.UUID == CBUUID(string: cUUID)){
                        /* Everything is found, READ characteristic ! */
                        peripheral.readValueForCharacteristic(characteristic)
                    }
                }
            }
        }
    }
    
    class func setNotificationForCharacteristic(peripheral:CBPeripheral, sUUID: String, cUUID: String, enable: Bool){
        for service in (peripheral.services )! {
            if(service.UUID == CBUUID(string: sUUID)){
                for characteristic in (service.characteristics )! {
                    if(characteristic.UUID == CBUUID(string: cUUID)){
                        /* Everything is found, SET notification ! */
                        peripheral.setNotifyValue(enable, forCharacteristic: characteristic)
                    }
                }
            }
        }
    }
    
    class func isCharacteristicNotifiable(peripheral:CBPeripheral, sUUID: CBUUID, cUUID: CBUUID) -> Bool{
        for service in (peripheral.services)!{
            if(service.UUID == sUUID){
                for characteristic in (service.characteristics)! {
                    if(characteristic.UUID == cUUID){
                        if(characteristic.properties == CBCharacteristicProperties.Notify){
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