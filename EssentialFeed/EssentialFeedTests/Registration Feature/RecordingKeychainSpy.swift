// MARK: - Test Helpers

import EssentialFeed
import Foundation

public class RecordingKeychainSpy: KeychainProtocol {
    struct SavedCredential: Equatable {
        let data: Data
        let key: String
    }
    private(set) var savedCredentials: [SavedCredential] = []

	public func save(data: Data, forKey key: String) -> Bool {
        savedCredentials.append(.init(data: data, key: key))
        return true
    }
}
