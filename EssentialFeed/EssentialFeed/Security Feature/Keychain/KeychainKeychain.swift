import Foundation
import Security

public protocol KeychainProtocol {
    func save(data: Data, forKey key: String) -> Bool
}

public final class KeychainKeychain: KeychainProtocol {
    public init() {}
    
    public func save(data: Data, forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary) // Remove old item if exists
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
}
