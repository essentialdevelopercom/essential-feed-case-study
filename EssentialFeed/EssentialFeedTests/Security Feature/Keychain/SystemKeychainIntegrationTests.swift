// CU: Seguridad de almacenamiento en Keychain
// Checklist: Validar operaciones seguras en Keychain

import EssentialFeed
import XCTest

final class SystemKeychainIntegrationTests: XCTestCase {
  // MARK: - Integration Test: Real Keychain

  // CU: Save, Load, Delete
  // Checklist:
  func test_save_load_delete_withSystemKeychain() {
    let testKey = uniqueTestKey()
    let testData = uniqueTestData()
    let sut = makeSystemKeychainSUT(testKey: testKey)
    // Save
    XCTAssertEqual(
      sut.save(data: testData, forKey: testKey), .success, "Should save data in real Keychain")
    // Load
    let loaded = sut.load(forKey: testKey)
    XCTAssertEqual(loaded, testData, "Should load the same data from real Keychain")
    // Delete
    XCTAssertTrue(sut.delete(forKey: testKey), "Should delete key from real Keychain")
    XCTAssertNil(sut.load(forKey: testKey), "Should not load deleted key from real Keychain")
  }

  // MARK: - Error Handling
  // Checklist:
  func test_save_fails_withEmptyKey() {
    let testKey = uniqueTestKey()
    let testData = uniqueTestData()
    let sut = makeSystemKeychainSUT(testKey: testKey)
    let result = sut.save(data: testData, forKey: "")
    XCTAssertEqual(result, .failure, "Should return failure when saving with empty key")
  }

  func test_save_fails_withEmptyData() {
    let testKey = uniqueTestKey()
    let sut = makeSystemKeychainSUT(testKey: testKey)
    let result = sut.save(data: Data(), forKey: testKey)
    XCTAssertEqual(result, .failure, "Should return failure when saving empty data")
  }

  func test_load_returnsNil_forNonExistentKey() {
    let sut = makeSystemKeychainSUT(testKey: "non-existent-key")
    XCTAssertNil(sut.load(forKey: "non-existent-key"), "Should return nil for non-existent key")
  }

  func test_dataPersistsBetweenSaves() {
    let testKey = uniqueTestKey()
    let testData = uniqueTestData()
    let sut = makeSystemKeychainSUT(testKey: testKey)
    XCTAssertEqual(
      sut.save(data: testData, forKey: testKey), .success, "Should save data in real Keychain")
    let loaded = sut.load(forKey: testKey)
    XCTAssertEqual(loaded, testData, "Should persist and load data between saves")
  }

  // MARK: - Helpers

  // Centralized factory/helper for SUT and test key/data
  func makeSystemKeychainSUT(testKey: String) -> SystemKeychain {
    let sut = SystemKeychain()
    _ = sut.delete(forKey: testKey)  // Ensure clean state before test
    return sut
  }

  func uniqueTestKey() -> String {
    return "integration-test-key-\(UUID().uuidString)"
  }

  func uniqueTestData() -> Data {
    return "integration-data-\(UUID().uuidString)".data(using: .utf8)!
  }

}
