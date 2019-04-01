//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

private final class FeedCachePolicy {
	private let calendar = Calendar(identifier: .gregorian)
	
	private var maxCacheAgeInDays: Int {
		return 7
	}
	
	func validate(_ timestamp: Date, against date: Date) -> Bool {
		guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
			return false
		}
		return date < maxCacheAge
	}
}

public final class LocalFeedLoader {
	private let store: FeedStore
	private let currentDate: () -> Date
	private let cachePolicy = FeedCachePolicy()
	
	public init(store: FeedStore, currentDate: @escaping () -> Date) {
		self.store = store
		self.currentDate = currentDate
	}
}

extension LocalFeedLoader {
	public typealias SaveResult = Error?

	public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
		store.deleteCachedFeed { [weak self] error in
			guard let self = self else { return }
			
			if let cacheDeletionError = error {
				completion(cacheDeletionError)
			} else {
				self.cache(feed, with: completion)
			}
		}
	}
	
	private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
		store.insert(feed.toLocal(), timestamp: currentDate()) { [weak self] error in
			guard self != nil else { return }
			
			completion(error)
		}
	}
}

extension LocalFeedLoader: FeedLoader {
	public typealias LoadResult = LoadFeedResult

	public func load(completion: @escaping (LoadResult) -> Void) {
		store.retrieve { [weak self] result in
			guard let self = self else { return }
			
			switch result {
			case let .failure(error):
				completion(.failure(error))

			case let .found(feed, timestamp) where self.cachePolicy.validate(timestamp, against: self.currentDate()):
				completion(.success(feed.toModels()))
				
			case .found, .empty:
				completion(.success([]))
			}
		}
	}
}

extension LocalFeedLoader {
	public func validateCache() {
		store.retrieve { [weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .failure:
				self.store.deleteCachedFeed { _ in }
				
			case let .found(_, timestamp) where !self.cachePolicy.validate(timestamp, against: self.currentDate()):
				self.store.deleteCachedFeed { _ in }
				
			case .empty, .found: break
			}
		}
	}
}

private extension Array where Element == FeedImage {
	func toLocal() -> [LocalFeedImage] {
		return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
	}
}

private extension Array where Element == LocalFeedImage {
	func toModels() -> [FeedImage] {
		return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
	}
}
