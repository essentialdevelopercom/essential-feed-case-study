// KeychainProtocol.swift
// Contratos base Keychain para dominio y test doubles

import Foundation

public enum KeychainSaveResult: Equatable {
    case success
    case failure
    case duplicateItem
}

public protocol KeychainSavable {
    func save(data: Data, forKey key: String) -> KeychainSaveResult
    func load(forKey key: String) -> Data?
}

public protocol KeychainDeletable {
    func delete(forKey key: String) -> Bool
}

public protocol KeychainUpdatable {
    func update(data: Data, forKey key: String) -> Bool
}

public typealias KeychainFull = KeychainSavable & KeychainDeletable & KeychainUpdatable


