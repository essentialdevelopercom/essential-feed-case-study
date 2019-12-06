//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

class FeedAcceptanceTests: XCTestCase {
	
	func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
		let feed = launch(httpClient: .online(response), store: .empty)
		
		XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 2)
		XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData())
		XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData())
	}
	
	func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
		let sharedStore = InMemoryFeedStore.empty
		let onlineFeed = launch(httpClient: .online(response), store: sharedStore)
		onlineFeed.simulateFeedImageViewVisible(at: 0)
		onlineFeed.simulateFeedImageViewVisible(at: 1)
		
		let offlineFeed = launch(httpClient: .offline, store: sharedStore)

		XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews(), 2)
		XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData())
		XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData())
	}
	
	func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
		let feed = launch(httpClient: .offline, store: .empty)
		
		XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 0)
	}
	
	func test_onEnteringBackground_deletesExpiredFeedCache() {
		let store = InMemoryFeedStore.withExpiredFeedCache
		
		enterBackground(with: store)

		XCTAssertNil(store.feedCache, "Expected to delete expired cache")
	}
	
	func test_onEnteringBackground_keepsNonExpiredFeedCache() {
		let store = InMemoryFeedStore.withNonExpiredFeedCache
		
		enterBackground(with: store)
		
		XCTAssertNotNil(store.feedCache, "Expected to keep non-expired cache")
	}
	
	// MARK: - Helpers

	private func launch(
		httpClient: HTTPClientStub = .offline,
		store: InMemoryFeedStore = .empty
	) -> FeedViewController {
		let sut = SceneDelegate(httpClient: httpClient, store: store)
		sut.window = UIWindow()
		sut.configureWindow()
		
		let nav = sut.window?.rootViewController as? UINavigationController
		return nav?.topViewController as! FeedViewController
	}
	
	private func enterBackground(with store: InMemoryFeedStore) {
		let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
		sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
	}

	private func response(for url: URL) -> (Data, HTTPURLResponse) {
		let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
		return (makeData(for: url), response)
	}
	
	private func makeData(for url: URL) -> Data {
		switch url.absoluteString {
		case "http://image.com":
			return makeImageData()
			
		default:
			return makeFeedData()
		}
	}
	
	private func makeImageData() -> Data {
		return UIImage.make(withColor: .red).pngData()!
	}
	
	private func makeFeedData() -> Data {
		return try! JSONSerialization.data(withJSONObject: ["items": [
			["id": UUID().uuidString, "image": "http://image.com"],
			["id": UUID().uuidString, "image": "http://image.com"]
		]])
	}

}
