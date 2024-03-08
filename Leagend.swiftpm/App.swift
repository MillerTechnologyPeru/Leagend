import Foundation
import SwiftUI
import CoreBluetooth
import Bluetooth
import GATT
import Leagend

@main
struct LeagendApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AccessoryManager.shared)
        }
    }
}
