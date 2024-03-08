//
//  BluetoothUUID.swift
//
//
//  Created by Alsey Coleman Miller on 3/6/24.
//

import Foundation
import Bluetooth

public extension BluetoothUUID {
    
    static var leagendBM2Service: BluetoothUUID {
        .bit16(0xFFF0)
    }
    
    static var leagendBM2Characteristic1: BluetoothUUID {
        .bit16(0xFFF1)
    }
    
    static var leagendBM2Characteristic2: BluetoothUUID {
        .bit16(0xFFF2)
    }
    
    static var leagendBM2Characteristic3: BluetoothUUID {
        .bit16(0xFFF3)
    }
    
    static var leagendBM2BatteryVoltageCharacteristic: BluetoothUUID {
        .bit16(0xFFF4) // "0000fff4-0000-1000-8000-00805f9b34fb"
    }
    
    static var leagendBM2Characteristic5: BluetoothUUID {
        .bit16(0xFFF5)
    }
    
    static var leagendBM2OTAService: BluetoothUUID {
        .bit16(0xFEE0)
    }
    
    static var leagendBM2OTACharacteristic: BluetoothUUID {
        .bit16(0xFEE1)
    }
}
