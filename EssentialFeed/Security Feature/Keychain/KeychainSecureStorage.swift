//
// Copyright © 2025 Essential Developer. All rights reserved.
//

import Foundation

// MARK: - KeychainSecureStorage

/// Clase que gestiona el almacenamiento seguro con múltiples estrategias de fallback
public final class KeychainSecureStorage {
	private let keychain: KeychainSavable
	private let fallback: KeychainSavable
	private let alternative: KeychainSavable
	
	public init(keychain: KeychainSavable, fallback: KeychainSavable = NoFallback(), alternative: KeychainSavable = NoFallback()) {
		self.keychain = keychain
		self.fallback = fallback
		self.alternative = alternative
	}
	
	public func save(data: Data, forKey key: String) -> KeychainSaveResult {
		let result = keychain.save(data: data, forKey: key)
		if result == .success {
			return .success
		} else if fallback.save(data: data, forKey: key) == .success {
			return .success
		} else if alternative.save(data: data, forKey: key) == .success {
			return .success
		} else {
			return .failure
		}
	}
	
	public func load(forKey key: String) -> Data? {
		if let data = keychain.load(forKey: key) {
			return data
		}
		if let data = fallback.load(forKey: key) {
			return data
		}
		if let data = alternative.load(forKey: key) {
			return data
		}
		return nil
	}
}
