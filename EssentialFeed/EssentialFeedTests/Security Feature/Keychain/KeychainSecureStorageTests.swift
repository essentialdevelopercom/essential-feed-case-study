import XCTest
import EssentialFeed

// CU: Seguridad de almacenamiento en Keychain
// Checklist: Validar operaciones seguras en Keychain
final class KeychainSecureStorageTests: XCTestCase {
    func test_saveData_succeeds_whenKeychainSavesSuccessfully() {
        let (sut, keychain, _, _) = makeSUT()
        let key = "test-key"
        let data = "test-data".data(using: .utf8)!
        keychain.saveResult = true

        let result = sut.save(data: data, forKey: key)

        XCTAssertEqual(keychain.receivedKey, key, "Should pass correct key to keychain")
        XCTAssertEqual(keychain.receivedData, data, "Should pass correct data to keychain")
        XCTAssertTrue(result, "Save should succeed with valid input")
    }

    func test_saveData_fails_whenKeychainReturnsError() {
        let (sut, keychain, fallback, alternative) = makeSUT()
        let key = "test-key"
        let data = "test-data".data(using: .utf8)!
        keychain.saveResult = false
        fallback.saveResult = false
        alternative.saveResult = false

        let result = sut.save(data: data, forKey: key)

        XCTAssertEqual(keychain.receivedKey, key, "Should pass correct key to keychain")
        XCTAssertEqual(keychain.receivedData, data, "Should pass correct data to keychain")
        XCTAssertFalse(result, "Save should fail with invalid input")
    }

    func test_saveData_usesFallback_whenKeychainFails() {
        let (sut, keychain, fallback, _) = makeSUT()
        let key = "test-key"
        let data = "test-data".data(using: .utf8)!
        keychain.saveResult = false
        fallback.saveResult = true

        let result = sut.save(data: data, forKey: key)

        XCTAssertEqual(fallback.receivedKey, key, "Should fallback with correct key")
        XCTAssertEqual(fallback.receivedData, data, "Should fallback with correct data")
        XCTAssertTrue(result, "Save should succeed with valid input")
    }

    func test_saveData_usesAlternativeStorage_whenKeychainAndFallbackFail() {
        let (sut, keychain, fallback, alternative) = makeSUT()
        let key = "test-key"
        let data = "test-data".data(using: .utf8)!
        keychain.saveResult = false
        fallback.saveResult = false
        alternative.saveResult = true

        // Simula que Keychain y fallback fallan
        let result = sut.save(data: data, forKey: key)

        XCTAssertEqual(alternative.receivedKey, key, "Should use alternative with correct key")
        XCTAssertEqual(alternative.receivedData, data, "Should use alternative with correct data")
        XCTAssertTrue(result, "Save should succeed with valid input")
    }

    // MARK: - Helpers
    private func makeSUT(
        keychain: SystemKeychainSpy = SystemKeychainSpy(),
        fallback: FallbackSpy = FallbackSpy(),
        alternative: AlternativeStorageSpy = AlternativeStorageSpy(),
        file: StaticString = #file, line: UInt = #line
    ) -> (KeychainSecureStorage, SystemKeychainSpy, FallbackSpy, AlternativeStorageSpy) {
        let sut = KeychainSecureStorage(keychain: keychain, fallback: fallback, alternative: alternative)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(keychain, file: file, line: line)
        trackForMemoryLeaks(fallback, file: file, line: line)
        trackForMemoryLeaks(alternative, file: file, line: line)
        return (sut, keychain, fallback, alternative)
    }
    
    private class SystemKeychainSpy: KeychainProtocol {
        var receivedKey: String?
        var receivedData: Data?
        var saveResult: Bool = true
        func save(data: Data, forKey key: String) -> Bool {
            receivedKey = key
            receivedData = data
            return saveResult
        }
    }

    private class FallbackSpy: KeychainProtocol {
        var receivedKey: String?
        var receivedData: Data?
        var saveResult: Bool = true
        func save(data: Data, forKey key: String) -> Bool {
            receivedKey = key
            receivedData = data
            return saveResult
        }
    }

    private class AlternativeStorageSpy: KeychainProtocol {
        var receivedKey: String?
        var receivedData: Data?
        var saveResult: Bool = true
        func save(data: Data, forKey key: String) -> Bool {
            receivedKey = key
            receivedData = data
            return saveResult
        }
    }
}

