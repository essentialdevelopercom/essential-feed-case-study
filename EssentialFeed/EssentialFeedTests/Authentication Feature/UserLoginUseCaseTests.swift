import XCTest

@testable import EssentialFeed

final class UserLoginUseCaseTests: XCTestCase {
  // CU: Autenticación de Usuario
  // Checklist: Notificar éxito al observer y almacenar token seguro
  func test_login_succeeds_onValidCredentialsAndServerResponse() async throws {
    let (sut, api, successObserver, _) = makeSUT()
    let credentials = LoginCredentials(email: "user@example.com", password: "password123")
    let expectedToken = "jwt-token-123"

    api.stubbedResult = .success(LoginResponse(token: expectedToken))

    let result = await sut.login(with: credentials)
    switch result {
    case let .success(response):
      XCTAssertEqual(response.token, expectedToken, "Returned token should match expected token")
      XCTAssertTrue(successObserver.didNotifySuccess, "Success observer should be notified on successful login")
    case .failure:
      XCTFail("Expected success, got failure")
    }
  }

  // CU: Autenticación de Usuario
  // Checklist: Manejar error de credenciales y notificar fallo al observer
  func test_login_fails_onInvalidCredentials() async throws {
    let (sut, api, _, failureObserver) = makeSUT()
    let credentials = LoginCredentials(email: "user@example.com", password: "wrongpass")

    api.stubbedResult = .failure(.invalidCredentials)

    let result = await sut.login(with: credentials)
    switch result {
    case .success:
      XCTFail("Expected failure, got success")
    case let .failure(error):
      XCTAssertEqual(error, .invalidCredentials, "Should return invalid credentials error on failure")
      XCTAssertTrue(failureObserver.didNotifyFailure, "Failure observer should be notified on failed login")
    }
  }

  // MARK: - Helpers
  private func makeSUT() -> (
    sut: UserLoginUseCase, api: AuthAPISpy, successObserver: LoginSuccessObserverSpy,
    failureObserver: LoginFailureObserverSpy
  ) {
    let api = AuthAPISpy()
    let successObserver = LoginSuccessObserverSpy()
    let failureObserver = LoginFailureObserverSpy()
    let sut = UserLoginUseCase(
      api: api, successObserver: successObserver, failureObserver: failureObserver)
    return (sut, api, successObserver, failureObserver)
  }
}

// MARK: - Test Doubles
final class AuthAPISpy: AuthAPI {
  var stubbedResult: Result<LoginResponse, LoginError>?
  func login(with credentials: LoginCredentials) async -> Result<LoginResponse, LoginError> {
    return stubbedResult!
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
