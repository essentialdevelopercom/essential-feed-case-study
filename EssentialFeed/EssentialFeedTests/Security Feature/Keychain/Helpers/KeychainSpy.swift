// KeychainSpy.swift
// Helpers para test unitario e integración de Keychain

import Foundation
import EssentialFeed

// MARK: - KeychainSaveSpy
public final class KeychainSaveSpy: KeychainSavable {
	public var receivedKey: String?
	public var receivedData: Data?
	public var saveResult: KeychainSaveResult = .success
	public var saveCalled = false
	public var saveCallCount = 0
	public var lastData: Data?
	public var lastKey: String?
	public var simulatedError: Int?
	
	public init() {}
	
	public func save(data: Data, forKey key: String) -> KeychainSaveResult {
		if let _ = simulatedError {
			return .failure
		}
		saveCalled = true
		saveCallCount += 1
		lastData = data
		lastKey = key
		receivedKey = key
		receivedData = data
		return saveResult
	}
	
	public func load(forKey key: String) -> Data? {
		return receivedKey == key ? receivedData : nil
	}
}

// MARK: - KeychainDeleteSpy
public final class KeychainDeleteSpy: KeychainSavable, KeychainDeletable {
    public var deleteCalled = false
    public var lastDeletedKey: String?
    public var deleteResult: Bool = true

    public init() {}

    public func delete(forKey key: String) -> Bool {
        deleteCalled = true
        lastDeletedKey = key
        return deleteResult
    }

    // Dummy implementations for KeychainSavable
    public func save(data: Data, forKey key: String) -> KeychainSaveResult { .success }
    public func load(forKey key: String) -> Data? { nil }
}

// MARK: - KeychainUpdateSpy
public final class KeychainUpdateSpy: KeychainSavable, KeychainUpdatable {
    public var updateCalled = false
    public var lastUpdatedKey: String?
    public var lastUpdatedData: Data?
    public var updateResult: Bool = true

    public init() {}

    public func update(data: Data, forKey key: String) -> Bool {
        updateCalled = true
        lastUpdatedKey = key
        lastUpdatedData = data
        return updateResult
    }

    // Dummy implementations for KeychainSavable
    public func save(data: Data, forKey key: String) -> KeychainSaveResult { .success }
    public func load(forKey key: String) -> Data? { nil }
}

// MARK: - KeychainSpyAux

// MARK: - Helper Factory (Global)
/// Global factory for KeychainFullSpy to be used in all tests (DRY, Clean Code)
func makeKeychainFullSpy() -> KeychainFullSpy {
    return KeychainFullSpy()
}

public protocol KeychainSpyAux {
    var saveResult: KeychainSaveResult { get set }
    var updateResult: Bool { get set }
}

// MARK: - KeychainFullSpy
public final class KeychainFullSpy: KeychainFull, KeychainSpyAux {
    // MARK: - Update Spy forwarding
    public var updateCalled: Bool {
        get { updateSpy.updateCalled }
        set { updateSpy.updateCalled = newValue }
    }
    public var lastUpdatedData: Data? {
        get { updateSpy.lastUpdatedData }
        set { updateSpy.lastUpdatedData = newValue }
    }
    public var lastUpdatedKey: String? {
        get { updateSpy.lastUpdatedKey }
        set { updateSpy.lastUpdatedKey = newValue }
    }
    // MARK: - Delete Spy forwarding
    public var deleteCalled: Bool {
        get { deleteSpy.deleteCalled }
        set { deleteSpy.deleteCalled = newValue }
    }
    public var lastDeletedKey: String? {
        get { deleteSpy.lastDeletedKey }
        set { deleteSpy.lastDeletedKey = newValue }
    }

    private var storage: [String: Data] = [:]
    private let storageLock = NSLock()
    private var errorByKey: [String: Int] = [:]
    public var deleteSpy = KeychainDeleteSpy()
    public var saveSpy = KeychainSaveSpy()
    public var updateSpy = KeychainUpdateSpy()

    public init() {}

    public var saveResult: KeychainSaveResult {
        get { saveSpy.saveResult }
        set { saveSpy.saveResult = newValue }
    }
    public var updateResult: Bool {
        get { updateSpy.updateResult }
        set { updateSpy.updateResult = newValue }
    }

    /// Closure hook para permitir manipulación antes de la validación post-save (solo para tests, inyectable)
    public var willValidateAfterSave: ((String) -> Void)?

    public func save(data: Data, forKey key: String) -> KeychainSaveResult {
        if !delete(forKey: key) {
            return .failure
        }
        storageLock.lock()
        defer { storageLock.unlock() }
        let result = saveSpy.save(data: data, forKey: key)
        switch result {
        case .success:
            storage[key] = data
            var stillThere = storage[key]
            storageLock.unlock()
            willValidateAfterSave?(key)
            storageLock.lock()
            stillThere = storage[key]
            return stillThere == nil ? .failure : .success
        case .duplicateItem:
            let didUpdate = update(data: data, forKey: key)
            if didUpdate {
                storage[key] = data
                let stillThere = storage[key]
                storageLock.unlock()
                willValidateAfterSave?(key)
                storageLock.lock()
                return stillThere == nil ? .failure : .success
            } else {
                // No modificar ni validar storage si update falla
                return .duplicateItem
            }
        case .failure:
            return .failure
        }
    }
    public func load(forKey key: String) -> Data? {
        storageLock.lock()
        let data = storage[key]
        storageLock.unlock()
        return data
    }
    public func delete(forKey key: String) -> Bool {
        let deleted = deleteSpy.delete(forKey: key)
        if deleted {
            storageLock.lock()
            storage.removeValue(forKey: key)
            storageLock.unlock()
        }
        return deleted
    }
    public func update(data: Data, forKey key: String) -> Bool {
        return updateSpy.update(data: data, forKey: key)
    }

    /// Permite a los tests simular corrupción del almacenamiento de forma segura
    public func simulateCorruption(forKey key: String) {
        storageLock.lock()
        storage[key] = nil
        storageLock.unlock()
    }
}
