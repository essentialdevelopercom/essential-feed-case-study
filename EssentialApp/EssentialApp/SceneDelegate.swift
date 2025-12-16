//
//  Copyright © Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	
	private lazy var feedService = FeedService()
	
	private lazy var navigationController = UINavigationController(
		rootViewController: FeedUIComposer.feedComposedWith(
			feedLoader: feedService.loadRemoteFeedWithLocalFallback,
			imageLoader: feedService.loadLocalImageWithRemoteFallback,
			selection: showComments))
	
	convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore & Scheduler & Sendable) {
		self.init()
		self.feedService = FeedService(httpClient: httpClient, store: store)
	}
	
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let scene = (scene as? UIWindowScene) else { return }
		
		window = UIWindow(windowScene: scene)
		configureWindow()
	}
	
	func configureWindow() {
		window?.rootViewController = navigationController
		window?.makeKeyAndVisible()
	}
	
	func sceneWillResignActive(_ scene: UIScene) {
		feedService.validateCache()
	}
	
	private func showComments(for image: FeedImage) {
		let comments = CommentsUIComposer.commentsComposedWith(commentsLoader: feedService.loadComments(for: image))
		navigationController.pushViewController(comments, animated: true)
	}
}
