// KeychainSpy.swift
// Spy para KeychainProtocol, ideal para tests unitarios y verificación de interacciones

import Foundation
import EssentialFeed

final class KeychainSpy: KeychainProtocol {
    private(set) var saveCalled = false
    private(set) var saveCallCount = 0
    private(set) var lastData: Data?
    private(set) var lastKey: String?
    var saveResult: Bool = false

    func save(data: Data, forKey key: String) -> Bool {
        saveCalled = true
        saveCallCount += 1
        lastData = data
        lastKey = key
        return saveResult
    }
}
