import Foundation
import Bluetooth
import GATT

/// Leagend Bluetooth Accessory
public enum LeagendAccessory: String, Equatable, Hashable, Sendable, Codable {
    
    case bm2 = "BM2"
}

public extension LeagendAccessory {
    
    enum Advertisement: Equatable, Hashable, Sendable {
        
        case bm2(BM2.Advertisement)
    }
}

public extension LeagendAccessory.Advertisement {
    
    init?<T: AdvertisementData>(_ advertisement: T) {
        if let bm2 = BM2.Advertisement(advertisement) {
            self = .bm2(bm2)
        } else {
            return nil
        }
    }
    
    var type: LeagendAccessory {
        switch self {
        case .bm2:
            return .bm2
        }
    }
    
    var name: String {
        switch self {
        case let .bm2(advertisement):
            return advertisement.name.rawValue
        }
    }
}
