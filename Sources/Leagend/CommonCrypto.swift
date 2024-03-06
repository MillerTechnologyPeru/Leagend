//
//  CommonCrypto.swift
//  
//
//  Created by Alsey Coleman Miller on 3/6/24.
//

#if canImport(CommonCrypto)
import Foundation
import CommonCrypto

internal final class CommonCrypto {
    
    private(set) var internalPointer: CCCryptorRef? = nil
    
    let key: Data?
    
    let iv: Data?
    
    deinit {
        CCCryptorRelease(internalPointer)
    }
    
    init(operation: CCOperation, algorithm: CCAlgorithm, options: CCOptions = 0, key: Data? = nil, iv: Data? = nil) throws {
        self.key = key
        self.iv = iv
        let keyPointer = key?.withUnsafeBytes({ $0.baseAddress })
        let ivPointer = iv?.withUnsafeBytes({ $0.baseAddress })
        let status = CCCryptorCreate(operation, algorithm, options, keyPointer, key?.count ?? 0, ivPointer, &internalPointer)
        guard status == kCCSuccess else {
            throw CommonCryptoError(status: status)
        }
    }
    
    func update(with data: Data, output: inout Data) throws {
        let outputLength = CCCryptorGetOutputLength(internalPointer, data.count, false)
        var dataOut = Data(repeating: 0, count: outputLength)
        var dataOutMoved = 0
        let status = data.withUnsafeBytes { (dataInBuffer) in
            dataOut.withUnsafeMutableBytes { (dataOutBuffer) in
                CCCryptorUpdate(internalPointer, dataInBuffer.baseAddress, data.count, dataOutBuffer.baseAddress, outputLength, &dataOutMoved)
            }
        }
        guard status == kCCSuccess else {
            throw CommonCryptoError(status: status)
        }
        output.append(dataOut[0..<Int(dataOutMoved)])
    }
    
    func finalize(output: inout Data) throws {
        let outputLength = CCCryptorGetOutputLength(internalPointer, 0, true)
        var dataOut = Data(repeating: 0, count: outputLength)
        var dataOutMoved = 0
        let status = dataOut.withUnsafeMutableBytes { (dataOutBuffer) in
            CCCryptorFinal(internalPointer, dataOutBuffer.baseAddress, outputLength, &dataOutMoved)
        }
        guard status == kCCSuccess else {
            throw CommonCryptoError(status: status)
        }
        output.append(dataOut[0..<Int(dataOutMoved)])
    }
}

// MARK: - Context

internal protocol CommonCryptoContext {
    
    associatedtype CommonCryptoType
    
    typealias Update = (_ c: UnsafeMutablePointer<CommonCryptoType>, _ data: UnsafeRawPointer?, _ len: CC_LONG) -> Int32
    
    typealias Final = (UnsafeMutablePointer<UInt8>?, UnsafeMutablePointer<CommonCryptoType>) -> Int32
    
    static var digestLength: Int { get }
    
    init()
    
    var context: CommonCryptoType { get set }
    
    static var update: Update { get }
    
    static var final: Final { get }
}

extension CommonCryptoContext {
    
    mutating func update(_ data: Data) throws {
        let result = data.withUnsafeBytes {
            Self.update(&context, $0, CC_LONG(data.count))
        }
        assert(result == 1)
    }
    
    mutating func finalize() throws -> Data {
        var data = Data(repeating: 0x00, count: Self.digestLength)
        let result = data.withUnsafeMutableBytes {
            Self.final($0, &context)
        }
        assert(result == 1)
        return data
    }
}

// MARK: - Error

internal struct CommonCryptoError: Error {
    
    public let status: CCStatus
    
    internal init(status: CCStatus) {
        self.status = status
        assert(status != kCCSuccess)
    }
}

extension CommonCryptoError: CustomStringConvertible {
    
    public var description: String {
        switch Int(status) {
        case kCCSuccess:
            return "Success"
        case kCCParamError:
            return "Parameter Error"
        case kCCBufferTooSmall:
            return "Buffer Too Small"
        case kCCMemoryFailure:
            return "Memory Failure"
        case kCCAlignmentError:
            return "Alignment Error"
        case kCCDecodeError:
            return "Decode Error"
        case kCCUnimplemented:
            return "Unimplemented Function"
        default:
            return "CommonCrypto Error \(status)"
        }
    }
}

internal extension CCOperation {
    
    static var encrypt: CCOperation { return CCOperation(kCCEncrypt) }
    
    static var decrypt: CCOperation { return CCOperation(kCCDecrypt) }
}

#endif
