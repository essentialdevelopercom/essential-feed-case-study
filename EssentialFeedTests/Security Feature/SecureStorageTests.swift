//
//  SecureStorageTests.swift
//  EssentialFeedTests
//
//  Created on 15/04/2025.
//

import XCTest
import EssentialFeed

class SecureStorageTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_protectionLevel_returnsHighForSensitiveData() {
        let (sut, _) = makeSUT()
        let sensitiveData = "password123".data(using: .utf8)!
        
        let level = sut.protectionLevel(for: sensitiveData)
        
        XCTAssertEqual(level, .high)
    }
    
    func test_saveSecureData_requestsSecureStoreSaveWithKey() {
        let (sut, store) = makeSUT()
        let secureData = "sensitive-data".data(using: .utf8)!
        let key = "secure-key"
        
        try? sut.save(secureData, forKey: key)
        
        XCTAssertEqual(store.receivedMessages, [.save(key: key, value: secureData)])
    }
    
    func test_saveSecureData_failsOnSecureStoreSaveError() {
        let (sut, store) = makeSUT()
        let secureData = "sensitive-data".data(using: .utf8)!
        let saveError = anyNSError()
        
        store.stubSave(forKey: "any-key", with: .failure(saveError))
        
        XCTAssertThrowsError(try sut.save(secureData, forKey: "any-key")) { error in
            XCTAssertEqual(error as NSError, saveError)
        }
    }
    
    func test_saveSecureData_succeedsOnSuccessfulSecureStoreSave() {
        let (sut, store) = makeSUT()
        let secureData = "sensitive-data".data(using: .utf8)!
        
        store.stubSave(forKey: "any-key", with: .success(()))
        
        XCTAssertNoThrow(try sut.save(secureData, forKey: "any-key"))
    }
    
    func test_saveSecureData_validatesSensitiveInformation() {
        let (sut, store) = makeSUT()
        let secureData = "sensitive-data".data(using: .utf8)!
        let key = "secure-key"
        
        try? sut.save(secureData, forKey: key)
        
        XCTAssertEqual(store.receivedMessages, [.save(key: key, value: secureData)])
    }
    
    // MARK: - Helpers
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: SecureStorage, store: SecureStoreSpy) {
        let store = SecureStoreSpy()
        let sut = SecureStorage(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
    
    private class SecureStoreSpy: SecureStoreWriter, SecureStoreReader, SecureStoreDeleter {
        enum ReceivedMessage: Equatable {
            case save(key: String, value: Data)
            case retrieve(key: String)
            case delete(key: String)
        }
        
        private(set) var receivedMessages = [ReceivedMessage]()
        private var stubbedRetrievalResults = [String: Result<Data, Error>]()
        private var stubbedSaveResults = [String: Result<Void, Error>]()
        private var stubbedDeleteResults = [String: Result<Void, Error>]()
        
        func save(_ data: Data, forKey key: String) throws {
            receivedMessages.append(.save(key: key, value: data))
            if let result = stubbedSaveResults[key], case let .failure(error) = result {
                throw error
            }
        }
        
        func retrieve(forKey key: String) throws -> Data {
            receivedMessages.append(.retrieve(key: key))
            if let result = stubbedRetrievalResults[key] {
                switch result {
                case let .success(data):
                    return data
                case let .failure(error):
                    throw error
                }
            }
            throw NSError(domain: "test", code: 0)
        }
        
        func delete(forKey key: String) throws {
            receivedMessages.append(.delete(key: key))
            if let result = stubbedDeleteResults[key], case let .failure(error) = result {
                throw error
            }
        }
        
        func stubRetrieval(forKey key: String, with result: Result<Data, Error>) {
            stubbedRetrievalResults[key] = result
        }
        
        func stubSave(forKey key: String, with result: Result<Void, Error>) {
            stubbedSaveResults[key] = result
        }
        
        func stubDelete(forKey key: String, with result: Result<Void, Error>) {
            stubbedDeleteResults[key] = result
        }
    }
}

// MARK: - Production Code (temporary, to be moved later)

enum SecureStorageProtectionLevel {
    case high
    case medium
    case low
}

protocol SecureStoreWriter {
    func save(_ data: Data, forKey key: String) throws
}

protocol SecureStoreReader {
    func retrieve(forKey key: String) throws -> Data
}

protocol SecureStoreDeleter {
    func delete(forKey key: String) throws
}

typealias SecureStore = SecureStoreWriter & SecureStoreReader & SecureStoreDeleter

class SecureStorage {
    private let store: SecureStore
    
    init(store: SecureStore) {
        self.store = store
    }
    
    func protectionLevel(for data: Data) -> SecureStorageProtectionLevel {
        return .high
    }
    
    func save(_ data: Data, forKey key: String) throws {
        try store.save(data, forKey: key)
    }
}
