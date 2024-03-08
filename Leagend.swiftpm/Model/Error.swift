//
//  Error.swift
//
//
//  Created by Alsey Coleman Miller on 4/12/23.
//

import Foundation
import Bluetooth
import Leagend

/// Leagend app errors.
public enum LeagendAppError: Error {
    
    /// Bluetooth is not available on this device.
    case bluetoothUnavailable
    
    /// No service with UUID found.
    case serviceNotFound(BluetoothUUID)
    
    /// No characteristic with UUID found.
    case characteristicNotFound(BluetoothUUID)
    
    /// The characteristic's value could not be parsed. Invalid data.
    case invalidCharacteristicValue(BluetoothUUID)
    
    /// Not a compatible peripheral
    case incompatiblePeripheral
}
