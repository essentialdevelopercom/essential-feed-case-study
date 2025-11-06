//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

extension FeedUIIntegrationTests {
	
	@MainActor
	class LoaderSpy {
		
		// MARK: - FeedLoader
		
		private var feedLoader = EssentialAppTests.LoaderSpy<Void, Paginated<FeedImage>>()
		
		var loadFeedCallCount: Int {
			return feedLoader.requests.count
		}
		
		func loadFeed() async throws -> Paginated<FeedImage> {
			try await feedLoader.load(())
		}
		
		func completeFeedLoadingWithError(at index: Int = 0) async {
			await feedLoader.fail(with: anyNSError(), at: index)
		}
		
		func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) async {
			await feedLoader.complete(
				with: Paginated(
					items: feed,
					loadMore: { @MainActor [weak self] in
						try await self?.loadMore() ?? Paginated(items: [])
					}),
				at: index)
		}
		
		// MARK: - LoadMoreFeedLoader
		
		private var loadMoreLoader = EssentialAppTests.LoaderSpy<Void, Paginated<FeedImage>>()
		
		var loadMoreCallCount: Int {
			return loadMoreLoader.requests.count
		}
		
		func loadMore() async throws -> Paginated<FeedImage> {
			try await loadMoreLoader.load(())
		}
		
		func completeLoadMore(with feed: [FeedImage] = [], lastPage: Bool = false, at index: Int = 0) async {
			let loadMore: @Sendable () async throws -> Paginated<FeedImage> = { @MainActor [weak self] in
				try await self?.loadMore() ?? Paginated(items: [])
			}
			
			await loadMoreLoader.complete(
				with: Paginated(
					items: feed,
					loadMore: lastPage ? nil : loadMore),
				at: index)
		}
		
		func completeLoadMoreWithError(at index: Int = 0) async {
			await loadMoreLoader.fail(with: anyNSError(), at: index)
		}
		
		// MARK: - FeedImageDataLoader
		
		private var imageLoader = EssentialAppTests.LoaderSpy<URL, Data>()
		
		var loadedImageURLs: [URL] {
			return imageLoader.requests.map { $0.param }
		}
		
		var cancelledImageURLs: [URL] {
			return imageLoader.requests.filter({ $0.result == .cancelled }).map { $0.param }
		}
		
		private struct NoResponse: Error {}
		private struct Timeout: Error {}
		
		func loadImageData(from url: URL) async throws -> Data {
			try await imageLoader.load(url)
		}
		
		func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) async {
			await imageLoader.complete(with: imageData, at: index)
		}
		
		func completeImageLoadingWithError(at index: Int = 0) async {
			await imageLoader.fail(with: anyNSError(), at: index)
		}
		
		func imageResult(at index: Int, timeout: TimeInterval = 1) async throws -> AsyncResult {
			try await imageLoader.result(at: index, timeout: timeout)
		}
		
		func cancelPendingRequests() async throws {
			try await imageLoader.cancelPendingRequests()
			try await feedLoader.cancelPendingRequests()
			try await loadMoreLoader.cancelPendingRequests()
		}
	}
	
}
