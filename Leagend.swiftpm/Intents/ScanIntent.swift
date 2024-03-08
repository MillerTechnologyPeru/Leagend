//
//  ScanIntent.swift
//  LeagendApp
//
//  Created by Alsey Coleman Miller on 4/12/23.
//

import Foundation
import AppIntents
import SwiftUI
import Bluetooth
import GATT
import DarwinGATT
import Leagend

@available(iOS 16, *)
struct ScanIntent: AppIntent {
        
    static var title: LocalizedStringResource { "Scan for Leagend Bluetooth devices" }
    
    static var description: IntentDescription {
        IntentDescription(
            "Scan for nearby devices",
            categoryName: "Utility",
            searchKeywords: ["scan", "bluetooth", "Leagend", "battery", "BM2"]
        )
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("Scan nearby devices for \(\.$duration) seconds")
    }
    
    @Parameter(
        title: "Duration",
        description: "Duration in seconds for scanning.",
        default: 1.5
    )
    var duration: TimeInterval
    
    @MainActor
    func perform() async throws -> some IntentResult {
        let store = AccessoryManager.shared
        try await store.central.wait(for: .poweredOn, warning: 2, timeout: 5)
        try await store.scan(duration: duration)
        let advertisements = store.peripherals.map { ($0, $1) }
        return .result(
            value: advertisements.map { $0.0.description },
            view: view(for: advertisements)
        )
    }
}

@available(iOS 16, *)
@MainActor
private extension ScanIntent {
    
    func view(for results: [(peripheral: NativePeripheral, advertisement: LeagendAccessory.Advertisement)]) -> some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                if results.isEmpty {
                    Text("No devices found.")
                        .padding(20)
                } else {
                    if results.count > 3 {
                        Text("Found \(results.count) devices.")
                            .padding(20)
                    } else {
                        ForEach(results, id: \.peripheral.id) {
                            view(for: $0.advertisement)
                                .padding(8)
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
    }
    
    func view(for advertisement: LeagendAccessory.Advertisement) -> some View {
        LeagendAdvertisementRow(
            advertisement: advertisement
        )
    }
}
