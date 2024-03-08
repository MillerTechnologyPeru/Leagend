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
        
        static var service: BluetoothUUID { .leagendBM2Service }
        
        public let name: BM2.Name
    }
}

public extension BM2.Advertisement {
    
    init?<T: AdvertisementData>(_ advertisement: T) {
        guard let localName = advertisement.localName,
              let name = BM2.Name(rawValue: localName),
              advertisement.serviceUUIDs == [Self.service] else {
            return nil
        }
        self.name = name
    }
}

// MARK: - Battery Characteristic

public extension BM2 {
    
    /// Decrypted battery characteristic
    struct BatteryCharacteristic: Equatable, Hashable, Sendable {
        
        public static var service: BluetoothUUID { .leagendBM2Service }
        
        public static var uuid: BluetoothUUID { .leagendBM2BatteryVoltageCharacteristic }
        
        public let voltage: BatteryVoltage
        
        public let power: UInt8
        
        init?(data: Data) {
            guard data.count >= 8,
                  data.first == 0xf5 else {
                return nil
            }
            
            let voltage = UInt16(bigEndian: UInt16(bytes: (data[1], data[2]))) >> 4
            let power = data[3]
            self.voltage = BM2.BatteryVoltage(rawValue: voltage)
            self.power = power
        }
    }
}

// MARK: - Battery Voltage

public extension BM2 {
    
    struct BatteryVoltage: RawRepresentable, Equatable, Hashable, Codable {
                
        public let rawValue: UInt16
        
        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
    }
}

public extension BM2.BatteryVoltage {
    
    var voltage: Double {
        Double(rawValue) / 100
    }
}

extension BM2.BatteryVoltage: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt16) {
        self.init(rawValue: value)
    }
}

extension BM2.BatteryVoltage: CustomStringConvertible {
    
    public var description: String {
        return "\(voltage)V"
    }
}

// MARK: - Battery Percentage

public extension BM2 {
    
    struct BatteryPercentage: RawRepresentable, Equatable, Hashable, Codable {
                
        public let rawValue: UInt8
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }
}

extension BM2.BatteryPercentage: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt8) {
        self.init(rawValue: value)
    }
}

extension BM2.BatteryPercentage: CustomStringConvertible {
    
    public var description: String {
        return "\(rawValue)%"
    }
}
