
import Foundation

public protocol LoginSuccessView: AnyObject {
    func showLoginSuccess()
}

public protocol LoginErrorClearingView: AnyObject {
    func clearErrorMessages()
}

