import Foundation
import EssentialFeed

public protocol KeychainProtocolWithDelete: KeychainProtocol {
    func delete(forKey key: String) -> Bool
}
