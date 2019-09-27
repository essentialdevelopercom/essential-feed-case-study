//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

public final class LocalFeedImageDataLoader: FeedImageDataLoader {
	private let store: FeedImageDataStore
	
	public init(store: FeedImageDataStore) {
		self.store = store
	}
	
	public enum Error: Swift.Error {
		case failed
		case notFound
	}
	
	private final class Task: FeedImageDataLoaderTask {
		private var completion: ((FeedImageDataLoader.Result) -> Void)?
		
		init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
			self.completion = completion
		}
		
		func complete(with result: FeedImageDataLoader.Result) {
			completion?(result)
		}
		
		func cancel() {
			preventFurtherCompletions()
		}
		
		private func preventFurtherCompletions() {
			completion = nil
		}
	}
	
	public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
		let task = Task(completion)
		store.retrieve(dataForURL: url) { [weak self] result in
			guard self != nil else { return }
			
			task.complete(with: result
				.mapError { _ in Error.failed }
				.flatMap { data in
					data.map { .success($0) } ?? .failure(Error.notFound)
				})
		}
		return task
	}
}
