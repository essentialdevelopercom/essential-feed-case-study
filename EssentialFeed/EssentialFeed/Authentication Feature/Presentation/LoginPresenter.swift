import Foundation

public final class LoginPresenter {
    private weak var successView: LoginSuccessPresentingView?
    private weak var errorClearingView: LoginErrorClearingPresentingView?
    
    public init(successView: LoginSuccessPresentingView, errorClearingView: LoginErrorClearingPresentingView) {
        self.successView = successView
        self.errorClearingView = errorClearingView
    }
    
    public func didLoginSuccessfully() {
        errorClearingView?.clearErrorMessages()
        successView?.showLoginSuccess()
    }
}
