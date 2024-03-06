//
//  Crypto.swift
//
//
//  Created by Alsey Coleman Miller on 3/6/24.
//

import Foundation

#if canImport(CryptoKit)
import CryptoKit
#else
import Crypto
#endif
#if canImport(CommonCrypto)
import CommonCrypto
#endif
#if canImport(CryptoSwift)
import CryptoSwift
#endif

internal extension BM2 {
    
    // https://doubleagent.net/hardware/ble/bluetooth/2023/05/23/a-car-battery-monitor-tracking-your-location-part3
    static var leagendKeyData: Data { Data([0x6c, 0x65, 0x61, 0x67, 0x65, 0x6e, 0x64, 0xff, 0xfe, 0x31, 0x38, 0x38, 0x32, 0x34, 0x36, 0x36]) }
}

public extension BM2.BatteryCharacteristic {
    
    /// Decrypt the provided data.
    static func decrypt(_ data: Data) throws -> BM2.BatteryCharacteristic {
        let decryptedData: Data
        #if canImport(CommonCrypto)
        // TODO: Common Crypto decryption
        decryptedData = try cryptoSwiftDecrypt(data)
        #elseif canImport(CryptoSwift)
        decryptedData = try cryptoSwiftDecrypt(data)
        #else
        throw CocoaError(.featureUnsupported)
        #endif
        // parse characteristic
        guard let characteristic = BM2.BatteryCharacteristic(data: decryptedData) else {
            throw CocoaError(.coderReadCorrupt)
        }
        return characteristic
    }
}

internal extension BM2.BatteryCharacteristic {
    
    /// Decrypt the provided data.
    static func decryptData(_ data: Data) throws -> Data {
        #if canImport(CommonCrypto)
        // TODO: Common Crypto decryption
        return try cryptoSwiftDecrypt(data)
        #elseif canImport(CryptoSwift)
        return try cryptoSwiftDecrypt(data)
        #else
        throw CocoaError(.featureUnsupported)
        #endif
    }
}

#if canImport(CryptoSwift)
internal extension BM2.BatteryCharacteristic {
    
    static func cryptoSwiftDecrypt(_ encryptedData: Data) throws -> Data {
        let key = BM2.leagendKeyData
        let crypto = try CryptoSwift.AES(
            key: [UInt8](key),
            blockMode: CBC(iv: [UInt8](repeating: 0, count: AES.blockSize)),
            padding: .noPadding
        )
        let decrypted = try crypto.decrypt(.init(encryptedData))
        return Data(decrypted)
    }
}
#endif
