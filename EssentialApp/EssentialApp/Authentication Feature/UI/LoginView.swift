import SwiftUI
import EssentialFeed

struct BorderedProminentIfAvailable: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content.buttonStyle(.borderedProminent)
        } else {
            content.buttonStyle(DefaultButtonStyle())
        }
    }
}

public struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel

    public init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 16) {
            TextField("Username", text: $viewModel.username)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
            Button("Login") {
                viewModel.login()
            }
            .modifier(BorderedProminentIfAvailable())
        }
        .padding()
        .alert(isPresented: $viewModel.loginSuccess) {
            Alert(
                title: Text("Login Successful"),
                message: Text("Welcome!"),
                dismissButton: .default(Text("OK"), action: {
                    viewModel.onSuccessAlertDismissed()
                })
            )
        }
    }
}

public protocol LoginSuccessView: AnyObject {
    func showLoginSuccess()
}

public protocol LoginErrorClearingView: AnyObject {
    func clearErrorMessages()
}
