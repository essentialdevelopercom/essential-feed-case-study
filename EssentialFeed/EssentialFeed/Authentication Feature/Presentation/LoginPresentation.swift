
import Foundation

public protocol LoginSuccessPresentingView: AnyObject {
    func showLoginSuccess()
}

public protocol LoginErrorClearingPresentingView: AnyObject {
    func clearErrorMessages()
}
