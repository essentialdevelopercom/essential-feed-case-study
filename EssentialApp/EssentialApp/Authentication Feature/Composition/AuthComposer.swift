import UIKit
import SwiftUI

public enum AuthComposer {
    public static func authViewController(
        onAuthenticated: @escaping () -> Void) -> UIViewController {
        // For now, show the login flow. Registration can be added easily here.
        let loginVC = LoginComposer.loginViewController(onAuthenticated: onAuthenticated)
        return loginVC
    }
}
