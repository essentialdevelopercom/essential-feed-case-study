import Foundation

public struct User {
    public let name: String
    public let email: String
    
    public init(name: String, email: String) {
        self.name = name
        self.email = email
    }
}

public struct UserRegistrationData: Codable {
    let name: String
    let email: String
    let password: String
}

public enum RegistrationValidationError: Error, Equatable {
    case emptyName
    case invalidEmail
    case weakPassword
}

public protocol RegistrationValidatorProtocol {
    func validate(name: String, email: String, password: String) -> RegistrationValidationError?
}

public struct RegistrationValidatorStub: RegistrationValidatorProtocol {
    public init() {}
    
    public func validate(name: String, email: String, password: String) -> RegistrationValidationError? {
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            return .emptyName
        }
        if !email.contains("@") || !email.contains(".") {
            return .invalidEmail
        }
        if password.count < 8 {
            return .weakPassword
        }
        return nil
    }
}

public enum UserRegistrationError: Error, Equatable {
    case emailAlreadyInUse
}

public enum UserRegistrationResult {
    case success(User)
    case failure(Error)
}

public enum NetworkError: Error, Equatable {
    case invalidResponse
    case clientError(statusCode: Int)
    case serverError(statusCode: Int)
    case unknown
    case noConnectivity
}

public protocol UserRegistrationNotifier {
    func notifyEmailAlreadyInUse()
}

public actor UserRegistrationUseCase {
    private let keychain: KeychainProtocol
    private let validator: RegistrationValidatorProtocol
    private let httpClient: HTTPClient
    private let registrationEndpoint: URL
    private let notifier: UserRegistrationNotifier?

    public init(keychain: KeychainProtocol, validator: RegistrationValidatorProtocol, httpClient: HTTPClient, registrationEndpoint: URL, notifier: UserRegistrationNotifier? = nil) {
        self.keychain = keychain
        self.validator = validator
        self.httpClient = httpClient
        self.registrationEndpoint = registrationEndpoint
        self.notifier = notifier
    }

    public func register(name: String, email: String, password: String) async -> UserRegistrationResult {
        if let validationError = validator.validate(name: name, email: email, password: password) {
            return .failure(validationError)
        }
        
        let userData = UserRegistrationData(name: name, email: email, password: password)
        let body = [
            "name": userData.name,
            "email": userData.email,
            "password": userData.password
        ]
        
        return await withCheckedContinuation { [self] continuation in
            _ = httpClient.post(to: registrationEndpoint, body: body) { [weak self] result in
                switch result {
                case .success((_, let httpResponse)):
                    switch httpResponse.statusCode {
                    case 201:
                        Task { [weak self] in
                            await self?.saveCredentials(email: email, password: password)
                            continuation.resume(returning: .success(User(name: name, email: email)))
                        }
                    case 409:
                        self?.notifier?.notifyEmailAlreadyInUse()
                        continuation.resume(returning: .failure(UserRegistrationError.emailAlreadyInUse))
                    case 400..<500:
                        continuation.resume(returning: .failure(NetworkError.clientError(statusCode: httpResponse.statusCode)))
                    case 500..<600:
                        continuation.resume(returning: .failure(NetworkError.serverError(statusCode: httpResponse.statusCode)))
                    default:
                        continuation.resume(returning: .failure(NetworkError.unknown))
                    }
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
    }

    // MARK: - Private Helpers (Actor Context)
    private func saveCredentials(email: String, password: String) {
        _ = keychain.save(data: password.data(using: .utf8)!, forKey: email)
    }
}
