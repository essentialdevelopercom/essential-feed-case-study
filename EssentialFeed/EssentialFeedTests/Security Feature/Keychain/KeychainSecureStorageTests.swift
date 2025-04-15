import XCTest
@testable import EssentialFeed

final class KeychainSecureStorageTests: XCTestCase {
    func test_saveData_succeeds_whenKeychainStoresSuccessfully() {
        let keychain = KeychainSpy()
        let sut = KeychainSecureStorage(keychain: keychain)
        let key = "test-key"
        let data = "test-data".data(using: .utf8)!
        keychain.saveResult = true

        let result = sut.save(data: data, forKey: key)

        XCTAssertEqual(keychain.receivedKey, key)
        XCTAssertEqual(keychain.receivedData, data)
        XCTAssertTrue(result)
    }

    private class KeychainSpy: KeychainProtocol {
        var receivedKey: String?
        var receivedData: Data?
        var saveResult: Bool = false

        func save(data: Data, forKey key: String) -> Bool {
            receivedKey = key
            receivedData = data
            return saveResult
        }
    }

    private protocol KeychainProtocol {
        func save(data: Data, forKey key: String) -> Bool
    }

    func test_saveData_fails_whenKeychainReturnsError() {
        // Arrange: Creamos el SUT y forzamos error en Keychain
        // TODO: Implementar stub/mocks para Keychain
        XCTFail("Not implemented yet")
    }

    // Añadir más tests según los escenarios del BDD
}
