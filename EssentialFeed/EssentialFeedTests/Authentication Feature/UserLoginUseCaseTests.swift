// CU: User Authentication - Login Validation
// Checklist: All format validation scenarios must be covered by unit tests (empty email, whitespace email, empty password, whitespace password, short password, both fields empty)

import EssentialFeed
import XCTest

final class UserLoginUseCaseTests: XCTestCase {
	
	func test_login_fails_withEmptyEmail_andDoesNotSendRequest() async {
		let (sut, api, _, failureObserver) = makeSUT()
		let credentials = LoginCredentials(email: "", password: "ValidPassword123")
		let result = await sut.login(with: credentials)
		switch result {
			case .failure(let error):
				XCTAssertEqual(error, .invalidEmailFormat, "Should return invalid email format error for empty email")
				XCTAssertFalse(api.wasCalled, "API should NOT be called when email is empty")
				XCTAssertTrue(failureObserver.didNotifyFailure, "Failure observer should be notified on validation error")
			case .success:
				XCTFail("Expected failure, got success")
		}
	}
	
	func test_login_fails_withWhitespaceOnlyEmail_andDoesNotSendRequest() async {
		let (sut, api, _, failureObserver) = makeSUT()
		let credentials = LoginCredentials(email: "    ", password: "ValidPassword123")
		let result = await sut.login(with: credentials)
		switch result {
			case .failure(let error):
				XCTAssertEqual(error, .invalidEmailFormat, "Should return invalid email format error for whitespace-only email")
				XCTAssertFalse(api.wasCalled, "API should NOT be called when email is whitespace-only")
				XCTAssertTrue(failureObserver.didNotifyFailure, "Failure observer should be notified on validation error")
			case .success:
				XCTFail("Expected failure, got success")
		}
	}
	
	func test_login_fails_withWhitespaceOnlyPassword_andDoesNotSendRequest() async {
		let (sut, api, _, failureObserver) = makeSUT()
		let credentials = LoginCredentials(email: "user@example.com", password: "     ")
		let result = await sut.login(with: credentials)
		switch result {
			case .failure(let error):
				XCTAssertEqual(error, .invalidPasswordFormat, "Should return invalid password format error for whitespace-only password")
				XCTAssertFalse(api.wasCalled, "API should NOT be called when password is whitespace-only")
				XCTAssertTrue(failureObserver.didNotifyFailure, "Failure observer should be notified on validation error")
			case .success:
				XCTFail("Expected failure, got success")
		}
	}
	
	func test_login_fails_withShortPassword_andDoesNotSendRequest() async {
		let (sut, api, _, failureObserver) = makeSUT()
		let credentials = LoginCredentials(email: "user@example.com", password: "12345")
		let result = await sut.login(with: credentials)
		switch result {
			case .failure(let error):
				XCTAssertEqual(error, .invalidPasswordFormat, "Should return invalid password format error for short password")
				XCTAssertFalse(api.wasCalled, "API should NOT be called when password is too short")
				XCTAssertTrue(failureObserver.didNotifyFailure, "Failure observer should be notified on validation error")
			case .success:
				XCTFail("Expected failure, got success")
		}
	}
	
	func test_login_fails_withEmptyEmailAndPassword_andDoesNotSendRequest() async {
		let (sut, api, _, failureObserver) = makeSUT()
		let credentials = LoginCredentials(email: "", password: "")
		let result = await sut.login(with: credentials)
		switch result {
			case .failure(let error):
				XCTAssertEqual(error, .invalidEmailFormat, "Should return invalid email format error when both fields are empty (email checked first)")
				XCTAssertFalse(api.wasCalled, "API should NOT be called when both fields are empty")
				XCTAssertTrue(failureObserver.didNotifyFailure, "Failure observer should be notified on validation error")
			case .success:
				XCTFail("Expected failure, got success")
		}
	}
	
	func test_login_fails_withInvalidEmailFormat_andDoesNotSendRequest() async {
		let (sut, api, _, failureObserver) = makeSUT()
		let invalidEmail = "usuario_invalido"  // sin '@'
		let credentials = LoginCredentials(email: invalidEmail, password: "ValidPassword123")
		
		// No configuramos stubbedResult porque NO debería llamarse la API
		
		let result = await sut.login(with: credentials)
		
		switch result {
			case .failure(let error):
				XCTAssertEqual(error, .invalidEmailFormat, "Should return invalid email format error")
				XCTAssertFalse(api.wasCalled, "API should NOT be called when email format is invalid")
				XCTAssertTrue(
					failureObserver.didNotifyFailure, "Failure observer should be notified on validation error")
			case .success:
				XCTFail("Expected failure, got success")
		}
	}
	
	func test_login_fails_withInvalidPassword_andDoesNotSendRequest() async {
		let (sut, api, _, failureObserver) = makeSUT()
		let invalidPassword = ""  // O prueba con una password demasiado corta
		let credentials = LoginCredentials(email: "user@example.com", password: invalidPassword)
		
		let result = await sut.login(with: credentials)
		
		switch result {
			case .failure(let error):
				XCTAssertEqual(error, .invalidPasswordFormat, "Should return invalid password format error")
				XCTAssertFalse(api.wasCalled, "API should NOT be called when password is invalid")
				XCTAssertTrue(
					failureObserver.didNotifyFailure, "Failure observer should be notified on validation error")
			case .success:
				XCTFail("Expected failure, got success")
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
				XCTAssertEqual(
					error, .invalidCredentials, "Should return invalid credentials error on failure")
				XCTAssertTrue(
					failureObserver.didNotifyFailure, "Failure observer should be notified on failed login")
		}
	}
	
	func test_login_succeeds_onValidCredentialsAndServerResponse() async throws {
		let (sut, api, successObserver, _) = makeSUT()
		let credentials = LoginCredentials(email: "user@example.com", password: "password123")
		let expectedToken = "jwt-token-123"
		
		api.stubbedResult = .success(LoginResponse(token: expectedToken))
		
		let result = await sut.login(with: credentials)
		switch result {
			case let .success(response):
				XCTAssertEqual(response.token, expectedToken, "Returned token should match expected token")
				XCTAssertTrue(
					successObserver.didNotifySuccess, "Success observer should be notified on successful login")
			case .failure:
				XCTFail("Expected success, got failure")
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
	private(set) var wasCalled = false
	
	func login(with credentials: LoginCredentials) async -> Result<LoginResponse, LoginError> {
		wasCalled = true
		guard let result = stubbedResult else {
			XCTFail("API should NOT be called for invalid input. Provide a stubbedResult only when expected.")
			return .failure(.invalidCredentials) // Dummy value, test debe fallar antes
		}
		return result
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
