import UIKit
import SwiftUI
import Combine
import EssentialFeed

public enum LoginComposer {
    private static var cancellables = Set<AnyCancellable>()
    public static func loginViewController(
        onAuthenticated: @escaping () -> Void) -> UIViewController {
        let viewModel = LoginViewModel()
        let loginView = LoginView(viewModel: viewModel)
        let controller = UIHostingController(rootView: loginView)
        viewModel.authenticated
            .sink { onAuthenticated() }
            .store(in: &cancellables)
        return controller
    }
}
