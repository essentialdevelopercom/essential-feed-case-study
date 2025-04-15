import Foundation

public final class KeychainSecureStorage {
  private let keychain: KeychainProtocol
  private let fallback: KeychainProtocol

  public init(keychain: KeychainProtocol, fallback: KeychainProtocol = NoFallback()) {
    self.keychain = keychain
    self.fallback = fallback
  }

  public func save(data: Data, forKey key: String) -> Bool {
    if keychain.save(data: data, forKey: key) {
      return true
    } else {
      return fallback.save(data: data, forKey: key)
    }
  }
}

public final class NoFallback: KeychainProtocol {
  public init() {}
  public func save(data: Data, forKey key: String) -> Bool { return false }
}