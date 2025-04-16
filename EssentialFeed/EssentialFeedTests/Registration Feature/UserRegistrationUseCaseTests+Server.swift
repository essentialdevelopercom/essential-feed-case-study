import XCTest
import EssentialFeed
import Foundation

final class UserRegistrationUseCaseTests: XCTestCase {
    // ... otros tests ...

    func test_registerUser_sendsRequestToServer() async throws {
        let httpClient = HTTPClientSpy()
        let sut = UserRegistrationUseCase(
            keychain: KeychainSpy(),
            validator: RegistrationValidatorStub(),
            httpClient: httpClient,
            registrationEndpoint: URL(string: "https://test-register-endpoint.com")!
        )
        let name = "Carlos"
        let email = "carlos@email.com"
        let password = "StrongPassword123"

        _ = try? await sut.register(name: name, email: email, password: password)

        XCTAssertEqual(httpClient.requestedURLs, [URL(string: "https://test-register-endpoint.com")!])
        XCTAssertEqual(httpClient.lastHTTPBody, [
            "name": name,
            "email": email,
            "password": password
        ])
    }
}

// MARK: - Test Doubles

final class HTTPClientSpy: HTTPClient {
    private(set) var requestedURLs: [URL] = []
    private(set) var lastHTTPBody: [String: String]? = nil

    func post(to url: URL, body: [String: String], completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        requestedURLs.append(url)
        lastHTTPBody = body
        // Simula una respuesta exitosa con la tupla correcta
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        completion(.success((Data(), response)))
        return DummyHTTPClientTask()
    }

    // Implementación dummy para cumplir el protocolo
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        return DummyHTTPClientTask()
    }
}

final class DummyHTTPClientTask: HTTPClientTask {
    func cancel() {}
}
