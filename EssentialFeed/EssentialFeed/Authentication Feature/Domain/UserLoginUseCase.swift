import Foundation

public struct LoginCredentials {
	public let email: String
	public let password: String
	public init(email: String, password: String) {
		self.email = email
		self.password = password
	}
}

public struct LoginResponse: Equatable {
	public let token: String
	public init(token: String) {
		self.token = token
	}
}

public protocol AuthAPI {
	func login(with credentials: LoginCredentials) async -> Result<LoginResponse, LoginError>
}

public enum LoginError: Error, Equatable {
	case invalidCredentials
	case network
	case invalidEmailFormat
	case invalidPasswordFormat
}

public protocol LoginSuccessObserver {
	func didLoginSuccessfully(response: LoginResponse)
}

public protocol LoginFailureObserver {
	func didFailLogin(error: LoginError)
}

public final class UserLoginUseCase {
	private let api: AuthAPI
	private let successObserver: LoginSuccessObserver?
	private let failureObserver: LoginFailureObserver?
	
	public init(api: AuthAPI, successObserver: LoginSuccessObserver? = nil, failureObserver: LoginFailureObserver? = nil) {
		self.api = api
		self.successObserver = successObserver
		self.failureObserver = failureObserver
	}
	
	public func login(with credentials: LoginCredentials) async -> Result<LoginResponse, LoginError> {
        let trimmedEmail = credentials.email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = credentials.password.trimmingCharacters(in: .whitespacesAndNewlines)
        // Email must not be empty and must contain '@'
        guard !trimmedEmail.isEmpty, trimmedEmail.contains("@") else {
            self.failureObserver?.didFailLogin(error: .invalidEmailFormat)
            return .failure(.invalidEmailFormat)
        }
        // Password must not be empty, must have at least 8 characters, and not be only whitespace
        guard !trimmedPassword.isEmpty, trimmedPassword.count >= 8 else {
            self.failureObserver?.didFailLogin(error: .invalidPasswordFormat)
            return .failure(.invalidPasswordFormat)
        }
        let result = await api.login(with: credentials)
        switch result {
            case let .success(response):
                self.successObserver?.didLoginSuccessfully(response: response)
                return .success(response)
            case let .failure(error):
                self.failureObserver?.didFailLogin(error: error)
                return .failure(error)
        }
    }
}
