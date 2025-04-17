import XCTest
@testable import EssentialFeed

final class UserLoginUseCaseTests: XCTestCase {
    func test_login_succeeds_onValidCredentialsAndServerResponse() throws {
        let (sut, api, observer) = makeSUT()
        let credentials = LoginCredentials(email: "user@example.com", password: "password123")
        let expectedToken = "jwt-token-123"
        
        api.stubbedResult = .success(LoginResponse(token: expectedToken))
        
        sut.login(with: credentials) { result in
            switch result {
            case let .success(response):
                XCTAssertEqual(response.token, expectedToken)
                observer.didNotifySuccess = true
            case .failure:
                XCTFail("Expected success, got failure")
            }
        }
        XCTAssertTrue(observer.didNotifySuccess)
    }

    func test_login_fails_onInvalidCredentials() throws {
        let (sut, api, observer) = makeSUT()
        let credentials = LoginCredentials(email: "user@example.com", password: "wrongpass")
        
        api.stubbedResult = .failure(.invalidCredentials)
        
        sut.login(with: credentials) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case let .failure(error):
                XCTAssertEqual(error, .invalidCredentials)
                observer.didNotifyFailure = true
            }
        }
        XCTAssertTrue(observer.didNotifyFailure)
    }

    // MARK: - Helpers
    private func makeSUT() -> (sut: UserLoginUseCase, api: AuthAPISpy, observer: LoginObserverSpy) {
        let api = AuthAPISpy()
        let observer = LoginObserverSpy()
        let sut = UserLoginUseCase(api: api, observer: observer)
        return (sut, api, observer)
    }
}

// MARK: - Test Doubles
struct LoginCredentials {
    let email: String
    let password: String
}

struct LoginResponse: Equatable {
    let token: String
}

enum LoginError: Error, Equatable {
    case invalidCredentials
    case network
}

final class AuthAPISpy {
    var stubbedResult: Result<LoginResponse, LoginError>?
    func login(with credentials: LoginCredentials, completion: @escaping (Result<LoginResponse, LoginError>) -> Void) {
        if let result = stubbedResult {
            completion(result)
        }
    }
}

final class LoginObserverSpy {
    var didNotifySuccess = false
    var didNotifyFailure = false
}

final class UserLoginUseCase {
    private let api: AuthAPISpy
    private let observer: LoginObserverSpy
    init(api: AuthAPISpy, observer: LoginObserverSpy) {
        self.api = api
        self.observer = observer
    }
    func login(with credentials: LoginCredentials, completion: @escaping (Result<LoginResponse, LoginError>) -> Void) {
        api.login(with: credentials) { result in
            completion(result)
        }
    }
}
