// MARK: - Test Helpers

import EssentialFeed
import Foundation

public class RecordingKeychainFullSpy: KeychainSavable {
    public func load(forKey key: String) -> Data? {
        return savedCredentials.first(where: { $0.key == key })?.data
    }
    struct SavedCredential: Equatable {
        let data: Data
        let key: String
    }
    private(set) var savedCredentials: [SavedCredential] = []

    public func save(data: Data, forKey key: String) -> KeychainSaveResult {
        savedCredentials.append(.init(data: data, key: key))
        return .success
    }
}

