// CU: Autenticación de Usuario
// Checklist: Mapping de errores a mensajes claros y específicos para el usuario final
// - Cada LoginError debe mapearse a un mensaje inequívoco, claro y alineado con las guidelines de producto
// - El mapping debe ser fácilmente testeable y extensible

import XCTest
import EssentialFeed

final class UserLoginErrorMappingTests: XCTestCase {
    func test_errorMapping_returnsCorrectMessageForEachError() {
        // Given
        let cases: [(LoginError, String)] = [
            (.invalidEmailFormat, "Email format is invalid"),
            (.invalidPasswordFormat, "Password does not meet the minimum requirements"),
            (.invalidCredentials, "Invalid credentials"),
            (.network, "Could not connect. Please try again.")
        ]

        for (error, expectedMessage) in cases {
            XCTAssertEqual(LoginErrorMessageMapper.message(for: error), expectedMessage, "Error mapping for \(error) should be '\(expectedMessage)'")
        }
    }
}


