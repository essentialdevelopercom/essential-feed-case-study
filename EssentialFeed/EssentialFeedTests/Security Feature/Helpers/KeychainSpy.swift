// KeychainSpy.swift
// Spy para KeychainProtocol, ideal para tests unitarios y verificación de interacciones

import Foundation
import EssentialFeed

final class KeychainSpy: KeychainProtocolWithDelete {
    var simulatedError: Int?
    private(set) var saveCalled = false
    private(set) var saveCallCount = 0
    private(set) var lastData: Data?
    private(set) var lastKey: String?
    var saveResult: Bool = false

    // Nuevas propiedades para delete
    private(set) var deleteCalled = false
    private(set) var lastDeletedKey: String?
    var deleteResult: Bool = true

    func save(data: Data, forKey key: String) -> Bool {
        if let _ = simulatedError {
            return false
        }
        saveCalled = true
        saveCallCount += 1
        lastData = data
        lastKey = key
        return saveResult
    }

    func delete(forKey key: String) -> Bool {
        deleteCalled = true
        lastDeletedKey = key
        return deleteResult
    }
}
