import Foundation
import Security

// MARK: - SystemKeychain

/// Implementación del Keychain usando las APIs del sistema
public final class SystemKeychain: KeychainProtocol {
    private let keychain: KeychainProtocolWithDelete?
    private let queue = DispatchQueue(label: "SystemKeychain.SerialQueue")
    private static let queueKey = DispatchSpecificKey<Void>()
    
    public init(keychain: KeychainProtocolWithDelete? = nil) {
        self.keychain = keychain
        queue.setSpecific(key: SystemKeychain.queueKey, value: ())
    }
    
    /// Guarda datos en el Keychain con reintentos y validación posterior.
    /// Añade robustez ante condiciones de carrera y latencias del sistema.
    public func save(data: Data, forKey key: String) -> Bool {
        return queue.sync {
            guard !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !data.isEmpty else { return false }
            if let keychain = keychain {
                _ = keychain.delete(forKey: key)
                return keychain.save(data: data, forKey: key)
            } else {
                let maxAttempts = 5
                let delay: useconds_t = 20000 // 20ms entre reintentos

                var attempts = 0
                while attempts < maxAttempts {
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

                    if status == errSecSuccess {
                        // Validar que el dato guardado es el esperado
                        if let loaded = self.load(forKey: key), loaded == data {
                            return true
                        }
                    } else if status == errSecDuplicateItem {
                        // Fallback: update existing item
                        let attributesToUpdate: [String: Any] = [
                            kSecValueData as String: data
                        ]
                        let updateStatus = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
                        if updateStatus == errSecSuccess {
                            if let loaded = self.load(forKey: key), loaded == data {
                                return true
                            }
                        }

                    }
                    // Esperar antes de reintentar
                    usleep(delay)
                    attempts += 1
                }
                return false
            }
        }
    }

    public func load(forKey key: String) -> Data? {
        if DispatchQueue.getSpecific(key: SystemKeychain.queueKey) != nil {
            // Ya estamos en la cola serial, ejecuta directamente
            guard !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]
            var dataTypeRef: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
            if status == errSecSuccess {
                return dataTypeRef as? Data
            }
            return nil
        } else {
            return queue.sync {
                guard !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
                let query: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrAccount as String: key,
                    kSecReturnData as String: true,
                    kSecMatchLimit as String: kSecMatchLimitOne
                ]
                var dataTypeRef: AnyObject?
                let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
                if status == errSecSuccess {
                    return dataTypeRef as? Data
                }
                return nil
            }
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
