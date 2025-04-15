import Foundation
import EssentialFeed

public struct User {
    public let name: String
    public let email: String
    public init(name: String, email: String) {
        self.name = name
        self.email = email
    }
}

public struct KeychainSpy: KeychainProtocol {
    public init() {}
    public func save(data: Data, forKey key: String) -> Bool { false }
}

public protocol RegistrationValidatorProtocol {
    func validate(name: String, email: String, password: String) -> Bool
}

public struct RegistrationValidatorStub: RegistrationValidatorProtocol {
    public init() {}
    public func validate(name: String, email: String, password: String) -> Bool { true }
}

public enum UserRegistrationResult {
    case success(User)
    case failure(Error)
}

public actor UserRegistrationUseCase {
    private let keychain: KeychainProtocol
    private let validator: RegistrationValidatorProtocol
    
    public init(keychain: KeychainProtocol, validator: RegistrationValidatorProtocol) {
        self.keychain = keychain
        self.validator = validator
    }
    
    public func register(name: String, email: String, password: String) async throws -> UserRegistrationResult {
        guard validator.validate(name: name, email: email, password: password) else {
            struct RegistrationError: Error {}
            return .failure(RegistrationError())
        }
        // Persistencia segura de credenciales
        _ = keychain.save(data: password.data(using: .utf8)!, forKey: email)
        let user = User(name: name, email: email)
        return .success(user)
    }
}
