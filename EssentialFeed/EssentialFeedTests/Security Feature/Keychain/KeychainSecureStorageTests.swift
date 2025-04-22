import XCTest
import EssentialFeed

// CU: Seguridad de almacenamiento en Keychain
// Checklist: Validar operaciones seguras en Keychain
final class KeychainSecureStorageTests: XCTestCase {
	func test_saveData_succeeds_whenKeychainSavesSuccessfully() {
		let (sut, keychain, _, _) = makeDefaultSUT()
		let key = "test-key"
		let data = "test-data".data(using: .utf8)!
		keychain.saveResult = KeychainSaveResult.success
		
		let result = sut.save(data: data, forKey: key)

		XCTAssertEqual(keychain.saveSpy.receivedKey, key, "Should pass correct key to keychain")
		XCTAssertEqual(keychain.saveSpy.receivedData, data, "Should pass correct data to keychain")
		XCTAssertEqual(sut.load(forKey: key), data, "Loaded data should match saved data") // This assert checks value equality, not reference
		XCTAssertEqual(result, KeychainSaveResult.success, "Save should succeed with valid input")
	}
	
	func test_saveData_fails_whenKeychainReturnsError() {
		let (sut, keychain, fallback, alternative) = makeDefaultSUT()
		let key = "test-key"
		let data = "test-data".data(using: .utf8)!
		keychain.saveResult = KeychainSaveResult.failure
		fallback.saveResult = KeychainSaveResult.failure
		alternative.saveResult = KeychainSaveResult.failure
		keychain.willValidateAfterSave = { [weak keychain] corruptedKey in
			keychain?.simulateCorruption(forKey: corruptedKey)
		}
		
		let result = sut.save(data: data, forKey: key)
		
		XCTAssertEqual(keychain.saveSpy.receivedKey, key, "Should pass correct key to keychain")
		XCTAssertEqual(keychain.saveSpy.receivedData, data, "Should pass correct data to keychain")
		assertEventuallyEqual(sut.load(forKey: key), nil)
		XCTAssertEqual(result, KeychainSaveResult.failure, "Save should fail with invalid input")
	}
	
	func test_saveData_usesFallback_whenKeychainFails() {
		let (sut, keychain, fallback, _) = makeDefaultSUT()
		let key = "test-key"
		let data = "test-data".data(using: .utf8)!
		keychain.saveResult = KeychainSaveResult.failure
		fallback.saveResult = KeychainSaveResult.success
		keychain.willValidateAfterSave = { [weak keychain] corruptedKey in
			keychain?.simulateCorruption(forKey: corruptedKey)
		}
		
		let result = sut.save(data: data, forKey: key)
		
		XCTAssertEqual(fallback.saveSpy.receivedKey, key, "Should fallback with correct key")
		XCTAssertEqual(fallback.saveSpy.receivedData, data, "Should fallback with correct data")
		assertEventuallyEqual(sut.load(forKey: key), data)
		XCTAssertEqual(result, KeychainSaveResult.success, "Save should succeed with valid input")
	}
	
	func test_saveData_usesAlternativeStorage_whenKeychainAndFallbackFail() {
		let (sut, keychain, fallback, alternative) = makeDefaultSUT()
		let key = "test-key"
		let data = "test-data".data(using: .utf8)!
		keychain.saveResult = KeychainSaveResult.failure
		fallback.saveResult = KeychainSaveResult.failure
		alternative.saveResult = KeychainSaveResult.success
		keychain.willValidateAfterSave = { [weak keychain] corruptedKey in
			keychain?.simulateCorruption(forKey: corruptedKey)
		}
		
		// Simula que Keychain y fallback fallan
		let result = sut.save(data: data, forKey: key)
		
		XCTAssertEqual(alternative.saveSpy.receivedKey, key, "Should use alternative with correct key")
		XCTAssertEqual(alternative.saveSpy.receivedData, data, "Should use alternative with correct data")
		XCTAssertEqual(result, KeychainSaveResult.success, "Save should succeed with valid input")
	}
	
	// MARK: - Helpers
	
	private func makeDefaultSUT(file: StaticString = #file, line: UInt = #line) -> (KeychainSecureStorage, KeychainFullSpy, KeychainFullSpy, KeychainFullSpy) {
		return makeSUT(
			keychain: makeKeychainFullSpy(),
			fallback: makeKeychainFullSpy(),
			alternative: makeKeychainFullSpy(),
			file: file, line: line
		)
	}
	
	private func makeSUT(
		keychain: KeychainFullSpy,
		fallback: KeychainFullSpy,
		alternative: KeychainFullSpy,
		file: StaticString = #file, line: UInt = #line
	) -> (KeychainSecureStorage, KeychainFullSpy, KeychainFullSpy, KeychainFullSpy) {
		let sut = KeychainSecureStorage(keychain: keychain, fallback: fallback, alternative: alternative)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(keychain, file: file, line: line)
		trackForMemoryLeaks(fallback, file: file, line: line)
		trackForMemoryLeaks(alternative, file: file, line: line)
		return (sut, keychain, fallback, alternative)
	}
	
}
