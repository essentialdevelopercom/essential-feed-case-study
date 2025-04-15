import Foundation

public protocol KeychainProtocol {
    func save(data: Data, forKey key: String) -> Bool
}
