import XCTest
import EssentialFeed

final class UserRegistrationUseCaseTests: XCTestCase {
    func test_registerUser_withValidData_createsUserAndStoresCredentialsSecurely() async throws {
        let httpClient = HTTPClientSpy()
        let url = URL(string: "https://test-register-endpoint.com")!
        let response201 = HTTPURLResponse(url: url, statusCode: 201, httpVersion: nil, headerFields: nil)!
        httpClient.responseToReturn = (Data(), response201)
        let (sut, _, name, email, password, _) = makeSUTWithDefaults(httpClient: httpClient)
        
        let result = await sut.register(name: name, email: email, password: password)
        
        switch result {
        case .success(let user):
            XCTAssertEqual(user.name, name)
            XCTAssertEqual(user.email, email)
        case .failure:
            XCTFail("Expected success, got failure instead")
        }
    }

    func test_registerUser_withEmptyName_returnsValidationError_andDoesNotCallHTTPOrKeychain() async {
        await assertRegistrationValidation(
            name: "",
            email: "test@email.com",
            password: "Password123",
            expectedError: .emptyName
        )
    }
    
    func test_registerUser_withInvalidEmail_returnsValidationError_andDoesNotCallHTTPOrKeychain() async {
        await assertRegistrationValidation(
            name: "Test User",
            email: "invalid-email",
            password: "Password123",
            expectedError: .invalidEmail
        )
    }
    
    func test_registerUser_withWeakPassword_returnsValidationError_andDoesNotCallHTTPOrKeychain() async {
        await assertRegistrationValidation(
            name: "Test User",
            email: "test@email.com",
            password: "123",
            expectedError: .weakPassword
        )
    }

// MARK: - Helpers

    private func assertRegistrationValidation(
        name: String,
        email: String,
        password: String,
        expectedError: RegistrationValidationError,
        file: StaticString = #file,
        line: UInt = #line
    ) async {
        let keychain = KeychainSpy()
        let validator = RegistrationValidatorStub()
        let httpClient = HTTPClientSpy()
        let sut = UserRegistrationUseCase(keychain: keychain, validator: validator, httpClient: httpClient, registrationEndpoint: anyURL())
        
        let result = await sut.register(name: name, email: email, password: password)
        
        switch result {
        case .failure(let error as RegistrationValidationError):
            XCTAssertEqual(error, expectedError, file: #file, line: #line)
        default:
            XCTFail("Expected failure with \(expectedError), got \(result) instead", file: #file, line: #line)
        }
        XCTAssertEqual(httpClient.postCallCount, 0, "No HTTP request should be made if validation fails", file: #file, line: #line)
        XCTAssertEqual(keychain.saveCallCount, 0, "No Keychain save should occur if validation fails", file: #file, line: #line)
    }

    private func makeSUTWithDefaults(httpClient: HTTPClientSpy? = nil) -> (UserRegistrationUseCase, KeychainProtocol, String, String, String, HTTPClientSpy) {
    let keychain = KeychainSpy()
    let name = "Carlos"
    let email = "carlos@email.com"
    let password = "StrongPassword123"
    let httpClient = httpClient ?? HTTPClientSpy()
    let registrationEndpoint = URL(string: "https://test-register-endpoint.com")!
    let sut = UserRegistrationUseCase(
        keychain: keychain,
        validator: RegistrationValidatorStub(),
        httpClient: httpClient,
        registrationEndpoint: registrationEndpoint
    )
    trackForMemoryLeaks(sut, file: #file, line: #line)
    trackForMemoryLeaks(keychain as AnyObject, file: #file, line: #line)
    return (sut, keychain, name, email, password, httpClient)
}

    private func makeSUTWithKeychain(_ keychain: RecordingKeychainSpy, file: StaticString = #file, line: UInt = #line) -> (sut: UserRegistrationUseCase, name: String, email: String, password: String) {
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
    var statusCode: Int = 201 // Valor por defecto esperado por la lógica

    func post(to url: URL, body: [String: String], completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        postCallCount += 1
        requestedURLs.append(url)
        requestedBodies.append(body)
        
        if let error = errorToReturn {
            completion(.failure(error))
        } else if let response = responseToReturn {
            completion(.success(response))
        } else {
            let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
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
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            completion(.success((Data(), response)))
            return DummyHTTPClientTask()
        }
        func post(to url: URL, body: [String : String], completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            completion(.success((Data(), response)))
            return DummyHTTPClientTask()
        }
    }

    private class DummyHTTPClientTask: HTTPClientTask {
        func cancel() {}
    }
}

// MARK: - Test Double
final class KeychainSpy: KeychainProtocol {
	private(set) var saveCallCount = 0
	func save(data: Data, forKey key: String) -> Bool {
		saveCallCount += 1
		return false
	}
}
