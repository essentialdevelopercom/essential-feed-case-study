import XCTest
import EssentialFeed
import Foundation

final class UserRegistrationUseCaseTests: XCTestCase {
    func test_registerUser_withValidData_createsUserAndStoresCredentialsSecurely() async throws {
        let (sut, _, name, email, password) = makeSUTWithDefaults()
        
        let result = try await sut.register(name: name, email: email, password: password)
        
        switch result {
        case .success(let user):
            XCTAssertEqual(user.name, name)
            XCTAssertEqual(user.email, email)
        case .failure:
            XCTFail("Expected success, got failure instead")
        }
    }
    
    func test_registerUser_withValidData_savesCredentialsInKeychain() async throws {
        let keychain = RecordingKeychainSpy()
        let (sut, name, email, password) = makeSUTWithKeychain(keychain)

        _ = try await sut.register(name: name, email: email, password: password)

        XCTAssertEqual(keychain.savedCredentials.count, 1)
        let saved = keychain.savedCredentials.first
        XCTAssertEqual(saved?.key, email)
        XCTAssertEqual(saved?.data, password.data(using: .utf8))
    }

// MARK: - Helpers
    private func makeSUTWithDefaults(file: StaticString = #file, line: UInt = #line) -> (sut: UserRegistrationUseCase, keychain: KeychainProtocol, name: String, email: String, password: String) {
    let keychain = KeychainSpy()
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
    trackForMemoryLeaks(sut, file: file, line: line)
    trackForMemoryLeaks(keychain as AnyObject, file: file, line: line)
    return (sut, keychain, name, email, password)
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
    trackForMemoryLeaks(sut, file: file, line: line)
    trackForMemoryLeaks(keychain, file: file, line: line)
    return (sut, name, email, password)
}

// Test Doubles para los tests unitarios
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
