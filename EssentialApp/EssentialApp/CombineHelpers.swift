//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import Combine
import EssentialFeed

public extension Paginated {
	init(items: [Item], loadMorePublisher: (() -> AnyPublisher<Self, Error>)?) {
		self.init(items: items, loadMore: loadMorePublisher.map { publisher in
			return { completion in
				publisher().subscribe(Subscribers.Sink(receiveCompletion: { result in
					if case let .failure(error) = result {
						completion(.failure(error))
					}
				}, receiveValue: { result in
					completion(.success(result))
				}))
			}
		})
	}
	
	var loadMorePublisher: (() -> AnyPublisher<Self, Error>)? {
		guard let loadMore = loadMore else { return nil }
		
		return {
			Deferred {
				Future(loadMore)
			}.eraseToAnyPublisher()
		}
	}
}

public extension HTTPClient {
	typealias Publisher = AnyPublisher<(Data, HTTPURLResponse), Error>
	
	func getPublisher(url: URL) -> Publisher {
		var task: HTTPClientTask?
		
		return Deferred {
			Future { completion in
				task = self.get(from: url, completion: completion)
			}
		}
		.handleEvents(receiveCancel: { task?.cancel() })
		.eraseToAnyPublisher()
	}
}

public extension FeedImageDataLoader {
	typealias Publisher = AnyPublisher<Data, Error>
	
	func loadImageDataPublisher(from url: URL) -> Publisher {
		return Deferred {
			Future { completion in
				completion(Result {
					try self.loadImageData(from: url)
				})
			}
		}
		.eraseToAnyPublisher()
	}
}

extension Publisher where Output == Data {
	func caching(to cache: FeedImageDataCache, using url: URL) -> AnyPublisher<Output, Failure> {
		handleEvents(receiveOutput: { data in
			cache.saveIgnoringResult(data, for: url)
		}).eraseToAnyPublisher()
	}
}

private extension FeedImageDataCache {
	func saveIgnoringResult(_ data: Data, for url: URL) {
		try? save(data, for: url)
	}
}

public extension LocalFeedLoader {
	typealias Publisher = AnyPublisher<[FeedImage], Error>
	
	func loadPublisher() -> Publisher {
		Deferred {
			Future(self.load)
		}
		.eraseToAnyPublisher()
	}
}

extension Publisher {
	func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
		self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
	}
}

extension Publisher {
	func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> where Output == [FeedImage] {
		handleEvents(receiveOutput: cache.saveIgnoringResult).eraseToAnyPublisher()
	}
	
	func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> where Output == Paginated<FeedImage> {
		handleEvents(receiveOutput: cache.saveIgnoringResult).eraseToAnyPublisher()
	}
}

private extension FeedCache {
	func saveIgnoringResult(_ feed: [FeedImage]) {
		save(feed) { _ in }
	}
	
	func saveIgnoringResult(_ page: Paginated<FeedImage>) {
		saveIgnoringResult(page.items)
	}
}

extension Publisher {
	func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
		receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
	}
}

extension DispatchQueue {
	static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
		ImmediateWhenOnMainQueueScheduler.shared
	}
	
	struct ImmediateWhenOnMainQueueScheduler: Scheduler {
		typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
		typealias SchedulerOptions = DispatchQueue.SchedulerOptions
		
		var now: SchedulerTimeType {
			DispatchQueue.main.now
		}
		
		var minimumTolerance: SchedulerTimeType.Stride {
			DispatchQueue.main.minimumTolerance
		}
		
		static let shared = Self()
		
		private static let key = DispatchSpecificKey<UInt8>()
		private static let value = UInt8.max
		
		private init() {
			DispatchQueue.main.setSpecific(key: Self.key, value: Self.value)
		}
		
		private func isMainQueue() -> Bool {
			DispatchQueue.getSpecific(key: Self.key) == Self.value
		}
		
		func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
			guard isMainQueue() else {
				return DispatchQueue.main.schedule(options: options, action)
			}
			
			action()
		}
		
		func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
			DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
		}
		
		func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
			DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
		}
	}
}
