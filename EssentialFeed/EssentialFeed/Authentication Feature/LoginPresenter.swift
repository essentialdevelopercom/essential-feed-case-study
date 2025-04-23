import Foundation

public final class LoginPresenter {
    private weak var successView: LoginSuccessView?
    private weak var errorClearingView: LoginErrorClearingView?
    
    public init(successView: LoginSuccessView, errorClearingView: LoginErrorClearingView) {
        self.successView = successView
        self.errorClearingView = errorClearingView
    }
    
    public func didLoginSuccessfully() {
        errorClearingView?.clearErrorMessages()
        successView?.showLoginSuccess()
    }
}
