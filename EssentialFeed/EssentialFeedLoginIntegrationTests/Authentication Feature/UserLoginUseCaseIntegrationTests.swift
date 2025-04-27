// CU: User Authentication - Integration: No network or Keychain call on validation error
// Checklist: Integration tests must ensure no HTTP or Keychain access on invalid format

import XCTest
import EssentialFeed

final class UserLoginUseCaseIntegrationTests: XCTestCase {
    
    func test_login_doesNotCallAPI_whenEmailIsInvalid() async {
        let api = AuthAPISpy()
        let sut = UserLoginUseCase(api: api)
        let credentials = LoginCredentials(email: "", password: "ValidPassword123")
        _ = await sut.login(with: credentials)
        XCTAssertFalse(api.wasCalled, "API should NOT be called when email is invalid")
    }
    
    func test_login_doesNotCallAPI_whenPasswordIsInvalid() async {
        let api = AuthAPISpy()
        let sut = UserLoginUseCase(api: api)
        let credentials = LoginCredentials(email: "user@example.com", password: "   ")
        _ = await sut.login(with: credentials)
        XCTAssertFalse(api.wasCalled, "API should NOT be called when password is invalid")
    }
    
    // Si existe Keychain/secure storage en el flujo, añadir spy y test equivalente:
    // func test_login_doesNotAccessKeychain_whenValidationFails() async { ... }
}

// Spy para AuthAPI (puedes moverlo a un test helper si ya existe)
final class AuthAPISpy: AuthAPI {
    private(set) var wasCalled = false
    func login(with credentials: LoginCredentials) async -> Result<LoginResponse, LoginError> {
        wasCalled = true
        return .failure(.network)
    }
}
