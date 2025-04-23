
import XCTest
import EssentialFeed

final class LoginPresenterTests: XCTestCase {
    func test_loginSuccess_notifiesViewAndCleansErrors() {
        let (sut, view) = makeSUT()
        
        sut.didLoginSuccessfully()
        
        // Assert: View should be notified of login success
        XCTAssertTrue(view.didShowLoginSuccess, "View should be notified of login success")
        // Assert: View should clear previous error messages
        XCTAssertTrue(view.didClearErrorMessages, "View should clear previous error messages")
    }
    
    // MARK: - Helpers
    private func makeSUT() -> (sut: LoginPresenter, view: LoginViewSpy) {
        let view = LoginViewSpy()
        let sut = LoginPresenter(successView: view, errorClearingView: view)
        return (sut, view)
    }
    
    private class LoginViewSpy: LoginSuccessView, LoginErrorClearingView {
        private(set) var didShowLoginSuccess = false
        private(set) var didClearErrorMessages = false
        
        func showLoginSuccess() {
            didShowLoginSuccess = true
        }
        
        func clearErrorMessages() {
            didClearErrorMessages = true
        }
    }
}
