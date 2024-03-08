//
//  VoltageView.swift
//
//
//  Created by Alsey Coleman Miller on 3/7/24.
//

import Foundation
import SwiftUI
import Bluetooth
import GATT
import Leagend

struct VoltageView: View {
    
    let peripheral: NativePeripheral
    
    @EnvironmentObject
    private var store: AccessoryManager
    
    @State
    var readings = [Reading]()
    
    @State
    var onDisappear: () -> () = { }
    
    init(peripheral: NativePeripheral) {
        self.peripheral = peripheral
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(readings.reversed()) { reading in
                    HStack {
                        Text(verbatim: reading.date.formatted(date: .abbreviated, time: .complete))
                        Text("\(reading.voltage)v")
                        Text("\(reading.percentage)%")
                    }
                }
            }
        }
        .navigationTitle("Voltage")
        .task {
            await start()
        }
        .onDisappear {
            onDisappear()
        }
    }
}

private extension VoltageView {
    
    func start() async {
        do {
            let stream = try await store.readBM2Voltage(for: peripheral)
            self.onDisappear = {
                stream.stop()
            }
            Task {
                do {
                    for try await notification in stream {
                        guard let characteristic = try? BM2.BatteryCharacteristic.decrypt(notification) else {
                            continue
                        }
                        let reading = Reading(
                            date: Date(),
                            voltage: characteristic.voltage.voltage,
                            percentage: UInt(characteristic.power.rawValue)
                        )
                        self.readings.append(reading)
                    }
                }
                catch {
                    store.log("Unable to read voltage. \(error)")
                }
            }
        }
        catch {
            store.log("Unable to read voltage. \(error)")
        }
        
    }
}

extension VoltageView {
    
    struct Reading: Equatable, Hashable, Identifiable, Codable {
        
        var id: Date {
            date
        }
        
        let date: Date
        
        let voltage: Float
        
        let percentage: UInt
    }
}
