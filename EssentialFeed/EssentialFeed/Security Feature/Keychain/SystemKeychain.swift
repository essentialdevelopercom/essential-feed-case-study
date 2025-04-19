import Foundation
import Security
import EssentialFeed

// MARK: - SystemKeychain

/// Implementación del Keychain usando las APIs del sistema
public final class SystemKeychain: KeychainProtocol {
    private let keychain: KeychainProtocolWithDelete?
    
    public init(keychain: KeychainProtocolWithDelete? = nil) {
        self.keychain = keychain
    }
    
    public func save(data: Data, forKey key: String) -> Bool {
        guard !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !data.isEmpty else { return false }
        if let keychain = keychain {
            _ = keychain.delete(forKey: key)
            return keychain.save(data: data, forKey: key)
        } else {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key
            ]
            SecItemDelete(query as CFDictionary)
            let queryWithData: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: data
            ]
            let status = SecItemAdd(queryWithData as CFDictionary, nil)
            return status == errSecSuccess
        }
    }
}

// MARK: - NoFallback

/// Implementación que siempre falla, utilizada como fallback por defecto
public final class NoFallback: KeychainProtocol {
    public init() {}
    public func save(data: Data, forKey key: String) -> Bool { return false }
}

// MARK: - KeychainSecureStorage

/// Clase que gestiona el almacenamiento seguro con múltiples estrategias de fallback
public final class KeychainSecureStorage {
    private let keychain: KeychainProtocol
    private let fallback: KeychainProtocol
    private let alternative: KeychainProtocol

    public init(keychain: KeychainProtocol, fallback: KeychainProtocol = NoFallback(), alternative: KeychainProtocol = NoFallback()) {
        self.keychain = keychain
        self.fallback = fallback
        self.alternative = alternative
    }

    public func save(data: Data, forKey key: String) -> Bool {
        if keychain.save(data: data, forKey: key) {
            return true
        } else if fallback.save(data: data, forKey: key) {
            return true
        } else {
            return alternative.save(data: data, forKey: key)
        }
    }
}
