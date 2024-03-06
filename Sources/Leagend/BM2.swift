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
