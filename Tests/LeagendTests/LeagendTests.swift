import Foundation
import Bluetooth
#if canImport(BluetoothGAP)
import BluetoothGAP
#endif
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
        
        XCTAssertEqual(characteristic.voltage, 1269)
        XCTAssertEqual(characteristic.voltage.voltage, 12.69)
        XCTAssertEqual(characteristic.voltage.description, "12.69V")
        XCTAssertEqual(characteristic.power, 76)
        XCTAssertEqual(characteristic.power.description, "76%")
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
    
    func testBM2SystemID() {
        
        // Read Response - System ID - Value: 56D2 8000 007B 5450
        let data = Data([0x56, 0xD2, 0x80, 0x00, 0x00, 0x7B, 0x54, 0x50])
        let id = UInt64(littleEndian: UInt64(bytes: (data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7])))
        XCTAssertEqual(id, 0x50547B000080D256)
        
        let address = BluetoothAddress(
            bigEndian: BluetoothAddress(
                bytes: (
                    id.bigEndian.bytes.0,
                    id.bigEndian.bytes.1,
                    id.bigEndian.bytes.2,
                    id.bigEndian.bytes.5,
                    id.bigEndian.bytes.6,
                    id.bigEndian.bytes.7
                )
            )
        )
        
        XCTAssertEqual(address.rawValue, "50:54:7B:80:D2:56")
    }
    
    #if canImport(BluetoothGAP)
    
    func testAdvertisement() throws {
        
        let data: LowEnergyAdvertisingData = [0x02, 0x01, 0x06, 0x03, 0x02, 0xF0, 0xFF, 0x11, 0xFF, 0xE4, 0xC3, 0x6D, 0x30, 0xF2, 0xAE, 0x3D, 0xAD, 0x94, 0xF7, 0x5F, 0xDA, 0x86, 0xDB, 0xA4, 0xEE]
        
        XCTAssertEqual(data.serviceUUIDs, [.leagendBM2Service])
    }
    
    func testBeacon() throws {
        
        let data: LowEnergyAdvertisingData = [0x02, 0x01, 0x06, 0x1A, 0xFF, 0x4C, 0x00, 0x02, 0x15, 0x65, 0x5F, 0x83, 0xCA, 0xAE, 0x16, 0xA1, 0x0A, 0x70, 0x2E, 0x31, 0xF3, 0x0D, 0x58, 0xDD, 0x82, 0xF6, 0x44, 0x00, 0x00, 0x64]
        
        guard let manufacturerData = data.manufacturerData, 
            let beacon = AppleBeacon(manufacturerData: manufacturerData) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(beacon.uuid.description, "655F83CA-AE16-A10A-702E-31F30D58DD82")
        XCTAssertEqual(beacon.major, 63044)
        XCTAssertEqual(beacon.minor, 0)
    }
    
    #endif
}
