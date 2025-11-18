//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS
import Combine

extension FeedUIIntegrationTests {
	
	@MainActor
	class LoaderSpy {
		
		// MARK: - FeedLoader
		
		private var feedRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()
		
		var loadFeedCallCount: Int {
			return feedRequests.count
		}
		
		func loadPublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
			let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
			feedRequests.append(publisher)
			return publisher.eraseToAnyPublisher()
		}
		
		func completeFeedLoadingWithError(at index: Int = 0) {
			feedRequests[index].send(completion: .failure(anyNSError()))
		}
		
		func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
			feedRequests[index].send(Paginated(items: feed, loadMorePublisher: { [weak self] in
				self?.loadMorePublisher() ?? Empty().eraseToAnyPublisher()
			}))
			feedRequests[index].send(completion: .finished)
		}
		
		// MARK: - LoadMoreFeedLoader
		
		private var loadMoreRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()
		
		var loadMoreCallCount: Int {
			return loadMoreRequests.count
		}
		
		func loadMorePublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
			let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
			loadMoreRequests.append(publisher)
			return publisher.eraseToAnyPublisher()
		}
		
		func completeLoadMore(with feed: [FeedImage] = [], lastPage: Bool = false, at index: Int = 0) {
			loadMoreRequests[index].send(Paginated(
											items: feed,
											loadMorePublisher: lastPage ? nil : { [weak self] in
												self?.loadMorePublisher() ?? Empty().eraseToAnyPublisher()
											}))
		}
		
		func completeLoadMoreWithError(at index: Int = 0) {
			loadMoreRequests[index].send(completion: .failure(anyNSError()))
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
		
		func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
			imageLoader.complete(with: imageData, at: index)
		}
		
		func completeImageLoadingWithError(at index: Int = 0) {
			imageLoader.fail(with: anyNSError(), at: index)
		}
		
		func imageResult(at index: Int, timeout: TimeInterval = 1) async throws -> AsyncResult {
			try await imageLoader.result(at: index, timeout: timeout)
		}
		
		func cancelPendingRequests() async throws {
			try await imageLoader.cancelPendingRequests()
		}
	}
	
}
