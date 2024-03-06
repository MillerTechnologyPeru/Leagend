import Foundation
import Bluetooth
import GATT
import XCTest
@testable import Leagend

final class LeagendTests: XCTestCase {
    
    func testLeagendKey() {
        
        let keyString = "leagendÿþ1882466"
        
        XCTAssertEqual(String(data: BM2.leagendKeyData, encoding: .ascii), keyString)
        
        let characters: [CChar] = [108,101,97,103,101,110,100,-1,-2,49,56,56,50,52,54,54]
        let characterBytes = Data(unsafeBitCast(characters, to: [UInt8].self))
        XCTAssertEqual(BM2.leagendKeyData, characterBytes)
        
        let bytes = Data([0x6c, 0x65, 0x61, 0x67, 0x65, 0x6e, 0x64, 0xff, 0xfe, 0x31, 0x38, 0x38, 0x32, 0x34, 0x36, 0x36])
        XCTAssertEqual(bytes, characterBytes)
    }
    
    func testBM2BatteryVoltageCharacteristic() throws {
        
        let data = Data([0xf5, 0x4f, 0x51, 0x4c, 0x09, 0xcf, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        
        guard let characteristic = BM2.BatteryCharacteristic(data: data) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(characteristic.voltage, 1280)
        XCTAssertEqual(characteristic.power, 76)
    }
    
    func testBM2Decrypt() throws {
        
        let encrypted = Data(unsafeBitCast([97,-71,48,-107,45,87,-59,111,-29,10,-35,76,106,-47,-27,-22] as [CChar], to: [UInt8].self))
        
        let decrypted = Data([0xf5, 0x4f, 0x51, 0x4c, 0x09, 0xcf, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        
        XCTAssertEqual(try! BM2.BatteryCharacteristic.decryptData(encrypted), decrypted)
        XCTAssertEqual(try! BM2.BatteryCharacteristic.cryptoSwiftDecrypt(encrypted), decrypted)
        #if canImport(CommonCrypto)
        XCTAssertEqual(try! BM2.BatteryCharacteristic.commonCryptoDecrypt(encrypted), decrypted)
        #endif
    }
}
