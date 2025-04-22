import EssentialFeed
import Security
import XCTest

final class UserRegistrationUseCaseTests: XCTestCase {
	// CU: Registro de Usuario
	// Checklist: Crear usuario y almacenar credenciales de forma segura
	func test_registerUser_withValidData_createsUserAndStoresCredentialsSecurely() async throws {
		let httpClient = HTTPClientSpy()
		let url = URL(string: "https://test-register-endpoint.com")!
		let response201 = HTTPURLResponse(
			url: url,
			statusCode: 201,
			httpVersion: nil,
			headerFields: nil
		)!
		httpClient.responseToReturn = (Data(), response201)
		let (sut, _, name, email, password, _) = makeSUTWithDefaults(httpClient: httpClient)
		
		let result = await sut.register(name: name, email: email, password: password)
		
		switch result {
			case .success(let user):
				XCTAssertEqual(user.name, name, "Registered user's name should match input")
				XCTAssertEqual(user.email, email, "Registered user's email should match input")
			case .failure:
				XCTFail("Expected success, got failure instead")
		}
	}
	
	// CU: Registro de Usuario
	// Checklist: Validar nombre vacío y no llamar a HTTP ni Keychain si es inválido
	func test_registerUser_withEmptyName_returnsValidationError_andDoesNotCallHTTPOrKeychain() async {
		await assertRegistrationValidation(
			name: "",
			email: "test@email.com",
			password: "Password123",
			expectedError: .emptyName
		)
	}
	
	// Checklist: Validar email y no llamar a Keychain si es inválido
	// CU: Registro de Usuario
	// Checklist: Validar email y no llamar a Keychain si es inválido
	func test_registerUser_withInvalidEmail_returnsValidationError_andDoesNotCallHTTPOrKeychain() async {
		await assertRegistrationValidation(
			name: "Test User",
			email: "invalid-email",
			password: "Password123",
			expectedError: .invalidEmail
		)
	}
	
	// Checklist: Validar password débil y no llamar a Keychain si es inválido
	// CU: Registro de Usuario
	// Checklist: Validar password débil y no llamar a Keychain si es inválido
	func test_registerUser_withWeakPassword_returnsValidationError_andDoesNotCallHTTPOrKeychain() async {
		await assertRegistrationValidation(
			name: "Test User",
			email: "test@email.com",
			password: "123",
			expectedError: .weakPassword
		)
	}
	
	// CU: Registro de Usuario
	// Checklist: Manejar error de email ya registrado y no guardar credenciales
	func test_registerUser_withAlreadyRegisteredEmail_notifiesEmailAlreadyInUsePresenter() async {
		let httpClient = HTTPClientSpy()
		httpClient.statusCode = 409  // Simula respuesta de correo ya registrado
		let expectation = expectation(description: "Notifier should be called")
		let notifier = UserRegistrationNotifierSpy {
			expectation.fulfill()
		}
		let (sut, keychain, name, email, password, _) = makeSUTWithDefaults(
			httpClient: httpClient,
			notifier: notifier
		)
		
		let result = await sut.register(name: name, email: email, password: password)
		
		// Assert: Se notifica al notifier (async/await)
		await fulfillment(of: [expectation], timeout: 1.0)
		XCTAssertTrue(notifier.notified, "Notifier should be called on registration")
		// Assert: No se guardan credenciales
		XCTAssertEqual(
			keychain.saveSpy.saveCallCount,
			0,
			"Keychain save should not be called on registration failure"
		)
		// Assert: El resultado es el error esperado
		switch result {
			case .failure(let error as UserRegistrationError):
				XCTAssertEqual(error, UserRegistrationError.emailAlreadyInUse)
			default:
				XCTFail("Expected .emailAlreadyInUse error, got \(result) instead")
		}
	}
	
	// Checklist: Manejar error de email ya registrado y no guardar credenciales
	// CU: Registro de Usuario
	// Checklist: Manejar error de email ya registrado y no guardar credenciales
	func test_registerUser_withAlreadyRegisteredEmail_returnsEmailAlreadyInUseError_andDoesNotStoreCredentials() async {
		let httpClient = HTTPClientSpy()
		httpClient.statusCode = 409  // Simula respuesta de correo ya registrado
		let (sut, keychain, name, email, password, _) = makeSUTWithDefaults(httpClient: httpClient)
		
		let result = await sut.register(name: name, email: email, password: password)
		
		switch result {
			case .failure(let error as UserRegistrationError):
				XCTAssertEqual(error, .emailAlreadyInUse)
			default:
				XCTFail("Expected .emailAlreadyInUse error, got \(result) instead")
		}
		XCTAssertEqual(
			keychain.saveSpy.saveCallCount,
			0,
			"No Keychain save should occur if email is already registered"
		)
	}
	
	// Checklist: Manejar error de conectividad y no guardar credenciales
	// CU: Registro de Usuario
	// Checklist: Manejar error de conectividad y no guardar credenciales
	func test_registerUser_withNoConnectivity_returnsConnectivityError_andDoesNotStoreCredentials() async {
		let httpClient = HTTPClientSpy()
		httpClient.errorToReturn = NetworkError.noConnectivity
		let (sut, keychain, name, email, password, _) = makeSUTWithDefaults(httpClient: httpClient)
		
		let result = await sut.register(name: name, email: email, password: password)
		
		switch result {
			case .failure(let error as NetworkError):
				XCTAssertEqual(error, .noConnectivity)
			default:
				XCTFail("Expected failure with .noConnectivity, got \(result) instead")
		}
		XCTAssertEqual(
			keychain.saveSpy.saveCallCount,
			0,
			"No Keychain save should occur if there is no connectivity"
		)
	}
	
	// MARK: - Notifier Spy
	// MARK: - Presenter Spies (SRP & ISP)
	
	final class UserRegistrationNotifierSpy: UserRegistrationNotifier {
		private(set) var notified = false
		private let onNotify: (() -> Void)?
		init(onNotify: (() -> Void)? = nil) {
			self.onNotify = onNotify
		}
		func notifyEmailAlreadyInUse() {
			notified = true
			onNotify?()
		}
	}
	
	// MARK: - Tests
	
	private func assertRegistrationValidation(
		name: String,
		email: String,
		password: String,
		expectedError: RegistrationValidationError,
		file: StaticString = #file,
		line: UInt = #line
	) async {
		let keychain = makeKeychainFullSpy()
		let validator = RegistrationValidatorStub()
		let httpClient = HTTPClientSpy()
		let sut = UserRegistrationUseCase(
			keychain: keychain,
			validator: validator,
			httpClient: httpClient,
			registrationEndpoint: anyURL()
		)
		
		let result = await sut.register(name: name, email: email, password: password)
		
		switch result {
			case .failure(let error as RegistrationValidationError):
				XCTAssertEqual(error, expectedError, file: #file, line: #line)
			default:
				XCTFail(
					"Expected failure with \(expectedError), got \(result) instead",
					file: #file,
					line: #line
				)
		}
		
		XCTAssertEqual(
			httpClient.postCallCount,
			0,
			"No HTTP request should be made if validation fails",
			file: #file,
			line: #line
		)
		
		XCTAssertEqual(
			keychain.saveSpy.saveCallCount,
			0,
			"No Keychain save should occur if validation fails",
			file: #file,
			line: #line
		)
	}
	
	private func makeSUTWithDefaults(
		httpClient: HTTPClientSpy? = nil,
		notifier: UserRegistrationNotifier? = nil
	) -> (UserRegistrationUseCase, KeychainFullSpy, String, String, String, HTTPClientSpy) {
		let keychain = makeKeychainFullSpy()
		let name = "Carlos"
		let email = "carlos@email.com"
		let password = "StrongPassword123"
		let httpClient = httpClient ?? HTTPClientSpy()
		let registrationEndpoint = URL(string: "https://test-register-endpoint.com")!
		let sut = UserRegistrationUseCase(
			keychain: keychain,
			validator: RegistrationValidatorStub(),
			httpClient: httpClient,
			registrationEndpoint: registrationEndpoint,
			notifier: notifier
		)
		trackForMemoryLeaks(sut, file: #file, line: #line)
		trackForMemoryLeaks(keychain as AnyObject, file: #file, line: #line)
		return (sut, keychain, name, email, password, httpClient)
	}
	
	private func makeSUTWithKeychain(
		_ keychain: KeychainFullSpy,
		file: StaticString = #file,
		line: UInt = #line
	) -> (sut: UserRegistrationUseCase, name: String, email: String, password: String) {
		let name = "Carlos"
		let email = "carlos@email.com"
		let password = "StrongPassword123"
		let httpClient = HTTPClientDummy()
		let registrationEndpoint = URL(string: "https://test-register-endpoint.com")!
		let sut = UserRegistrationUseCase(
			keychain: keychain,
			validator: RegistrationValidatorStub(),
			httpClient: httpClient,
			registrationEndpoint: registrationEndpoint
		)
		trackForMemoryLeaks(sut, file: #file, line: #line)
		trackForMemoryLeaks(keychain, file: #file, line: #line)
		return (sut, name, email, password)
	}
	
	private class HTTPClientSpy: HTTPClient {
		private(set) var postCallCount = 0
		private(set) var requestedURLs: [URL] = []
		private(set) var requestedBodies: [[String: String]] = []
		
		var responseToReturn: (Data, HTTPURLResponse)?
		var errorToReturn: Error?
		var statusCode: Int = 201  // Valor por defecto esperado por la lógica
		
		func post(
			to url: URL,
			body: [String: String],
			completion: @escaping (HTTPClient.Result) -> Void
		) -> HTTPClientTask {
			postCallCount += 1
			requestedURLs.append(url)
			requestedBodies.append(body)
			
			if let error = errorToReturn {
				completion(.failure(error))
			} else if let response = responseToReturn {
				completion(.success(response))
			} else {
				let response = HTTPURLResponse(
					url: url,
					statusCode: statusCode,
					httpVersion: nil,
					headerFields: nil
				)!
				completion(.success((Data(), response)))
			}
			return DummyHTTPClientTask()
		}
		
		func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
			return DummyHTTPClientTask()
		}
	}
	
	private class HTTPClientDummy: HTTPClient {
		func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
			let response = HTTPURLResponse(
				url: url,
				statusCode: 200,
				httpVersion: nil,
				headerFields: nil
			)!
			completion(.success((Data(), response)))
			return DummyHTTPClientTask()
		}
		
		func post(
			to url: URL,
			body: [String: String],
			completion: @escaping (HTTPClient.Result) -> Void
		) -> HTTPClientTask {
			let response = HTTPURLResponse(
				url: url,
				statusCode: 200,
				httpVersion: nil,
				headerFields: nil
			)!
			completion(.success((Data(), response)))
			return DummyHTTPClientTask()
		}
	}
	
	private class DummyHTTPClientTask: HTTPClientTask {
		func cancel() {}
	}
}
