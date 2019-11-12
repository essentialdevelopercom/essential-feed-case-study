//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let _ = (scene as? UIWindowScene) else { return }
		
		let remoteURL = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
		
		let remoteClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
		let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: remoteClient)
		let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)
				
		window?.rootViewController = FeedUIComposer.feedComposedWith(
			feedLoader: remoteFeedLoader,
			imageLoader: remoteImageLoader)
	}
}
