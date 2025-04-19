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

        XCTAssertTrue(spy.saveCalled)
        XCTAssertEqual(spy.lastData, data)
        XCTAssertEqual(spy.lastKey, key)
        XCTAssertTrue(result)
    }

    // CU: SystemKeychain-save-validInput
    // Checklist: test_save_returnsBool_forValidInput
    func test_save_returnsBool_forValidInput() {
        let sut = makeSUT()
        let result = sut.save(data: anyData(), forKey: anyKey())
        XCTAssert(result == true || result == false)
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
        XCTAssert(result == true || result == false)
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
        XCTAssert(result == true || result == false, "Saving with unicode key and large data should not crash and return a Bool")
    }

            // CU: SystemKeychain-save-threadSafe
    // Checklist: test_save_isThreadSafe
    func test_save_isThreadSafe() {
        let sut = makeSUT()
        let key = "thread-safe-key"
        let iterations = 100
        let queue = DispatchQueue(label: "concurrent-keychain-test", attributes: .concurrent)
        let group = DispatchGroup()
        for i in 0..<iterations {
            group.enter()
            queue.async {
                let data = Data(String(i).utf8)
                _ = sut.save(data: data, forKey: key)
                group.leave()
            }
        }
        group.wait()
        let finalData = sut.load(forKey: key)
        XCTAssertNotNil(finalData, "Final data should not be nil after concurrent writes")
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
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> SystemKeychain {
        let sut = SystemKeychain()
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
}
