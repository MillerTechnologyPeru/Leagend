//
//  BM2.swift
//
//
//  Created by Alsey Coleman Miller on 3/6/24.
//

import Foundation
import Bluetooth
import GATT

public struct BM2 {
    
    public enum Name: String, Codable, Sendable, CaseIterable {
        
        case batteryMonitor = "Battery Monitor"
        case liBatteryMonitor = "Li Battery Monitor"
        case zx1689 = "ZX-1689"
    }
    
    public struct Advertisement: Equatable, Hashable, Sendable {
        
        public let name: BM2.Name
    }
}

extension BM2.Advertisement {
    
    init?<T: AdvertisementData>(_ advertisement: T) {
        guard let localName = advertisement.localName,
              let name = BM2.Name(rawValue: localName) else {
            return nil
        }
        self.name = name
    }
}

public extension BM2 {
    
    /// Decrypted battery characteristic
    struct BatteryCharacteristic: Equatable, Hashable, Sendable {
        
        public static var uuid: BluetoothUUID { .leagendBatteryVoltageCharacteristic }
        
        public let voltage: UInt16
        
        public let power: UInt8
        
        init?(data: Data) {
            guard data.count >= 8,
                  data.first == 0xf5 else {
                return nil
            }
            
            let voltage = UInt16(bigEndian: UInt16(bytes: (data[1], data[2]))) >> 4
            let power = data[3]
            self.voltage = voltage
            self.power = power
        }
    }
}
