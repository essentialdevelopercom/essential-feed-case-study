import UIKit
import SwiftUI

public enum LoginComposer {
    public static func loginViewController(
        onAuthenticated: @escaping () -> Void
    ) -> UIViewController {
        // Placeholder for the real SwiftUI LoginView integration
        let viewModel = LoginViewModel(onAuthenticated: onAuthenticated)
        let loginView = LoginView(viewModel: viewModel)
        return UIHostingController(rootView: loginView)
    }
}
