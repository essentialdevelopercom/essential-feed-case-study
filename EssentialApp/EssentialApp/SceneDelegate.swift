//
//  Copyright © Essential Developer. All rights reserved.
//

import os
import UIKit
import CoreData
import EssentialFeed

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	
	private lazy var scheduler: AnyDispatchQueueScheduler = {
		if let store = store as? CoreDataFeedStore {
			return .scheduler(for: store)
		}
		
		return DispatchQueue(
			label: "com.essentialdeveloper.infra.queue",
			qos: .userInitiated
		).eraseToAnyScheduler()
	}()
	
	private lazy var httpClient: HTTPClient = {
		URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
	}()
	
	private lazy var logger = Logger(subsystem: "com.essentialdeveloper.EssentialAppCaseStudy", category: "main")
	
	private lazy var store: FeedStore & FeedImageDataStore & StoreScheduler & Sendable = {
		do {
			return try CoreDataFeedStore(
				storeURL: NSPersistentContainer
					.defaultDirectoryURL()
					.appendingPathComponent("feed-store.sqlite"))
		} catch {
			assertionFailure("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
			logger.fault("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
			return InMemoryFeedStore()
		}
	}()
	
	private lazy var localFeedLoader: LocalFeedLoader = {
		LocalFeedLoader(store: store, currentDate: Date.init)
	}()
	
	private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
	
	private lazy var navigationController = UINavigationController(
		rootViewController: FeedUIComposer.feedComposedWith(
			feedLoader: loadRemoteFeedWithLocalFallback,
			imageLoader: loadLocalImageWithRemoteFallback,
			selection: showComments))
	
	convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore & StoreScheduler & Sendable) {
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
		window?.rootViewController = navigationController
		window?.makeKeyAndVisible()
	}
	
	func sceneWillResignActive(_ scene: UIScene) {
		scheduler.schedule { [localFeedLoader, logger] in
			do {
				try localFeedLoader.validateCache()
			} catch {
				logger.error("Failed to validate cache with error: \(error.localizedDescription)")
			}
		}
	}
	
	private func showComments(for image: FeedImage) {
		let url = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)
		let comments = CommentsUIComposer.commentsComposedWith(commentsLoader: loadComments(url: url))
		navigationController.pushViewController(comments, animated: true)
	}
	
	private func loadComments(url: URL) -> () async throws -> [ImageComment] {
		return { [httpClient] in
			let (data, response) = try await httpClient.get(from: url)
			return try ImageCommentsMapper.map(data, from: response)
		}
	}
	
	private func loadRemoteFeedWithLocalFallback() async throws -> Paginated<FeedImage> {
		do {
			let feed = try await loadAndCacheRemoteFeed()
			return makeFirstPage(items: feed)
		} catch {
			let feed = try await loadLocalFeed()
			return makeFirstPage(items: feed)
		}
	}
	
	private func loadAndCacheRemoteFeed() async throws -> [FeedImage] {
		let feed = try await loadRemoteFeed()
		await store.schedule { [store] in
			let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
			try? localFeedLoader.save(feed)
		}
		return feed
	}

	private func loadLocalFeed() async throws -> [FeedImage] {
		try await store.schedule { [store] in
			let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
			return try localFeedLoader.load()
		}
	}
	
	private func loadRemoteFeed(after: FeedImage? = nil) async throws -> [FeedImage] {
		let url = FeedEndpoint.get(after: after).url(baseURL: baseURL)
		let (data, response) = try await httpClient.get(from: url)
		return try FeedItemsMapper.map(data, from: response)
	}

	private func loadMoreRemoteFeed(last: FeedImage?) async throws -> Paginated<FeedImage> {
		async let cachedItems = try await loadLocalFeed()
		async let newItems = try await loadRemoteFeed(after: last)
		
		let items = try await cachedItems + newItems
		
		await store.schedule { [store] in
			let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
			try? localFeedLoader.save(items)
		}
		
		return try await makePage(items: items, last: newItems.last)
	}
	
	private func makeFirstPage(items: [FeedImage]) -> Paginated<FeedImage> {
		makePage(items: items, last: items.last)
	}
	
	private func makePage(items: [FeedImage], last: FeedImage?) -> Paginated<FeedImage> {
		Paginated(items: items, loadMore: last.map { last in
			{ @MainActor @Sendable in try await self.loadMoreRemoteFeed(last: last) }
		})
	}
	
	private func loadLocalImageWithRemoteFallback(url: URL) async throws -> Data {
		do {
			return try await loadLocalImage(url: url)
		} catch {
			return try await loadAndCacheRemoteImage(url: url)
		}
	}
	
	private func loadLocalImage(url: URL) async throws -> Data {
		try await store.schedule { [store] in
			let localImageLoader = LocalFeedImageDataLoader(store: store)
			let imageData = try localImageLoader.loadImageData(from: url)
			return imageData
		}
	}

	private func loadAndCacheRemoteImage(url: URL) async throws -> Data {
		let (data, response) = try await httpClient.get(from: url)
		let imageData = try FeedImageDataMapper.map(data, from: response)
		await store.schedule { [store] in
			let localImageLoader = LocalFeedImageDataLoader(store: store)
			try? localImageLoader.save(data, for: url)
		}
		return imageData
	}
}

protocol StoreScheduler {
	@MainActor
	func schedule<T>(_ action: @escaping @Sendable () throws -> T) async rethrows -> T
}

extension CoreDataFeedStore: StoreScheduler {
	@MainActor
	func schedule<T>(_ action: @escaping @Sendable () throws -> T) async rethrows -> T {
		if contextQueue == .main {
			return try action()
		} else {
			return try await perform(action)
		}
	}
}

extension InMemoryFeedStore: StoreScheduler {
	@MainActor
	func schedule<T>(_ action: @escaping @Sendable () throws -> T) async rethrows -> T {
		try action()
	}
}
