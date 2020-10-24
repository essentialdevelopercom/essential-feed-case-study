//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS
import Combine

extension FeedUIIntegrationTests {
	
	class LoaderSpy: FeedImageDataLoader {
		
		// MARK: - FeedLoader
		
        private var feedRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()
        private var loadMoreRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()

		var loadFeedCallCount: Int {
			return feedRequests.count
		}
        
        var loadMoreCallCount: Int {
            return loadMoreRequests.count
        }
		        
        func loadPublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
            let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
            feedRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }

		func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index].send(Paginated(items: feed, loadMorePublisher: { [weak self] in
                let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
                self?.loadMoreRequests.append(publisher)
                return publisher.eraseToAnyPublisher()
            }))
		}
		
		func completeFeedLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "an error", code: 0)
            feedRequests[index].send(completion: .failure(error))
		}
        
        func completeLoadMore(with feed: [FeedImage] = [], lastPage: Bool = false, at index: Int = 0) {
            loadMoreRequests[index].send(Paginated(
                items: feed,
                loadMorePublisher: lastPage ? nil : { [weak self] in
                    let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
                    self?.loadMoreRequests.append(publisher)
                    return publisher.eraseToAnyPublisher()
                }))
        }
        
        func completeLoadMoreWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            loadMoreRequests[index].send(completion: .failure(error))
        }
		
		// MARK: - FeedImageDataLoader
		
		private struct TaskSpy: FeedImageDataLoaderTask {
			let cancelCallback: () -> Void
			func cancel() {
				cancelCallback()
			}
		}
		
		private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
		
		var loadedImageURLs: [URL] {
			return imageRequests.map { $0.url }
		}
		
		private(set) var cancelledImageURLs = [URL]()
		
		func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
			imageRequests.append((url, completion))
			return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
		}
		
		func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
			imageRequests[index].completion(.success(imageData))
		}
		
		func completeImageLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "an error", code: 0)
			imageRequests[index].completion(.failure(error))
		}
	}
	
}
