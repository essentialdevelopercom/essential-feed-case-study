import XCTest
@testable import EssentialFeed

final class UserLoginUseCaseTests: XCTestCase {
    func test_login_succeeds_onValidCredentialsAndServerResponse() async throws {
        let (sut, api, successObserver, _) = makeSUT()
        let credentials = LoginCredentials(email: "user@example.com", password: "password123")
        let expectedToken = "jwt-token-123"
        
        api.stubbedResult = .success(LoginResponse(token: expectedToken))
        
        let result = await sut.login(with: credentials)
        switch result {
        case let .success(response):
            XCTAssertEqual(response.token, expectedToken)
            XCTAssertTrue(successObserver.didNotifySuccess)
        case .failure:
            XCTFail("Expected success, got failure")
        }
    }

    func test_login_fails_onInvalidCredentials() async throws {
        let (sut, api, _, failureObserver) = makeSUT()
        let credentials = LoginCredentials(email: "user@example.com", password: "wrongpass")
        
        api.stubbedResult = .failure(.invalidCredentials)
        
        let result = await sut.login(with: credentials)
        switch result {
        case .success:
            XCTFail("Expected failure, got success")
        case let .failure(error):
            XCTAssertEqual(error, .invalidCredentials)
            XCTAssertTrue(failureObserver.didNotifyFailure)
        }
    }

    // MARK: - Helpers
    private func makeSUT() -> (sut: UserLoginUseCase, api: AuthAPISpy, successObserver: LoginSuccessObserverSpy, failureObserver: LoginFailureObserverSpy) {
        let api = AuthAPISpy()
        let successObserver = LoginSuccessObserverSpy()
        let failureObserver = LoginFailureObserverSpy()
        let sut = UserLoginUseCase(api: api, successObserver: successObserver, failureObserver: failureObserver)
        return (sut, api, successObserver, failureObserver)
    }
}

// MARK: - Test Doubles
final class AuthAPISpy: AuthAPI {
    var stubbedResult: Result<LoginResponse, LoginError>?
    func login(with credentials: LoginCredentials, completion: @escaping (Result<LoginResponse, LoginError>) -> Void) {
        if let result = stubbedResult {
            completion(result)
        }
    }
}

final class LoginSuccessObserverSpy: LoginSuccessObserver {
    var didNotifySuccess = false
    func didLoginSuccessfully(response: LoginResponse) {
        didNotifySuccess = true
    }
}

final class LoginFailureObserverSpy: LoginFailureObserver {
    var didNotifyFailure = false
    func didFailLogin(error: LoginError) {
        didNotifyFailure = true
    }
}
