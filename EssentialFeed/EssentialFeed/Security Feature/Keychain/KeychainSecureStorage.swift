import Foundation

public final class KeychainSecureStorage {
    private let keychain: KeychainProtocol

    public init(keychain: KeychainProtocol) {
        self.keychain = keychain
    }

    public func save(data: Data, forKey key: String) -> Bool {
        return keychain.save(data: data, forKey: key)
    }
}


