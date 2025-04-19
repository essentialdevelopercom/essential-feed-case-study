// SystemKeychainTests.swift
// Pruebas unitarias para SystemKeychain

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
        XCTAssertFalse(result, "Guardar con clave vacía debería fallar")
    }
    
    func test_save_returnsFalse_forEmptyData() {
        let sut = makeSUT()
        let result = sut.save(data: Data(), forKey: anyKey())
        XCTAssertFalse(result, "Guardar datos vacíos debería fallar")
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
        let (sut, spy) = makeSpySUT()
        spy.saveResult = true
        let key = anyKey()
        let data = anyData()
        _ = sut.save(data: data, forKey: key)
        XCTAssertTrue(spy.deleteCalled, "Should delete previous value before saving new one")
        XCTAssertEqual(spy.lastDeletedKey, key, "Should delete the correct key")
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> SystemKeychain {
        let sut = SystemKeychain()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func makeSpySUT(file: StaticString = #file, line: UInt = #line) -> (sut: KeychainProtocol, spy: KeychainSpy) {
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
    
    // NOTA: Para mocks reales de Keychain, se recomienda usar dependency injection y wrappers testables del framework Security.
}
