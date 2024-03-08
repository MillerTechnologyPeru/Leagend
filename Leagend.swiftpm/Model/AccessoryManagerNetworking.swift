//
//  AccessoryManagerNetworking.swift
//
//
//  Created by Alsey Coleman Miller  on 3/6/24.
//

import Foundation

internal extension AccessoryManager {
    
    func loadURLSession() -> URLSession {
        URLSession(configuration: .ephemeral)
    }
}

public extension AccessoryManager {
    
    @discardableResult
    func downloadAccessoryInfo() async throws -> LeagendAccessoryInfo.Database {
        // fetch from server
        let value = try await urlSession.downloadLeagendAccessoryInfo()
        // write to disk
        try saveAccessoryInfoFile(value)
        return value
    }
}
