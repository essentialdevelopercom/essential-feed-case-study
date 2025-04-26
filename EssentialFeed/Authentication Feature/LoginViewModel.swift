import Foundation

public final class LoginViewModel: ObservableObject {
    private let onAuthenticated: () -> Void
    
    @Published public var username: String = ""
    @Published public var password: String = ""
    @Published public var errorMessage: String?
    
    public init(onAuthenticated: @escaping () -> Void) {
        self.onAuthenticated = onAuthenticated
    }
    
    public func login() {
        // Placeholder: Replace with actual login logic & presenter integration
        if username == "user" && password == "pass" {
            errorMessage = nil
            onAuthenticated()
        } else {
            errorMessage = "Invalid credentials."
        }
    }
}
