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
        
        public let voltage: UInt32
        
        public let power: UInt16
        
        init?(data: Data) {
            guard data.count <= 16,
                  data.first == 0xf5 else {
                return nil
            }
            let voltage = UInt32(bigEndian: UInt32(bytes: (data[2], data[3], data[4], data[5])))
            let power = UInt16(bigEndian: UInt16(bytes: (data[6], data[7])))
            self.voltage = voltage
            self.power = power
        }
    }
}
