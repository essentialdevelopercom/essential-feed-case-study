import Foundation

public final class LoginPresenter {
    private weak var successView: (any LoginSuccessPresentingView)?
    private weak var errorClearingView: (any LoginErrorClearingPresentingView)?
    
    public init(successView: (any LoginSuccessPresentingView)?, errorClearingView: (any LoginErrorClearingPresentingView)?) {
        self.successView = successView
        self.errorClearingView = errorClearingView
    }
    
    public func didLoginSuccessfully() {
        errorClearingView?.clearErrorMessages()
        successView?.showLoginSuccess()
    }
}
