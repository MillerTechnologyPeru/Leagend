//
//  AccessoryInfo.swift
//
//
//  Created by Alsey Coleman Miller on 3/6/24.
//

import Foundation
import Leagend

/// Leagend Accessory Info
public struct LeagendAccessoryInfo: Equatable, Hashable, Codable, Sendable {
        
    public let symbol: String
    
    public let image: String
        
    public let manual: String?
        
    public let website: String?
}

public extension LeagendAccessoryInfo {
    
    struct Database: Equatable, Hashable, Sendable {
        
        public let accessories: [LeagendAccessory: LeagendAccessoryInfo]
    }
}

public extension LeagendAccessoryInfo.Database {
    
    subscript(type: LeagendAccessory) -> LeagendAccessoryInfo? {
        accessories[type]
    }
}

public extension LeagendAccessoryInfo.Database {
    
    internal static let encoder: PropertyListEncoder = {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        return encoder
    }()
    
    internal static let decoder: PropertyListDecoder = {
        let decoder = PropertyListDecoder()
        return decoder
    }()
    
    init(propertyList data: Data) throws {
        self = try Self.decoder.decode(LeagendAccessoryInfo.Database.self, from: data)
    }
    
    func encodePropertyList() throws -> Data {
        try Self.encoder.encode(self)
    }
}

extension LeagendAccessoryInfo.Database: Codable {
    
    public init(from decoder: Decoder) throws {
        let accessories = try [String: LeagendAccessoryInfo].init(from: decoder)
        self.accessories = try accessories.mapKeys {
            guard let key = LeagendAccessory(rawValue: $0) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid key \($0)"))
            }
            return key
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        try accessories
            .mapKeys { $0.rawValue }
            .encode(to: encoder)
    }
}
