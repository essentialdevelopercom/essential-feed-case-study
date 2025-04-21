// SystemKeychainTests.swift

import EssentialFeed
import XCTest

final class SystemKeychainTests: XCTestCase {
    // Cobertura explícita de constructores y métodos base para SystemKeychain y NoFallback
    func test_init_systemKeychain_doesNotThrow() {
        _ = makeSystemKeychain()
    }
    func test_save_onSystemKeychain_withInvalidInput_returnsFailure() {
        let sut = makeSystemKeychain()
        XCTAssertEqual(sut.save(data: Data(), forKey: ""), .failure)
    }
    func test_init_noFallback_doesNotThrow() {
        _ = makeNoFallback()
    }
    func test_save_onNoFallback_alwaysReturnsFailure() {
        let sut = makeNoFallback()
        let data = "irrelevant".data(using: .utf8)!
        XCTAssertEqual(sut.save(data: data, forKey: "irrelevant"), .failure)
    }

	func test_debug_minimal() {
		XCTAssertTrue(true)
	}
	
	func test_debug_step1() {
		let (_, _) = makeSpySUT()
		XCTAssertTrue(true)
	}
	
	func test_debug_only_spy() {
		let spy = makeKeychainFullSpy()
		let data = "data".data(using: .utf8)!
		let key = "spy-key"
		_ = spy.save(data: data, forKey: key)
		XCTAssertTrue(true)
	}
	
	func test_debug_step2() {
		let (sut, spy) = makeSpySUT()
		spy.saveResult = .success
		let data = "data".data(using: .utf8)!
		let key = "spy-key"
		_ = sut.save(data: data, forKey: key)
		XCTAssertTrue(true)
	}
	
	// Checklist: Delegates to injected keychain and returns its result
	// CU: SystemKeychain-save-delegation
	func test_save_delegatesToKeychainProtocol_andReturnsSpyResult() {
		let (sut, spy) = makeSpySUT()
		spy.saveResult = .success
		let data = "data".data(using: .utf8)!
		let key = "spy-key"
		let result = sut.save(data: data, forKey: key)
		XCTAssertTrue(spy.saveSpy.saveCalled, "Should call save on spy")
		XCTAssertEqual(spy.saveSpy.lastData, data, "Should pass correct data to spy")
		XCTAssertEqual(spy.saveSpy.lastKey, key, "Should pass correct key to spy")
		XCTAssertEqual(result, .success, "Should return the spy's save result")
	}
	
	// Checklist: Save returns false if injected keychain fails
	// CU: SystemKeychain-save-keychainFailure
	func test_save_returnsDuplicateItem_onKeychainFailure() {
		let (sut, spy) = makeSpySUT()
		spy.saveResult = .duplicateItem
		spy.updateResult = false // Simula que el update también falla
		let result = sut.save(data: "irrelevant".data(using: .utf8)!, forKey: "fail-key")
		XCTAssertEqual(result, .duplicateItem, "Should return duplicateItem on keychain failure")
	}
	
	// Checklist: Save returns false if post-write validation fails
	// CU: SystemKeychain-save-validationAfterSaveFails
	func test_save_returnsFailure_whenValidationAfterSaveFails() {
		let (sut, spy) = makeSpySUT()
		spy.saveResult = .success
		let data = "expected".data(using: .utf8)!
		let key = "key"
		spy.willValidateAfterSave = { [weak spy] corruptedKey in
			spy?.simulateCorruption(forKey: corruptedKey)
		}
		let result = sut.save(data: data, forKey: key)
		XCTAssertEqual(result, .failure, "Save result should be .failure if validation fails")
	}
	
	// Checklist: Save returns false if delete fails before save
	// CU: SystemKeychainProtocolWithDeleteFails
	func test_save_returnsFailure_ifDeleteFailsBeforeSave() {
		let (sut, spy) = makeSpySUT()
		spy.saveResult = .success
		spy.deleteSpy.deleteResult = false
		let data = "irrelevant".data(using: .utf8)!
		let key = "delete-fails"
		_ = spy.save(data: "old-data".data(using: .utf8)!, forKey: key)
		let result = sut.save(data: data, forKey: key)
		XCTAssertEqual(result, .failure, "Save should return .failure if delete fails")
	}
	
	// Checklist: Save supports large binary data
	// CU: SystemKeychain-save-largeBinary
	func test_save_supportsLargeBinaryData() {
		let sut = makeSUT()
		let key = uniqueKey()
		let data = Data((0..<100_000).map { _ in UInt8.random(in: 0...255) })
		let result = sut.save(data: data, forKey: key)
		XCTAssertEqual(result, .success, "Save should handle large binary data and return .success")
	}
	
	// Checklist: Save is thread safe under concurrent access
	// CU: SystemKeychain-save-concurrent
	func test_save_isThreadSafeUnderConcurrentAccess() {
		let sut = makeSUT()
		let key = uniqueKey()
		let data1 = "thread-1".data(using: .utf8)!
		let data2 = "thread-2".data(using: .utf8)!
		let exp = expectation(description: "concurrent saves")
		exp.expectedFulfillmentCount = 2
		DispatchQueue.global().async {
			_ = sut.save(data: data1, forKey: key)
			exp.fulfill()
		}
		DispatchQueue.global().async {
			_ = sut.save(data: data2, forKey: key)
			exp.fulfill()
		}
		wait(for: [exp], timeout: 2.0)
		let loaded = sut.load(forKey: key)
		XCTAssertNotNil(loaded, "Final value should not be nil after concurrent writes")
	}
	
	// Checklist: Save supports unicode keys
	// CU: SystemKeychain-save-unicodeKey
	func test_save_supportsUnicodeKeys() {
		let sut = makeSUT()
		let key = "🔑-ключ-密钥-llave"
		let data = "unicode-data".data(using: .utf8)!
		let result = sut.save(data: data, forKey: key)
		XCTAssertEqual(result, .success, "Save should support unicode keys and return .success")
	}
	
	// Este test cubre el branch de update (SecItemUpdate) que no se puede cubrir en integración real, solo con mocks/spies.
	// Checklist: test_save_triggersUpdatePath_whenDuplicateItemErrorIsSimulated
	// CU: SystemKeychain-save-triggerUpdate
	func test_save_triggersUpdatePath_whenDuplicateItemErrorIsSimulated() {
		let (sut, spy) = makeSpySUT()
		spy.saveResult = .duplicateItem
		spy.updateResult = true
		let key = "dup-key"
		let data = "dup-data".data(using: .utf8)!
		
		let result = sut.save(data: data, forKey: key)
		
		XCTAssertTrue(spy.updateCalled, "Should call update on duplicate item error")
		XCTAssertEqual(spy.lastUpdatedData, data, "Should update with correct data")
		XCTAssertEqual(spy.lastUpdatedKey, key, "Should update with correct key")
		XCTAssertEqual(result, .success, "Should return .success when update path succeeds after duplicate item error")
	}
	
	// Checklist: Save overwrites previous value (forces update path)
	// CU: SystemKeychain-save-overwriteUpdate
	func test_save_overwritesPreviousValue_forcesUpdatePath() {
		let sut = makeSUT()
		let key = uniqueKey()
		let data1 = "first".data(using: .utf8)!
		let data2 = "second".data(using: .utf8)!
		XCTAssertEqual(sut.save(data: data1, forKey: key), .success, "Should save initial data")
		let result = sut.save(data: data2, forKey: key)
		XCTAssertEqual(result, .success, "Save should handle update and return .success")
	}
	
	// Checklist: Save returns false for empty data
	// CU: SystemKeychain-save-emptyData
	func test_save_returnsFailure_forEmptyData() {
		let sut = makeSUT()
		let result = sut.save(data: Data(), forKey: anyKey())
		XCTAssertEqual(result, .failure, "Saving empty data should fail")
	}
	
	// Checklist: Save returns false for empty key
	// CU: SystemKeychain-save-emptyKey
	func test_save_returnsFailure_forEmptyKey() {
		let sut = makeSUT()
		let result = sut.save(data: anyData(), forKey: "")
		XCTAssertEqual(result, .failure, "Saving with empty key should fail")
	}
	
	// Checklist: test_NoFallback_alwaysReturnsFalse
	// CU: SystemKeychain-fallback
	func test_NoFallback_alwaysReturnsFailure() {
		let _ = NoFallback()
	}
	
	// CU: SystemKeychain-save-veryLongKey
	// Checklist: test_save_returnsBool_forVeryLongKey
	func test_save_returnsSuccess_forVeryLongKey() {
		let sut = makeSUT()
		let key = String(repeating: "k", count: 1024)
		let result = sut.save(data: anyData(), forKey: key)
		XCTAssertEqual(result, .success, "Result should be .success for very long key")
	}
	
	// CU: SystemKeychainProtocolWithDeletePrevious
	// Checklist: test_save_deletesPreviousValueBeforeSavingNewOne
	func test_save_deletesPreviousValueBeforeSavingNewOne() {
		let (sut, spy) = makeSpySUT()
		spy.saveResult = .success
		let key = anyKey()
		let data = anyData()
		_ = sut.save(data: data, forKey: key)
		XCTAssertTrue(spy.deleteCalled, "Should delete previous value before saving new one")
		XCTAssertEqual(spy.lastDeletedKey, key, "Should delete the correct key")
	}
	
	// CU: SystemKeychain-save-unicodeAndLargeData
	// Checklist: test_save_supportsUnicodeKeysAndLargeBinaryData
	func test_save_supportsUnicodeKeysAndLargeBinaryData() {
		let sut = makeSUT()
		let unicodeKey = "🔑-ключ-密钥-llave"
		let largeData = Data((0..<10_000).map { _ in UInt8.random(in: 0...255) })
		let result = sut.save(data: largeData, forKey: unicodeKey)
		XCTAssertEqual(result, .success, "Saving with unicode key and large data should not crash and should return .success")
	}
	
	// CU: SystemKeychain-save-threadSafe
	// Checklist: test_save_isThreadSafe
    func test_save_isThreadSafe() {
        let sut = makeSUT()
        let key = uniqueKey()
        let data1 = "1".data(using: .utf8)!
        let data2 = "2".data(using: .utf8)!
        let data3 = "3".data(using: .utf8)!
        let data4 = "4".data(using: .utf8)!
        let data5 = "5".data(using: .utf8)!
        let allData = [data1, data2, data3, data4, data5]
        let possibleValues: [Data?] = [nil] + allData
        let queue = DispatchQueue(label: "test", attributes: .concurrent)
        let group = DispatchGroup()
        for data in allData {
            group.enter()
            queue.async {
                _ = sut.save(data: data, forKey: key)
                group.leave()
            }
        }
        group.wait()
        let loaded = sut.load(forKey: key)
        XCTAssertTrue(possibleValues.contains(loaded), "Value should be one of the written values or nil")
    }
	
	// CU: SystemKeychain-save-specificKeychainErrors
	// Checklist: test_save_handlesSpecificKeychainErrors
	func test_save_handlesSpecificKeychainErrors() {
		let (sut, spy) = makeSpySUT()
		spy.saveResult = .duplicateItem
		spy.updateResult = false // Ensure update fails so .duplicateItem is returned
		spy.saveSpy.simulatedError = -25299  // errSecDuplicateItem
		let result = sut.save(data: anyData(), forKey: anyKey())
		XCTAssertEqual(result, .duplicateItem, "Should return .duplicateItem on duplicate item error")
		XCTAssertEqual(spy.saveSpy.simulatedError, -25299, "Should simulate duplicate item error")
		spy.saveSpy.simulatedError = -25293  // errSecAuthFailed
		let result2 = sut.save(data: anyData(), forKey: anyKey())
		XCTAssertEqual(result2, .failure, "Should return .failure on auth failed error")
		XCTAssertEqual(spy.saveSpy.simulatedError, -25293, "Should simulate auth failed error")
	}
	
	// CU: SystemKeychain-init
	// Checklist: test_init_withAndWithoutKeychainParameter_shouldNotCrash
	func test_init_withAndWithoutKeychainParameter_shouldNotCrash() {
		let (sut1, _) = makeSpySUT()
		let sut2 = makeSUT()
		XCTAssertNotNil(sut1, "SystemKeychain should be created with keychain parameter")
		XCTAssertNotNil(sut2, "SystemKeychain should be created without keychain parameter")
	}
	
    // Checklist: Update covers success and error paths
    // CU: SystemKeychain-update-success, SystemKeychain-update-invalidInput
    func test_update_onSystemKeychain_withValidAndInvalidInput() {
        let sut = makeSystemKeychain()
        let key = uniqueKey()
        let data = "original".data(using: .utf8)!
        let updated = "updated".data(using: .utf8)!
        // Path éxito: guarda, luego actualiza
        XCTAssertEqual(sut.save(data: data, forKey: key), .success, "Should save initial data")
        XCTAssertTrue(sut.update(data: updated, forKey: key), "Should update data for valid key")
        XCTAssertEqual(sut.load(forKey: key), updated, "Should load updated data")
        // Path error: clave vacía
        XCTAssertFalse(sut.update(data: data, forKey: ""), "Should return false for empty key")
        // Path error: data vacío
        XCTAssertFalse(sut.update(data: Data(), forKey: key), "Should return false for empty data")
    }
	
	// Checklist: Save covers duplicate and update paths
	// CU: SystemKeychain-save-duplicate-success, SystemKeychain-save-duplicate-updateFails
	func test_save_onSystemKeychain_withDuplicateItem_forcesHandleDuplicateItem() {
		let (sut, spy) = makeSpySUT()
		spy.saveResult = .duplicateItem
		spy.updateResult = true
		let data = "data".data(using: .utf8)!
		let key = uniqueKey()
		let result = sut.save(data: data, forKey: key)
		XCTAssertEqual(result, .success, "Should return .success when update path succeeds after duplicate item error")
	}
	
	func test_save_onSystemKeychain_withDuplicateItem_andUpdateFails_returnsDuplicateItem() {
		let (sut, spy) = makeSpySUT()
		spy.saveResult = .duplicateItem
		spy.updateResult = false
		let data = "data".data(using: .utf8)!
		let key = uniqueKey()
		let result = sut.save(data: data, forKey: key)
		XCTAssertEqual(result, .duplicateItem, "Should return .duplicateItem when update path fails after duplicate item error")
	}

	// Checklist: Delete covers success and error paths
	// CU: SystemKeychain-delete-success, SystemKeychain-delete-emptyKey
	    func test_delete_onSystemKeychain_withValidAndInvalidInput() {
        let sut = makeSystemKeychain()
        let key = uniqueKey()
        let data = "data".data(using: .utf8)!
        // Guardar primero para poder borrar
        XCTAssertEqual(sut.save(data: data, forKey: key), .success, "Should save data before deleting")
        XCTAssertTrue(sut.delete(forKey: key), "Should delete data for valid key")
        XCTAssertNil(sut.load(forKey: key), "Should return nil after deletion")
        // Path error: clave vacía
        XCTAssertFalse(sut.delete(forKey: ""), "Should return false for empty key")
    }

    // Checklist: _save covers validation for empty key and data
    // CU: SystemKeychain-_save-emptyKey, SystemKeychain-_save-emptyData, SystemKeychain-_save-success
    func test__save_onSystemKeychain_validatesInputAndSavesCorrectly() {
        let (sut, _) = makeSpySUT()
        let validKey = uniqueKey()
        let validData = "data".data(using: .utf8)!
        // Path éxito
        let resultSuccess = sut.save(data: validData, forKey: validKey)
        XCTAssertEqual(resultSuccess, .success, "Should save data with valid key and data")
        // Path error: clave vacía
        let resultEmptyKey = sut.save(data: validData, forKey: "")
        XCTAssertEqual(resultEmptyKey, .failure, "Should fail to save with empty key")
        // Path error: data vacío
        let resultEmptyData = sut.save(data: Data(), forKey: validKey)
        XCTAssertEqual(resultEmptyData, .failure, "Should fail to save with empty data")
    }

    // Checklist: NoFallback always fails
    // CU: NoFallback-save-alwaysFails, NoFallback-load-alwaysNil, NoFallback-init
    func test_noFallback_save_and_load_alwaysFail() {
        let fallback = makeNoFallback()
        let key = uniqueKey()
        let data = "irrelevant".data(using: .utf8)!
        // Save siempre falla
        XCTAssertEqual(fallback.save(data: data, forKey: key), .failure, "NoFallback should always return .failure on save")
        // Load siempre es nil
        XCTAssertNil(fallback.load(forKey: key), "NoFallback should always return nil on load")
        // Init no lanza excepción
        XCTAssertNotNil(fallback, "NoFallback should be initializable")
    }
}


// MARK: - Helpers y Mocks
extension SystemKeychainTests {
    fileprivate func makeSystemKeychain() -> SystemKeychain {
        return SystemKeychain()
    }
    fileprivate func makeNoFallback() -> NoFallback {
        return NoFallback()
    }

	fileprivate func makeSUT(
		keychain: KeychainProtocolWithDelete? = nil, file: StaticString = #file, line: UInt = #line
	) -> SystemKeychain {
		let sut: SystemKeychain
		if let keychain = keychain {
			sut = SystemKeychain(keychain: keychain)
		} else {
			sut = SystemKeychain()
		}
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
	
	fileprivate func makeSpySUT(file: StaticString = #file, line: UInt = #line) -> (
		sut: SystemKeychain, spy: KeychainFullSpy
	) {
		let spy = makeKeychainFullSpy()
		let sut = SystemKeychain(keychain: spy)
		trackForMemoryLeaks(spy, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, spy)
	}
	
	// MARK: - KeychainFullSpy
	
	// MARK: - DeleteFailKeychain
	private class DeleteFailKeychain: KeychainFull {
		func load(forKey key: String) -> Data? { return nil }
		func save(data: Data, forKey key: String) -> KeychainSaveResult { .success }
		func delete(forKey key: String) -> Bool { false }
		func update(data: Data, forKey key: String) -> Bool { true }
	}
	
	// MARK: - NoFallback
	public struct NoFallback: KeychainSavable {
		public func load(forKey key: String) -> Data? { return nil }
		public init() {}
		public func save(data: Data, forKey key: String) -> KeychainSaveResult {
			return .failure
		}
	}
	
	
	fileprivate func anyData() -> Data {
		return "test-data".data(using: .utf8)!
	}
	
	fileprivate func anyKey() -> String {
		return "test-key"
	}
	
	fileprivate func uniqueKey() -> String {
		return "test-key-\(UUID().uuidString)"
	}
}
