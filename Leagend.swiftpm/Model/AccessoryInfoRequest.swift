//
//  AccessoryInfoRequest.swift
//
//
//  Created by Alsey Coleman Miller  on 3/6/24.
//

import Foundation

public extension URLClient {
    
    func downloadLeagendAccessoryInfo() async throws -> LeagendAccessoryInfo.Database {
        let url = URL(string: "https://raw.githubusercontent.com/MillerTechnologyPeru/Leagend/master/Leagend.swiftpm/Leagend.plist")!
        let (data, urlResponse) = try await self.data(for: URLRequest(url: url))
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw URLError(.unknown)
        }
        guard httpResponse.statusCode == 200 else {
            throw URLError(.resourceUnavailable)
        }
        let decoder = PropertyListDecoder()
        return try decoder.decode(LeagendAccessoryInfo.Database.self, from: data)
    }
}
