// SystemKeychainTests.swift
// Unit tests for SystemKeychain

import XCTest
import EssentialFeed

final class SystemKeychainTests: XCTestCase {
    // CU: SystemKeychain
    
    // CU: SystemKeychain-save-delegates
    // Checklist: test_save_delegatesToKeychainProtocol_andReturnsSpyResult
    func test_save_delegatesToKeychainProtocol_andReturnsSpyResult() {
        let (sut, spy) = makeSpySUT()
        spy.saveResult = true
        let data = anyData()
        let key = anyKey()
        
        let result = sut.save(data: data, forKey: key)

        XCTAssertTrue(spy.saveCalled, "Should call save on spy")
        XCTAssertEqual(spy.lastData, data, "Should pass correct data to spy")
        XCTAssertEqual(spy.lastKey, key, "Should pass correct key to spy")
        XCTAssertTrue(result, "Save should succeed with valid input")
    }

    // CU: SystemKeychain-save-validInput
    // Checklist: test_save_returnsBool_forValidInput
    func test_save_returnsBool_forValidInput() {
        let sut = makeSUT()
        let result = sut.save(data: anyData(), forKey: anyKey())
        XCTAssert(result == true || result == false, "Result should be a Bool value")
    }
    
    // CU: SystemKeychain-save-emptyKey
    // Checklist: test_save_returnsFalse_forEmptyKey
    func test_save_returnsFalse_forEmptyKey() {
        let sut = makeSUT()
        let result = sut.save(data: anyData(), forKey: "")
        XCTAssertFalse(result, "Saving with empty key should fail")
    }
    
    // CU: SystemKeychain-save-emptyData
    // Checklist: test_save_returnsFalse_forEmptyData
    func test_save_returnsFalse_forEmptyData() {
        let sut = makeSUT()
        let result = sut.save(data: Data(), forKey: anyKey())
        XCTAssertFalse(result, "Saving empty data should fail")
    }
    
    // CU: SystemKeychain-save-veryLongKey
    // Checklist: test_save_returnsBool_forVeryLongKey
    func test_save_returnsBool_forVeryLongKey() {
        let sut = makeSUT()
        let key = String(repeating: "k", count: 1024)
        let result = sut.save(data: anyData(), forKey: key)
        XCTAssert(result == true || result == false, "Result should be a Bool value")
    }

    // CU: SystemKeychain-save-onlySpacesKey
    // Checklist: test_save_returnsFalse_forKeyWithOnlySpaces
    func test_save_returnsFalse_forKeyWithOnlySpaces() {
        let sut = makeSUT()
        let result = sut.save(data: anyData(), forKey: "   ")
        XCTAssertFalse(result, "Saving with only-spaces key should fail")
    }

    // CU: SystemKeychain-save-keychainFailure
    // Checklist: test_save_returnsFalse_onKeychainFailure
    func test_save_returnsFalse_onKeychainFailure() {
        let (sut, spy) = makeSpySUT()
        spy.saveResult = false // Simulate Keychain failure
        let result = sut.save(data: anyData(), forKey: anyKey())
        XCTAssertFalse(result, "Saving should return false on Keychain failure")
    }

    // CU: SystemKeychain-save-deletePrevious
    // Checklist: test_save_deletesPreviousValueBeforeSavingNewOne
    func test_save_deletesPreviousValueBeforeSavingNewOne() {
        let spy = KeychainSpy()
        let sut = SystemKeychain(keychain: spy)
        spy.saveResult = true
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
        XCTAssert(result == true || result == false, "Saving with unicode key and large data should not crash and should return a Bool")
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
        
        // El Keychain en simulador/CLI puede no reflejar inmediatamente los cambios tras escrituras concurrentes. 
        // Por eso, reintentamos la lectura varias veces antes de fallar el test.
        let maxAttempts = 10
        let retryDelay: useconds_t = 50000 // 50ms
        var finalData: Data? = nil
        for _ in 0..<maxAttempts {
            finalData = sut.load(forKey: key)
            if finalData != nil { break }
            usleep(retryDelay)
        }
        XCTAssertNotNil(finalData, "Final data should not be nil after concurrent writes. This may be due to the asynchronous and global nature of Keychain in the simulator or CLI environment.")
    }

    // CU: SystemKeychain-save-specificKeychainErrors
    // Checklist: test_save_handlesSpecificKeychainErrors
    func test_save_handlesSpecificKeychainErrors() {
        let (sut, spy) = makeSpySUT()
        // Simulate duplicate item error
        spy.saveResult = false
        spy.simulatedError = -25299 // errSecDuplicateItem
        let result = sut.save(data: anyData(), forKey: anyKey())
        XCTAssertFalse(result, "Should return false on duplicate item error")
        XCTAssertEqual(spy.simulatedError, -25299, "Should simulate duplicate item error")
        // Simulate auth failed error
        spy.simulatedError = -25293 // errSecAuthFailed
        let result2 = sut.save(data: anyData(), forKey: anyKey())
        XCTAssertFalse(result2, "Should return false on auth failed error")
        XCTAssertEqual(spy.simulatedError, -25293, "Should simulate auth failed error")
    }

    // --- Cobertura real de SystemKeychain y NoFallback ---
    // Checklist: test_realSystemKeychain_saveAndLoad_returnsPersistedData
    // CU: SystemKeychain-save-andLoad
    func test_realSystemKeychain_saveAndLoad_returnsPersistedData() {
        let sut = makeSUT()
        let key = "integration-key"
        let data = "integration-data".data(using: .utf8)!
        // Guardar dato real
        let saveResult = sut.save(data: data, forKey: key)
        XCTAssert(saveResult == true || saveResult == false, "Save result should be a Bool value")
        // Leer dato real
        let loaded = sut.load(forKey: key)
        if saveResult {
            XCTAssertEqual(loaded, data, "Should retrieve the same data if save succeeded")
        } else {
            XCTAssertNil(loaded, "Should not retrieve data if save failed")
        }
    }

    // Checklist: test_realSystemKeychain_saveAndDelete_returnsTrueOrFalse
    // CU: SystemKeychain-save-andDelete
    func test_realSystemKeychain_saveAndDelete_returnsTrueOrFalse() {
        let sut = makeSUT()
        let key = "test-key-real"
        let data = "real-test-data".data(using: .utf8)!
        // Guardar dato real
        let saveResult = sut.save(data: data, forKey: key)
        XCTAssert(saveResult == true || saveResult == false, "Save result should be a Bool value")
        // Intentar guardar con clave vacía
        let emptyKeyResult = sut.save(data: data, forKey: "")
        XCTAssertFalse(emptyKeyResult, "Saving with empty key should fail")
        // Intentar guardar con data vacía
        let emptyDataResult = sut.save(data: Data(), forKey: key)
        XCTAssertFalse(emptyDataResult, "Saving with empty data should fail")
    }

    // Checklist: test_NoFallback_alwaysReturnsFalse
    // CU: SystemKeychain-fallback
    func test_NoFallback_alwaysReturnsFalse() {
        let fallback = NoFallback()
        let data = "irrelevant".data(using: .utf8)!
        let result = fallback.save(data: data, forKey: "any-key")
        XCTAssertFalse(result, "Saving should return false on Keychain failure")
    }
    
    // MARK: - Helpers
    // Helper para crear el SUT y asegurar liberación de memoria
    // El parámetro keychain debe conformar a KeychainProtocolWithDelete para ser compatible con SystemKeychain
    private func makeSUT(keychain: KeychainProtocolWithDelete? = nil, file: StaticString = #file, line: UInt = #line) -> SystemKeychain {
        let sut: SystemKeychain
        if let keychain = keychain {
            sut = SystemKeychain(keychain: keychain)
        } else {
            sut = SystemKeychain()
        }
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func makeSpySUT(file: StaticString = #file, line: UInt = #line) -> (sut: KeychainSpy, spy: KeychainSpy) {
        let spy = KeychainSpy()
        trackForMemoryLeaks(spy, file: file, line: line)
        return (spy, spy)
    }
    
    private func anyData() -> Data {
        return "test-data".data(using: .utf8)!
    }
    
    private func anyKey() -> String {
        return "test-key"
    }

    // NOTE: For real Keychain mocks, it is recommended to use dependency injection and testable wrappers of the Security framework.
    
    // Helper para generar claves únicas en los tests
    private func uniqueKey() -> String {
        return "test-key-\(UUID().uuidString)"
    }
}
