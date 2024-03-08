//
//  AccessoryManagerBluetooth.swift
//  
//
//  Created by Alsey Coleman Miller  on 3/6/24.
//

import Foundation
import Bluetooth
import GATT
import DarwinGATT
import Leagend

public extension AccessoryManager {
    
    func scan(duration: TimeInterval? = nil, filterServices: Bool = false) async throws {
        let bluetoothState = await central.state
        guard bluetoothState == .poweredOn else {
            throw LeagendAppError.bluetoothUnavailable
        }
        let filterDuplicates = true //preferences.filterDuplicates
        self.peripherals.removeAll(keepingCapacity: true)
        stopScanning()
        let services = filterServices ? Set([Leagend.BM2.Advertisement.service]) : []
        let scanStream = central.scan(
            with: services,
            filterDuplicates: filterDuplicates
        )
        self.scanStream = scanStream
        let task = Task { [unowned self] in
            for try await scanData in scanStream {
                guard found(scanData) else { continue }
            }
        }
        if let duration = duration {
            precondition(duration > 0.001)
            try await Task.sleep(timeInterval: duration)
            scanStream.stop()
            try await task.value // throw errors
        } else {
            // error not thrown
            Task { [unowned self] in
                do { try await task.value }
                catch is CancellationError { }
                catch {
                    self.log("Error scanning: \(error)")
                }
            }
        }
    }
    
    func stopScanning() {
        scanStream?.stop()
        scanStream = nil
    }
    
    @discardableResult
    func connect(to peripheral: NativePeripheral) async throws -> GATTConnection<NativeCentral> {
        let central = self.central
        if let connection = self.connectionsByPeripherals[peripheral] {
            return connection
        }
        // connect
        if await loadConnections.contains(peripheral) == false {
            // initiate connection
            try await central.connect(to: peripheral)
        }
        // cache MTU
        let maximumTransmissionUnit = try await central.maximumTransmissionUnit(for: peripheral)
        // get characteristics by UUID
        let servicesCache = try await central.cacheServices(for: peripheral)
        let connectionCache = GATTConnection(
            central: central,
            peripheral: peripheral,
            maximumTransmissionUnit: maximumTransmissionUnit,
            cache: servicesCache
        )
        // store connection cache
        self.connectionsByPeripherals[peripheral] = connectionCache
        return connectionCache
    }
    
    func disconnect(_ peripheral: NativePeripheral) async {
        await central.disconnect(peripheral)
    }
    
    /// Read Voltage
    func readBM2Voltage(
        for peripheral: NativePeripheral
    ) async throws -> AsyncCentralNotifications<NativeCentral> {
        let connection = try await connect(to: peripheral)
        return try await connection.leagendBM2VoltageNotifications()
    }
}

internal extension GATTConnection {
    
    func leagendBM2VoltageNotifications() async throws -> AsyncCentralNotifications<Central> {
        guard let characteristic = cache.characteristic(.leagendBM2BatteryVoltageCharacteristic, service: .leagendBM2Service) else {
            throw LeagendAppError.characteristicNotFound(.leagendBM2BatteryVoltageCharacteristic)
        }
        let notifications = try await central.notify(for: characteristic)
        return notifications//.compactMap { BM2.BatteryCharacteristic(data: $0) }
    }
}

internal extension AccessoryManager {
    
    func observeBluetoothState() {
        // observe state
        Task { [weak self] in
            while let self = self {
                let newState = await self.central.state
                let oldValue = self.state
                if newState != oldValue {
                    self.state = newState
                }
                try await Task.sleep(timeInterval: 0.5)
            }
        }
        // observe connections
        Task { [weak self] in
            while let self = self {
                let newState = await self.loadConnections
                let oldValue = self.connections
                let disconnected = self.connectionsByPeripherals
                    .filter { newState.contains($0.value.peripheral) }
                    .keys
                if newState != oldValue, disconnected.isEmpty == false {
                    for peripheral in disconnected {
                        self.connectionsByPeripherals[peripheral] = nil
                    }
                }
                try await Task.sleep(timeInterval: 0.2)
            }
        }
    }
    
    var loadConnections: Set<NativePeripheral> {
        get async {
            let peripherals = await self.central
                .peripherals
                .filter { $0.value }
                .map { $0.key }
            return Set(peripherals)
        }
    }
    
    func found(_ scanData: ScanData<NativeCentral.Peripheral, NativeCentral.Advertisement>) -> Bool {
        guard let advertisement = LeagendAccessory.Advertisement(scanData.advertisementData) else {
            return false
        }
        self.peripherals[scanData.peripheral] = advertisement
        return true
    }
}
