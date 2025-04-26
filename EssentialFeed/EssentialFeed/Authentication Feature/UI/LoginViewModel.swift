import Foundation
import Combine

public final class LoginViewModel: ObservableObject {
    @Published public var username: String = ""
    @Published public var password: String = ""
    @Published public var errorMessage: String?
    @Published public var loginSuccess: Bool = false
    public let authenticated = PassthroughSubject<Void, Never>()
    
    public init() {}
    
    public func login() {
        if username == "user" && password == "pass" {
            errorMessage = nil
            loginSuccess = true
            authenticated.send(())
        } else {
            errorMessage = "Invalid credentials."
            loginSuccess = false
        }
    }
    
    public func onSuccessAlertDismissed() {
        loginSuccess = false
        // Aquí puedes notificar a la capa superior si hace falta
    }
}
