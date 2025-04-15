import XCTest
@testable import EssentialFeed

final class KeychainSecureStorageTests: XCTestCase {
    func test_saveData_succeeds_whenKeychainStoresSuccessfully() {
        let keychain = SystemKeychainSpy()
        let sut = KeychainSecureStorage(keychain: keychain)
        let key = "test-key"
        let data = "test-data".data(using: .utf8)!
        keychain.saveResult = true

        let result = sut.save(data: data, forKey: key)

        XCTAssertEqual(keychain.receivedKey, key)
        XCTAssertEqual(keychain.receivedData, data)
        XCTAssertTrue(result)
    }

    private class SystemKeychainSpy: KeychainProtocol {
        var receivedKey: String?
        var receivedData: Data?
        var saveResult: Bool = false

        func save(data: Data, forKey key: String) -> Bool {
            receivedKey = key
            receivedData = data
            return saveResult
        }
    }

    func test_saveData_fails_whenKeychainReturnsError() {
        let keychain = SystemKeychainSpy()
        let sut = KeychainSecureStorage(keychain: keychain)
        let key = "test-key"
        let data = "test-data".data(using: .utf8)!
        keychain.saveResult = false

        let result = sut.save(data: data, forKey: key)

        XCTAssertEqual(keychain.receivedKey, key)
        XCTAssertEqual(keychain.receivedData, data)
        XCTAssertFalse(result)
    }

    func test_saveData_usesFallback_whenKeychainFails() {
        let keychain = SystemKeychainSpy()
        let fallback = FallbackSpy()
        let sut = KeychainSecureStorage(keychain: keychain, fallback: fallback)
        let key = "test-key"
        let data = "test-data".data(using: .utf8)!
        keychain.saveResult = false // Simula fallo en Keychain

        let result = sut.save(data: data, forKey: key)

        XCTAssertEqual(fallback.receivedKey, key)
        XCTAssertEqual(fallback.receivedData, data)
        XCTAssertTrue(result)
    }

    private class FallbackSpy: KeychainProtocol {
        var receivedKey: String?
        var receivedData: Data?
        func save(data: Data, forKey key: String) -> Bool {
            receivedKey = key
            receivedData = data
            return true // Simula éxito
        }
    }
    // Añadir más tests según los escenarios del BDD
}
