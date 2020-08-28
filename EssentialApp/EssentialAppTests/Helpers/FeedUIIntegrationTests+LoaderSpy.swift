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
		
		private var feedRequests = [PassthroughSubject<[FeedImage], Error>]()
		
		var loadFeedCallCount: Int {
			return feedRequests.count
		}
		        
        func loadPublisher() -> AnyPublisher<[FeedImage], Error> {
            let publisher = PassthroughSubject<[FeedImage], Error>()
            feedRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }

		func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index].send(feed)
		}
		
		func completeFeedLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "an error", code: 0)
            feedRequests[index].send(completion: .failure(error))
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
