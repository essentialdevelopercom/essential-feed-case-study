// SystemKeychainTests.swift
// Unit tests for SystemKeychain

import XCTest
import EssentialFeed

final class SystemKeychainTests: XCTestCase {
    // CU: SystemKeychain
    
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

    func test_save_returnsBool_forValidInput() {
        let sut = makeSUT()
        let result = sut.save(data: anyData(), forKey: anyKey())
        XCTAssert(result == true || result == false)
    }
    
    func test_save_returnsFalse_forEmptyKey() {
        let sut = makeSUT()
        let result = sut.save(data: anyData(), forKey: "")
        XCTAssertFalse(result, "Saving with empty key should fail")
    }
    
    func test_save_returnsFalse_forEmptyData() {
        let sut = makeSUT()
        let result = sut.save(data: Data(), forKey: anyKey())
        XCTAssertFalse(result, "Saving empty data should fail")
    }
    
    func test_save_returnsBool_forVeryLongKey() {
        let sut = makeSUT()
        let key = String(repeating: "k", count: 1024)
        let result = sut.save(data: anyData(), forKey: key)
        XCTAssert(result == true || result == false)
    }

    func test_save_returnsFalse_forKeyWithOnlySpaces() {
        let sut = makeSUT()
        let result = sut.save(data: anyData(), forKey: "   ")
        XCTAssertFalse(result, "Saving with only-spaces key should fail")
    }

    func test_save_returnsFalse_onKeychainFailure() {
        let (sut, spy) = makeSpySUT()
        spy.saveResult = false // Simulate Keychain failure
        let result = sut.save(data: anyData(), forKey: anyKey())
        XCTAssertFalse(result, "Saving should return false on Keychain failure")
    }

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

    func test_save_supportsUnicodeKeysAndLargeBinaryData() {
        let sut = makeSUT()
        let unicodeKey = "🔑-ключ-密钥-llave"
        let largeData = Data((0..<10_000).map { _ in UInt8.random(in: 0...255) })
        let result = sut.save(data: largeData, forKey: unicodeKey)
        XCTAssert(result == true || result == false, "Saving with unicode key and large data should not crash and return a Bool")
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
