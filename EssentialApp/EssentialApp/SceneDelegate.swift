//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import CoreData
import EssentialFeed

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	
	private lazy var httpClient: HTTPClient = {
		URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
	}()
	
	private lazy var store: FeedStore & FeedImageDataStore = {
		try! CoreDataFeedStore(
			storeURL: NSPersistentContainer
				.defaultDirectoryURL()
				.appendingPathComponent("feed-store.sqlite"))
	}()

	private lazy var localFeedLoader: LocalFeedLoader = {
		LocalFeedLoader(store: store, currentDate: Date.init)
	}()

	convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
		self.init()
		self.httpClient = httpClient
		self.store = store
	}
	
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let scene = (scene as? UIWindowScene) else { return }
	
        window = UIWindow(windowScene: scene)
		configureWindow()
	}
	
	func configureWindow() {
		let remoteURL = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
		
		let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: httpClient)
		let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
		let localImageLoader = LocalFeedImageDataLoader(store: store)
		
		window?.rootViewController = UINavigationController(
			rootViewController: FeedUIComposer.feedComposedWith(
				feedLoader: FeedLoaderWithFallbackComposite(
					primary: FeedLoaderCacheDecorator(
						decoratee: remoteFeedLoader,
						cache: localFeedLoader),
					fallback: localFeedLoader),
				imageLoader: FeedImageDataLoaderWithFallbackComposite(
					primary: localImageLoader,
					fallback: FeedImageDataLoaderCacheDecorator(
						decoratee: remoteImageLoader,
						cache: localImageLoader))))
        
        window?.makeKeyAndVisible()
	}
	
	func sceneWillResignActive(_ scene: UIScene) {
		localFeedLoader.validateCache { _ in }
	}
}
