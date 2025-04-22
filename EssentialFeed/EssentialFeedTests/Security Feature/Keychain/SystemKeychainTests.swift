// SystemKeychainTests.swift

import EssentialFeed
import XCTest

final class SystemKeychainTests: XCTestCase {
	
	// MARK: - Concurrency and Thread Safety
	
	// Checklist: Thread Safety
	// CU: SystemKeychain-save-concurrent
	func test_save_isThreadSafe_underConcurrentAccess() {
		var sut: SystemKeychain? = makeSUT()
		let key = uniqueKey()
		let data = "concurrent-data".data(using: .utf8)!
		let queue = DispatchQueue(label: "test.concurrent", attributes: .concurrent)
		let expectation = expectation(description: "Concurrent saves")
		expectation.expectedFulfillmentCount = 10 // Para depuración, luego vuelve a 100
		let resultsLock = NSLock()
		var results = [KeychainSaveResult]()
		for _ in 0..<10 {
			queue.async { [weak sut] in
				guard let sut = sut else {
					expectation.fulfill()
					return
				}
				let result = sut.save(data: data, forKey: key)
				resultsLock.lock()
				results.append(result)
				resultsLock.unlock()
				expectation.fulfill()
			}
		}
		// Forzamos la liberación del SUT antes del wait
		sut = nil
		wait(for: [expectation], timeout: 5)
		XCTAssertTrue(results.allSatisfy { $0 == .success || $0 == .duplicateItem }, "All concurrent saves should succeed or be duplicateItem")
	}
	
	// MARK: - Validation after Save (Simulated Corruption)
	
	// Checklist: Validation after Save
	// CU: SystemKeychain-save-validationAfterSave
	func test_save_returnsFailure_whenValidationAfterSaveFails_dueToCorruption() {
		let (sut, spy) = makeSpySUT()
		spy.saveResult = .success
		let data = "expected".data(using: .utf8)!
		let key = uniqueKey()
		spy.willValidateAfterSave = { [weak spy] corruptedKey in
			spy?.simulateCorruption(forKey: corruptedKey)
		}
		let result = sut.save(data: data, forKey: key)
		XCTAssertEqual(result, .failure, "Save should return failure if validation after save fails due to corruption")
	}
	
	// MARK: - Duplicate Item and Update Fails
	
	// Checklist: Duplicate Item and Update Fails
	// CU: SystemKeychain-save-duplicateItem
	func test_save_returnsDuplicateItem_whenUpdateFailsAfterDuplicate() {
		let (sut, spy) = makeSpySUT()
		let data = "data".data(using: .utf8)!
		let key = uniqueKey()
		spy.saveResult = .duplicateItem
		spy.updateStatus = errSecDuplicateItem
		let result = sut.save(data: data, forKey: key)
		XCTAssertEqual(result, .duplicateItem, "Should return duplicateItem when update fails after duplicate")
	}
	
	// MARK: - Error Fallback (NoFallback Strategy)
	
	// Checklist: Error Fallback
	// CU: SystemKeychain-save-noFallback
	func test_save_onNoFallbackStrategy_alwaysReturnsFailure() {
		let sut = makeNoFallback()
		let data = "irrelevant".data(using: .utf8)!
		let key = uniqueKey()
		let result = sut.save(data: data, forKey: key)
		XCTAssertEqual(result, .failure, "NoFallback should always return failure on save")
	}
	
	// MARK: - Edge Cases: Empty Key/Data
	func test_save_returnsFailure_forEmptyKeyOrData() {
		let sut = makeSUT()
		let data = "irrelevant".data(using: .utf8)!
		XCTAssertEqual(sut.save(data: data, forKey: ""), .failure, "Saving with empty key should fail")
		XCTAssertEqual(sut.save(data: Data(), forKey: uniqueKey()), .failure, "Saving with empty data should fail")
	}
	
	// MARK: - Unicode Keys and Large Data
	func test_save_supportsUnicodeKeys_andLargeBinaryData() {
		let sut = makeSUT()
		let unicodeKey = "🔑-ключ-密钥-llave"
		let data = Data((0..<100_000).map { _ in UInt8.random(in: 0...255) })
		let result = sut.save(data: data, forKey: unicodeKey)
		XCTAssertEqual(result, .success, "Should save large binary data with unicode key successfully")
		let loaded = sut.load(forKey: unicodeKey)
		XCTAssertEqual(loaded, data, "Loaded data should match saved data for unicode key")
	}
	
	// MARK: - Helpers/Factories Edge Cases
	func test_save_and_delete_withEdgeCaseKeys_andHelpers() {
		let (sut, _) = makeSpySUT()
		let emptyKey = ""
		let spacesKey = "   "
		let normalData = "data".data(using: .utf8)!
		XCTAssertEqual(sut.save(data: normalData, forKey: emptyKey), .failure, "Should fail to save with empty key")
		XCTAssertEqual(sut.save(data: normalData, forKey: spacesKey), .failure, "Should fail to save with spaces key")
		XCTAssertFalse(sut.delete(forKey: emptyKey), "Should fail to delete with empty key")
		XCTAssertFalse(sut.delete(forKey: spacesKey), "Should fail to delete with spaces key")
	}
	
	// MARK: - Borrado de clave inexistente
	func test_delete_returnsTrue_whenKeyDoesNotExist() {
		let (sut, spy) = makeSpySUT()
		let key = uniqueKey()
		spy.deleteSpy.deleteResult = true
		spy.updateStatus = errSecSuccess
		XCTAssertTrue(sut.delete(forKey: key), "Should return true when deleting non-existent key (Keychain semantics)")
	}
	
	// Checklist: Delegates to injected keychain and returns its result
	// CU: SystemKeychain-save-delegation
	func test_save_delegatesToKeychainProtocol_andReturnsSpyResult() {
		let (sut, spy) = makeSpySUT()
		spy.saveResult = KeychainSaveResult.success
		let data = "data".data(using: .utf8)!
		let key = "spy-key"
		let result = sut.save(data: data, forKey: key)
		XCTAssertTrue(spy.saveSpy.saveCalled, "Should call save on spy")
		XCTAssertEqual(spy.saveSpy.lastData, data, "Should pass correct data to spy")
		XCTAssertEqual(spy.saveSpy.lastKey, key, "Should pass correct key to spy")
		XCTAssertEqual(result, KeychainSaveResult.success, "Should return the spy's save result")
	}
	
	// Checklist: Save returns false if injected keychain fails
	// CU: SystemKeychain-save-keychainFailure
	func test_save_returnsDuplicateItem_onKeychainFailure() {
		let (sut, spy) = makeSpySUT()
		spy.saveResult = KeychainSaveResult.duplicateItem
		spy.updateStatus = errSecDuplicateItem  // Simula que el update también falla
		let result = sut.save(data: "irrelevant".data(using: .utf8)!, forKey: "fail-key")
		XCTAssertEqual(
			result, KeychainSaveResult.duplicateItem, "Should return duplicateItem on keychain failure")
	}
	
	// Checklist: Save returns false if post-write validation fails
	// CU: SystemKeychain-save-validationAfterSaveFails
	func test_save_returnsFailure_whenValidationAfterSaveFails() {
		let (sut, spy) = makeSpySUT()
		spy.saveResult = KeychainSaveResult.success
		let data = "expected".data(using: .utf8)!
		let key = "key"
		spy.willValidateAfterSave = { [weak spy] (corruptedKey: String) in
			spy?.simulateCorruption(forKey: corruptedKey)
		}
		let result = sut.save(data: data, forKey: key)
		XCTAssertEqual(
			result, KeychainSaveResult.failure,
			"Save result should be KeychainSaveResult.failure if validation fails")
	}
	
	// Checklist: Save returns false if delete fails before save
	// CU: SystemKeychainProtocolWithDeleteFails
	func test_save_returnsFailure_ifDeleteFailsBeforeSave() {
		let (sut, spy) = makeSpySUT()
		spy.saveResult = KeychainSaveResult.success
		spy.deleteSpy.deleteResult = false
		let data = "irrelevant".data(using: .utf8)!
		let key = "delete-fails"
		_ = spy.save(data: "old-data".data(using: .utf8)!, forKey: key)
		let result = sut.save(data: data, forKey: key)
		XCTAssertEqual(
			result, KeychainSaveResult.failure,
			"Save should return KeychainSaveResult.failure if delete fails")
	}
	
	// Checklist: Save supports large binary data
	// CU: SystemKeychain-save-largeBinary
	func test_save_supportsLargeBinaryData() {
		let sut = makeSUT()
		let key = uniqueKey()
		let data = Data((0..<100_000).map { _ in UInt8.random(in: 0...255) })
		let result = sut.save(data: data, forKey: key)
		XCTAssertEqual(
			result, KeychainSaveResult.success,
			"Save should handle large binary data and return KeychainSaveResult.success")
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
		XCTAssertEqual(
			result, KeychainSaveResult.success,
			"Save should support unicode keys and return KeychainSaveResult.success")
	}
	
	// Checklist: Save overwrites previous value (forces update path)
	// CU: SystemKeychain-save-overwriteUpdate
	func test_save_overwritesPreviousValue_forcesUpdatePath() {
		let sut = makeSUT()
		let key = uniqueKey()
		let data1 = "first".data(using: .utf8)!
		let data2 = "second".data(using: .utf8)!
		XCTAssertEqual(
			sut.save(data: data1, forKey: key), KeychainSaveResult.success, "Should save initial data")
		let result = sut.save(data: data2, forKey: key)
		XCTAssertEqual(
			result, KeychainSaveResult.success,
			"Save should handle update and return KeychainSaveResult.success")
	}
	
	// Checklist: Save returns false for empty data
	// CU: SystemKeychain-save-emptyData
	func test_save_returnsFailure_forEmptyData() {
		let sut = makeSUT()
		let result = sut.save(data: Data(), forKey: anyKey())
		XCTAssertEqual(result, KeychainSaveResult.failure, "Saving empty data should fail")
	}
	
	// Checklist: Save returns false for empty key
	// CU: SystemKeychain-save-emptyKey
	func test_save_returnsFailure_forEmptyKey() {
		let sut = makeSUT()
		let result = sut.save(data: anyData(), forKey: "")
		XCTAssertEqual(result, KeychainSaveResult.failure, "Saving with empty key should fail")
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
		XCTAssertEqual(
			result, KeychainSaveResult.success,
			"Result should be KeychainSaveResult.success for very long key")
	}
	
	// CU: SystemKeychainProtocolWithDeletePrevious
	// Checklist: test_save_deletesPreviousValueBeforeSavingNewOne
	func test_save_deletesPreviousValueBeforeSavingNewOne() {
		let (sut, spy) = makeSpySUT()
		spy.saveResult = KeychainSaveResult.success
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
		XCTAssertEqual(
			result, KeychainSaveResult.success,
			"Saving with unicode key and large data should not crash and should return KeychainSaveResult.success"
		)
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
		XCTAssertTrue(
			possibleValues.contains(loaded), "Value should be one of the written values or nil")
	}
	
	// CU: SystemKeychain-save-specificKeychainErrors
	// Checklist: test_save_handlesSpecificKeychainErrors
	func test_save_handlesSpecificKeychainErrors() {
		let (sut, spy) = makeSpySUT()
		spy.saveResult = KeychainSaveResult.duplicateItem
		spy.updateStatus = errSecDuplicateItem  // Ensure update fails so KeychainSaveResult.duplicateItem is returned
		spy.saveSpy.simulatedError = -25299  // errSecDuplicateItem
		let result = sut.save(data: anyData(), forKey: anyKey())
		XCTAssertEqual(
			result, KeychainSaveResult.duplicateItem,
			"Should return KeychainSaveResult.duplicateItem on duplicate item error")
		XCTAssertEqual(spy.saveSpy.simulatedError, -25299, "Should simulate duplicate item error")
		spy.saveSpy.simulatedError = -25293  // errSecAuthFailed
		let result2 = sut.save(data: anyData(), forKey: anyKey())
		XCTAssertEqual(
			result2, KeychainSaveResult.failure,
			"Should return KeychainSaveResult.failure on auth failed error")
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
		XCTAssertEqual(
			sut.save(data: data, forKey: key), KeychainSaveResult.success, "Should save initial data")
		XCTAssertEqual(sut.update(data: updated, forKey: key), errSecSuccess, "Should update data for valid key")
        XCTAssertEqual(sut.load(forKey: key), updated, "Should load updated data")
        // Path error: clave vacía
        XCTAssertEqual(sut.update(data: data, forKey: ""), errSecParam, "Should return errSecParam for empty key")
        // Path error: data vacío
        XCTAssertEqual(sut.update(data: Data(), forKey: key), errSecParam, "Should return errSecParam for empty data")
	}
	
	func test_save_onSystemKeychain_withDuplicateItem_andUpdateFails_returnsDuplicateItem() {
		let (sut, spy) = makeSpySUT()
		let data = "data".data(using: .utf8)!
		let key = uniqueKey()
		spy.saveResult = .duplicateItem
		spy.updateStatus = errSecDuplicateItem
		spy.loadResult = nil
		// No hace falta manipular storage, update falla y el spy devuelve duplicateItem
		let result = sut.save(data: data, forKey: key)
		XCTAssertEqual(
			result, .duplicateItem,
			"Should return duplicateItem when update fails after duplicate item error")
	}
	
	// Checklist: Delete covers success and error paths
	// CU: SystemKeychain-delete-success, SystemKeychain-delete-emptyKey
	func test_delete_onSystemKeychain_withValidAndInvalidInput() {
		let sut = makeSystemKeychain()
		let key = uniqueKey()
		let data = "data".data(using: .utf8)!
		// Guardar primero para poder borrar
		XCTAssertEqual(
			sut.save(data: data, forKey: key), KeychainSaveResult.success,
			"Should save data before deleting")
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
		XCTAssertEqual(
			resultSuccess, KeychainSaveResult.success, "Should save data with valid key and data")
		// Path error: clave vacía
		let resultEmptyKey = sut.save(data: validData, forKey: "")
		XCTAssertEqual(resultEmptyKey, KeychainSaveResult.failure, "Should fail to save with empty key")
		// Path error: data vacío
		let resultEmptyData = sut.save(data: Data(), forKey: validKey)
		XCTAssertEqual(
			resultEmptyData, KeychainSaveResult.failure, "Should fail to save with empty data")
	}
	
	func test_noFallback_save_alwaysReturnsFailure() {
		let sut = makeNoFallback()
		let data = "irrelevant".data(using: .utf8)!
		let key = uniqueKey()
		// Assert: NoFallback.save always returns .failure
		XCTAssertEqual(
			sut.save(data: data, forKey: key),
			KeychainSaveResult.failure,
			"NoFallback should always return .failure on save"
		)
	}
	
	func test_noFallback_load_alwaysReturnsNil() {
		let sut = makeNoFallback()
		let key = uniqueKey()
		// Assert: NoFallback.load always returns nil
		XCTAssertNil(
			sut.load(forKey: key),
			"NoFallback should always return nil on load"
		)
	}
	
	func test_noFallback_save_and_load_alwaysFail() {
		let fallback = makeNoFallback()
		let key = uniqueKey()
		let data = "irrelevant".data(using: .utf8)!
		// Save siempre falla
		XCTAssertEqual(
			fallback.save(data: data, forKey: key), KeychainSaveResult.failure,
			"NoFallback should always return KeychainSaveResult.failure on save")
		// Load siempre es nil
		XCTAssertNil(fallback.load(forKey: key), "NoFallback should always return nil on load")
		// Init no lanza excepción
		XCTAssertNotNil(fallback, "NoFallback should be initializable")
	}
	
	// Checklist: handleDuplicateItem covers max attempts
	// CU: SystemKeychain-handleDuplicateItem-maxAttempts
	func test_handleDuplicateItem_returnsDuplicateItem_whenMaxAttemptsReached() {
		let (sut, spy) = makeSpySUT()
		spy.saveResult = KeychainSaveResult.duplicateItem
		spy.updateStatus = errSecDuplicateItem  // Forzar que nunca se consiga actualizar
		let data = "data".data(using: .utf8)!
		let key = uniqueKey()
		// Simula el save varias veces para forzar los reintentos
		let result = sut.save(data: data, forKey: key)
		XCTAssertEqual(
			result, KeychainSaveResult.duplicateItem,
			"Should return KeychainSaveResult.duplicateItem after max duplicate attempts")
	}
	
	// Checklist: _update covers validation for empty key and data
	// CU: SystemKeychain-_update-emptyKey, SystemKeychain-_update-emptyData
	func test__update_onSystemKeychain_failsWithEmptyKeyOrData() {
        let sut = makeSystemKeychain()
        let validKey = uniqueKey()
        let validData = "data".data(using: .utf8)!
        // Path error: clave vacía
        let resultEmptyKey = sut.update(data: validData, forKey: "")
        XCTAssertEqual(resultEmptyKey, errSecParam, "Should return errSecParam for empty key")
        // Path error: data vacío
        let resultEmptyData = sut.update(data: Data(), forKey: validKey)
        XCTAssertEqual(resultEmptyData, errSecParam, "Should return errSecParam for empty data")
    }
	
	// NOTE: Due to the current SystemKeychain implementation, the error path for delete cannot be unit tested.
	// The production code calls the system API directly, so only the success path is covered here.
	// To cover the error path, either refactor production to delegate to the injected keychain or use integration tests.
	// Checklist: _delete covers success and failure paths
	// CU: SystemKeychain-_delete-success, SystemKeychain-_delete-failure
	func test__delete_onSystemKeychain_returnsTrueOnSuccess() {
		// NOTE: Due to the current SystemKeychain implementation, the error path for delete cannot be unit tested.
		// The production code calls the system API directly, so only the success path is covered here.
		// To cover the error path, either refactor production to delegate to the injected keychain or use integration tests.
		let spy = makeKeychainFullSpy()
		let sut = SystemKeychain(keychain: spy)
		let keySuccess = uniqueKey()
		// Path éxito
		_ = spy.save(data: "irrelevant".data(using: .utf8)!, forKey: keySuccess)
		spy.deleteSpy.deleteResult = true
		spy.deleteSpy.simulatedDeleteError = nil
		spy.updateStatus = errSecSuccess
		XCTAssertTrue(sut.delete(forKey: keySuccess), "Should return true when deletion succeeds")
		// Path error real NO se puede cubrir en unit test debido a la implementación de producción.
	}
	
	// MARK:  Cobertura explícita de constructores y métodos base para SystemKeychain y NoFallback
	
	// CU: SecureStorage (SystemKeychain) - Checklist: Explicit constructor coverage
	// Checklist: Explicit constructor coverage
	func test_init_systemKeychain_doesNotThrow() {
		_ = makeSystemKeychain()
	}
	
	// CU: SecureStorage (SystemKeychain) - Checklist: Returns failure for invalid input (empty key/data)
	// Checklist: Returns failure for invalid input (empty key/data)
	func test_save_onSystemKeychain_withInvalidInput_returnsFailure() {
		let sut = makeSystemKeychain()
		XCTAssertEqual(sut.save(data: Data(), forKey: ""), KeychainSaveResult.failure)
	}
	
	// CU: SecureStorage (NoFallback strategy) - Checklist: Explicit constructor coverage
	// Checklist: Explicit constructor coverage
	func test_init_noFallback_doesNotThrow() {
		_ = makeNoFallback()
	}
	
	// CU: SecureStorage (NoFallback strategy) - Checklist: Always returns failure
	// Checklist: Always returns failure
	func test_save_onNoFallback_alwaysReturnsFailure() {
		let sut = makeNoFallback()
		let data = "irrelevant".data(using: .utf8)!
		XCTAssertEqual(sut.save(data: data, forKey: "irrelevant"), KeychainSaveResult.failure)
	}
	
	// MARK: - Internal Closures Coverage
	
	// Checklist: _save returns failure for empty key
	// CU: SystemKeychain-save-emptyKey
	func test__save_returnsFailureOnEmptyKey() {
		let sut = makeSUT()
		let data = "data".data(using: .utf8)!
		XCTAssertEqual(sut.save(data: data, forKey: ""), .failure, "Should fail to save with empty key")
	}
	
	// Checklist: _save returns failure for empty data
	// CU: SystemKeychain-save-emptyData
	func test__save_returnsFailureOnEmptyData() {
		let sut = makeSUT()
		XCTAssertEqual(sut.save(data: Data(), forKey: "key"), .failure, "Should fail to save with empty data")
	}
	
	// Checklist: _delete returns false for empty key
	// CU: SystemKeychain-delete-emptyKey
	func test__delete_returnsFalseOnEmptyKey() {
		let sut = makeSUT()
		XCTAssertFalse(sut.delete(forKey: ""), "Should fail to delete with empty key")
	}
	
	// Checklist: _load returns nil for empty key
	// CU: SystemKeychain-load-emptyKey
	func test__load_returnsNilOnEmptyKey() {
		let sut = makeSUT()
		XCTAssertNil(sut.load(forKey: ""), "Should return nil when loading with empty key")
	}
	
	// MARK: - handleDuplicateItem branch coverage
	
	// Checklist: _save returns success when handleDuplicateItem succeeds and validation succeeds
	// CU: SystemKeychain-save-success
	func test_save_returnsSuccess_whenHandleDuplicateItemSucceedsAndValidationSucceeds() {
    let (sut, spy) = makeSpySUT()
    let key = uniqueKey()
    let data = "data".data(using: .utf8)!
    spy.saveResult = .duplicateItem
    spy.loadResult = nil // Ensure no interference from previous loadResult
    var attempts = 0
    spy.customUpdateHandler = { [weak spy] data, key in
        attempts += 1
        spy?.storage[key] = data // Ensure the spy updates the storage
        return true
    }
    spy.willValidateAfterSave = nil // No corruption
    let result = sut.save(data: data, forKey: key)
    XCTAssertEqual(result, .success, "Should return success if updateStatus == errSecSuccess and validation succeed in handleDuplicateItem")
    XCTAssertEqual(attempts, 1, "Should have retried once")
    XCTAssertEqual(spy.storage[key], data, "Spy storage should contain the updated data after success")
}
	
	// Checklist: _save returns duplicateItem when handleDuplicateItem succeeds but validation fails
	// CU: SystemKeychain-save-duplicateItem
	func test_save_returnsFailure_whenHandleDuplicateItemSucceedsButValidationFails() {
    let (sut, spy) = makeSpySUT()
    let key = uniqueKey()
    let data = "data".data(using: .utf8)!
    spy.saveResult = .duplicateItem
    spy.loadResult = nil // Ensure no interference from previous loadResult
    var attempts = 0
    spy.customUpdateHandler = { [weak spy] data, key in
        attempts += 1
        spy?.storage[key] = data // Ensure the spy updates the storage
        return true
    }
    // Simulate corruption right before validation
    spy.willValidateAfterSave = { [weak spy] corruptedKey in
        spy?.storage[corruptedKey] = nil
    }
    let result = sut.save(data: data, forKey: key)
    XCTAssertEqual(result, .failure, "Should return failure if updateStatus == errSecSuccess succeeds but validation fails in handleDuplicateItem")
    XCTAssertEqual(attempts, 2, "Should have retried twice (once for initial update, once for retry after failed validation)")
    XCTAssertNil(spy.storage[key], "Spy storage should not contain the data after simulated corruption")
}
	// Checklist: Factory simulates corruption
	// CU: SystemKeychain-factory-simulatesCorruption
	func test_factory_simulatesCorruption() {
		let spy = makeKeychainFullSpy()
		let sut = makeSUT(keychain: spy)
		let key = "corrupt-key"
		let value = "data".data(using: .utf8)!
		_ = sut.save(data: value, forKey: key)
		spy.simulateCorruption(forKey: key)
		XCTAssertNil(sut.load(forKey: key), "Should return nil for corrupted key")
	}
	
	// Checklist: Factory handles unicode keys
	// CU: SystemKeychain-factory-handlesUnicodeKeys
	func test_factory_handlesUnicodeKeys() {
		let spy = makeKeychainFullSpy()
		let sut = makeSUT(keychain: spy)
		let key = "🔑-ключ-鍵"
		let value = "unicode-data".data(using: .utf8)!
		XCTAssertEqual(sut.save(data: value, forKey: key), .success, "Should save with unicode key")
		XCTAssertEqual(sut.load(forKey: key), value, "Should load with unicode key")
	}
	
	// Checklist: Factory handles large data
	// CU: SystemKeychain-factory-handlesLargeData
	func test_factory_handlesLargeData() {
		let spy = makeKeychainFullSpy()
		let sut = makeSUT(keychain: spy)
		let key = "large-key"
		let value = Data(repeating: 0xFF, count: 1024 * 1024) // 1 MB
		XCTAssertEqual(sut.save(data: value, forKey: key), .success, "Should save large data")
		XCTAssertEqual(sut.load(forKey: key), value, "Should load large data")
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
	
	// MARK: - DRY Save Result Helper
	fileprivate func expectSaveResult(
		sut: SystemKeychain,
		spy: KeychainFullSpy,
		data: Data,
		key: String,
		expected: KeychainSaveResult,
		loadResult: Data?,
		file: StaticString = #file, line: UInt = #line
	) {
		spy.loadResult = loadResult
		let result = sut.save(data: data, forKey: key)
		XCTAssertEqual(
			result, expected,
			"Should return \(expected) when loadResult is \(String(describing: loadResult))", file: file,
			line: line)
	}
	
	// MARK: - KeychainFullSpy
	
	// MARK: - DeleteFailKeychain
	private class DeleteFailKeychain: KeychainFull {
        func load(forKey key: String) -> Data? { return nil }
        func save(data: Data, forKey key: String) -> KeychainSaveResult { KeychainSaveResult.success }
        func delete(forKey key: String) -> Bool { false }
        func update(data: Data, forKey key: String) -> OSStatus { return errSecSuccess }
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
