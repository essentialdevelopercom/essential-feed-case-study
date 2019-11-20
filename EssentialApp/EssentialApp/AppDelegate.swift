//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
		
		#if DEBUG
		configuration.delegateClass = DebuggingSceneDelegate.self
		#endif
		
		return configuration
	}
	
}
