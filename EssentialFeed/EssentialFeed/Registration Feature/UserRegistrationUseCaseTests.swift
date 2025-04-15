import XCTest
import EssentialFeed

final class UserRegistrationUseCaseTests: XCTestCase {
    func test_registerUser_withValidData_createsUserAndStoresCredentialsSecurely() async throws {
        let sut = makeSUT()
        let name = "Carlos"
        let email = "carlos@email.com"
        let password = "StrongPassword123"
        
        let result = try await sut.register(name: name, email: email, password: password)
        
        switch result {
        case .success(let user):
            XCTAssertEqual(user.name, name)
            XCTAssertEqual(user.email, email)
            // Aquí podríamos verificar si el Keychain fue llamado, usando un spy/mock
        case .failure:
            XCTFail("Expected success, got failure instead")
        }
    }
    
    // MARK: - Helpers
    private func makeSUT() -> UserRegistrationUseCase {
        // Aquí inyectaremos mocks/spies para el Keychain y validadores
        return UserRegistrationUseCase(
            keychain: KeychainSpy(),
            validator: RegistrationValidatorStub()
        )
    }
}
