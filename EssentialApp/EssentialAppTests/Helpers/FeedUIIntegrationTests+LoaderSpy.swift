//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS
import Combine

extension FeedUIIntegrationTests {
	
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
		
		private var imageRequests = [(url: URL, publisher: PassthroughSubject<Data, Error>)]()
		
		var loadedImageURLs: [URL] {
			return imageRequests.map { $0.url }
		}
		
		private(set) var cancelledImageURLs = [URL]()
		
		func loadImageDataPublisher(from url: URL) -> AnyPublisher<Data, Error> {
			let publisher = PassthroughSubject<Data, Error>()
			imageRequests.append((url, publisher))
			return publisher.handleEvents(receiveCancel: { [weak self] in
				self?.cancelledImageURLs.append(url)
			}).eraseToAnyPublisher()
		}
		
		func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
			imageRequests[index].publisher.send(imageData)
			imageRequests[index].publisher.send(completion: .finished)
		}
		
		func completeImageLoadingWithError(at index: Int = 0) {
			imageRequests[index].publisher.send(completion: .failure(anyNSError()))
		}
	}
	
}
