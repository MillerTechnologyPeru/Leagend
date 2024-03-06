//
//  Crypto.swift
//
//
//  Created by Alsey Coleman Miller on 3/6/24.
//

import Foundation

#if canImport(CryptoKit)
import CryptoKit
#elseif canImport(Crypto)
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
        #if canImport(CommonCrypto) && os(iOS)
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

#if canImport(CommonCrypto)
import CommonCrypto

func commonCryptoAES(_ operation: CCOperation, data: Data, key: Data, initializationVector: Data? = nil) throws -> Data {
    
    // padding for key
    var key = key
    if key.count < kCCKeySizeAES128 {
        let remainder = kCCKeySizeAES128 - key.count
        key.append(contentsOf: [UInt8](repeating: 0x00, count: remainder))
    }
    assert(key.count == kCCKeySizeAES128)
    // padding for input
    var data = data
    if data.count < 16 {
        let remainder = 16 - data.count
        data.append(contentsOf: [UInt8](repeating: 0x00, count: remainder))
    }
    assert(data.count == 16)
    let cryptor = try CommonCrypto(
        operation: operation,
        algorithm: CCAlgorithm(kCCAlgorithmAES),
        options: 0,
        key: key,
        iv: initializationVector
    )
    var output = Data()
    try cryptor.update(with: data, output: &output)
    try cryptor.finalize(output: &output)
    return output
}

internal extension BM2.BatteryCharacteristic {
    
    static func commonCryptoDecrypt(_ encryptedData: Data) throws -> Data {
        return try commonCryptoAES(.decrypt, data: encryptedData, key: BM2.leagendKeyData)
    }
}

#endif
